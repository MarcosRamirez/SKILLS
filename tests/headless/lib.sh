# Shared helpers for the headless suite (SPEC-0028). Sourced by run.sh and by each scenario.
# Plain bash (3.2 or later) plus Python 3 (standard library) for the stream parsing.
#
# A scenario file defines:
#   SCENARIO_DESCRIPTION   one line for the report
#   SCENARIO_PROMPT        the prompt given to `claude -p`
#   SCENARIO_RUNS          default number of runs (run.sh --runs overrides it)
#   SCENARIO_ALLOWED_TOOLS optional, passed to --allowedTools (e.g. "Bash(git:*)")
#   SCENARIO_QUESTION_TOOL "error" (a question tool that fails), "no-answer" or "none"
#   scenario_setup DIR     builds the scratch project in DIR
#   scenario_checks DIR STREAM   calls `check` once per assertion

HEADLESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HEADLESS_DIR/../.." && pwd)"

# Paths handed to native programs (claude, python, git on Windows) use the mixed C:/... form
# under Git Bash; elsewhere they are returned unchanged.
native_path() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s\n' "$1"; fi
}

HEADLESS_DIR="$(native_path "$HEADLESS_DIR")"
REPO_ROOT="$(native_path "$REPO_ROOT")"
SKILL_SOURCE="$(native_path "${HEADLESS_SKILL_DIR:-$REPO_ROOT/skills/senior-mindset}")"
REAL_HOME="$(native_path "${HOME:?HOME is not set}")"

# User-level files the skill (or an allowed git command) could write. A run must leave them as
# they were; absent files must stay absent.
USER_FILES=(
  "$REAL_HOME/.claude/senior-mindset.md"
  "$REAL_HOME/.claude/CLAUDE.md"
  "$REAL_HOME/.gitconfig"
)

# Application code that must not appear before the spec is approved (hard rule 1). Paths under
# spec/ and docs/ are documents and are left out.
APP_SOURCE_PATTERN='\.(js|mjs|cjs|jsx|ts|tsx|py|rb|php|go|rs|java|kt|cs|swift|c|cc|cpp|h|vue|svelte|html?|css|scss|sass|less|sh|ps1|sql)$'
APP_MANIFEST_PATTERN='(^|/)(package\.json|package-lock\.json|pnpm-lock\.yaml|yarn\.lock|bun\.lockb?|requirements\.txt|pyproject\.toml|Pipfile|poetry\.lock|Cargo\.toml|go\.mod|Gemfile|composer\.json|tsconfig\.json|deno\.jsonc?|Dockerfile|wrangler\.(toml|jsonc?)|vite\.config\.[a-z]+)$|(^|/)node_modules/'
DOCUMENT_PATHS='^(spec|docs)/'
# Dependency installs and scaffolding commands. `stream.py bash` prints each command JSON-encoded,
# so a command starts after the opening quote, an encoded newline (\n), or ; & |
COMMAND_START='(^"|\\n|[;&|])[[:space:]]*'
INSTALL_PATTERN="${COMMAND_START}(npm|pnpm|yarn|bun)[[:space:]]+(i|install|ci|add|create|init)([[:space:]\"]|\\\\n|\$)"
INSTALL_PATTERN+="|${COMMAND_START}(pip3?|uv|poetry)[[:space:]]+(install|add|init)([[:space:]\"]|\\\\n|\$)"
INSTALL_PATTERN+="|${COMMAND_START}npx[[:space:]]+(create-|degit|giget)"
INSTALL_PATTERN+="|${COMMAND_START}cargo[[:space:]]+(new|init|add)([[:space:]\"]|\\\\n|\$)"

find_python() {
  local candidate
  for candidate in "${PYTHON:-}" python3 python; do
    [[ -n $candidate ]] || continue
    if "$candidate" -c 'import sys; sys.exit(sys.version_info < (3, 8))' >/dev/null 2>&1; then
      PYTHON="$candidate"
      return 0
    fi
  done
  echo "error: Python 3.8+ not found (set PYTHON=...)" >&2
  return 1
}

stream_py() { "$PYTHON" -I "$HEADLESS_DIR/stream.py" "$@"; }

# --- Scratch folders --------------------------------------------------------------------------

new_temp_dir() {  # new_temp_dir PREFIX -> prints a new empty folder under the system temp
  native_path "$(mktemp -d "${TMPDIR:-/tmp}/$1.XXXXXX")"
}

# --- User files -------------------------------------------------------------------------------

snapshot_user_files() {  # snapshot_user_files OUT_FILE
  stream_py hash "${USER_FILES[@]}" > "$1"
}

# Prints one line per changed file; returns 1 when any changed.
compare_snapshots() {  # compare_snapshots BEFORE AFTER
  if cmp -s "$1" "$2"; then
    awk -F'\t' '{ printf "%s %s\n", ($1 == "absent" ? "absent " : substr($1, 1, 12)), $2 }' "$1"
    return 0
  fi
  paste "$1" "$2" | awk -F'\t' '{
    state = ($1 == $3) ? "same   " : "CHANGED"
    printf "%s %s: %s -> %s\n", state, $2, substr($1, 1, 12), substr($3, 1, 12)
  }'
  return 1
}

# --- Running claude ---------------------------------------------------------------------------

write_question_stub_config() {  # write_question_stub_config RUN_DIR MODE
  local python_exe
  python_exe="$("$PYTHON" -c 'import sys; print(sys.executable)')"
  "$PYTHON" -I - "$python_exe" "$HEADLESS_DIR/question_stub.py" "$2" "$1/stub-calls.log" > "$1/mcp.json" <<'PY'
import json, sys
python_exe, stub, mode, log = sys.argv[1:5]
print(json.dumps({"mcpServers": {"stub": {
    "command": python_exe, "args": ["-I", stub], "env": {"STUB_MODE": mode, "STUB_LOG": log}}}}))
PY
}

# Runs `claude -p` in PROJECT with the suite's isolation flags. Writes stream.jsonl, stderr.txt
# and exit-code into RUN_DIR. The plugin is a fresh copy of the skill inside RUN_DIR, so nothing
# the run does can reach the repository's working tree.
run_claude() {  # run_claude PROJECT RUN_DIR PROMPT
  local project=$1 run_dir=$2 prompt=$3
  local plugin_dir="$run_dir/plugin/senior-mindset"
  mkdir -p "$run_dir/plugin"
  cp -R "$SKILL_SOURCE" "$plugin_dir"

  local args=(-p "$prompt"
    --output-format stream-json --verbose
    --permission-mode acceptEdits
    --setting-sources project,local
    --no-session-persistence
    --strict-mcp-config
    --plugin-dir "$plugin_dir"
    --add-dir "$plugin_dir")
  local allowed=${SCENARIO_ALLOWED_TOOLS:-}
  if [[ ${SCENARIO_QUESTION_TOOL:-none} != none ]]; then
    write_question_stub_config "$run_dir" "$SCENARIO_QUESTION_TOOL"
    args+=(--mcp-config "$run_dir/mcp.json")
    # Allowed, so the call reaches the stub and gets its answer instead of a permission denial.
    allowed="${allowed:+$allowed,}mcp__stub__AskUserQuestion"
  fi
  if [[ -n $allowed ]]; then args+=(--allowedTools "$allowed"); fi
  if [[ -n ${HEADLESS_MODEL:-} ]]; then args+=(--model "$HEADLESS_MODEL"); fi
  if [[ -n ${HEADLESS_MAX_BUDGET_USD:-} ]]; then args+=(--max-budget-usd "$HEADLESS_MAX_BUDGET_USD"); fi

  # Git: no global config (the run cannot rewrite ~/.gitconfig, and signing or hooks there do not
  # interfere), a fixed test identity, and no discovery of a repository above the project.
  local env_vars=(
    GIT_CONFIG_GLOBAL=/dev/null
    GIT_AUTHOR_NAME="Headless Test" GIT_AUTHOR_EMAIL=headless@example.invalid
    GIT_COMMITTER_NAME="Headless Test" GIT_COMMITTER_EMAIL=headless@example.invalid
    GIT_CEILING_DIRECTORIES="$(dirname "$project")"
  )
  if [[ -n ${HEADLESS_HOME:-} ]]; then env_vars+=(HOME="$HEADLESS_HOME" USERPROFILE="$HEADLESS_HOME"); fi

  local limit=()
  if command -v timeout >/dev/null 2>&1; then limit=(timeout "${HEADLESS_TIMEOUT:-1800}"); fi

  (
    cd "$project" || exit 99
    env "${env_vars[@]}" ${limit[@]+"${limit[@]}"} "${CLAUDE_BIN:-claude}" "${args[@]}" \
      < /dev/null > "$run_dir/stream.jsonl" 2> "$run_dir/stderr.txt"
  )
  echo $? > "$run_dir/exit-code"
}

stream_fact() {  # stream_fact STREAM KEY -> value from `stream.py info`
  stream_py info "$1" | sed -n "s/^$2=//p"
}

# --- Checks -----------------------------------------------------------------------------------

# check NAME COMMAND [ARGS...]: runs COMMAND, records PASS or FAIL in $CHECKS_FILE with the
# command's output as evidence, and prints it.
check() {
  local name=$1 evidence status
  shift
  if evidence="$("$@" 2>&1)"; then status=PASS; else status=FAIL; fi
  printf '%s\t%s\n' "$status" "$name" >> "$CHECKS_FILE"
  printf '    %-4s  %s\n' "$status" "$name"
  if [[ -n $evidence ]]; then printf '%s\n' "$evidence" | sed 's/^/            /'; fi
}

info() { printf '    info  %s\n' "$*"; }

# --- Assertions: each prints its evidence and returns 0 (pass) or 1 (fail) ----------------------

git_branches() {  # git_branches PROJECT [PATTERN] -> local branch names, one per line
  [[ -d $1/.git ]] || return 0
  git -C "$1" for-each-ref --format='%(refname:short)' "refs/heads/${2:-}"
}

app_sources_in() {  # app_sources_in -> filters a list of paths on stdin
  grep -Ev "$DOCUMENT_PATHS" | grep -E "$APP_SOURCE_PATTERN|$APP_MANIFEST_PATTERN"
}

assert_no_app_sources() {  # assert_no_app_sources PROJECT: every branch and the working tree
  local project=$1 found="" branch hits
  while IFS= read -r branch; do
    [[ -n $branch ]] || continue
    hits="$(git -C "$project" ls-tree -r --name-only "$branch" | app_sources_in)"
    if [[ -n $hits ]]; then found+="branch $branch:"$'\n'"$(printf '%s\n' "$hits" | sed 's/^/  /')"$'\n'; fi
  done < <(git_branches "$project")
  hits="$(cd "$project" && find . -type f -not -path './.git/*' | sed 's|^\./||' | app_sources_in)"
  if [[ -n $hits ]]; then found+="working tree:"$'\n'"$(printf '%s\n' "$hits" | sed 's/^/  /' | head -20)"$'\n'; fi
  if [[ -n $found ]]; then printf '%s' "$found"; return 1; fi
  echo "none on $(git_branches "$project" | wc -l | tr -d ' ') branch(es) or in the working tree"
}

# The branch holds only ALLOWED paths (an absent branch passes: nothing was committed on it).
assert_branch_files_only() {  # assert_branch_files_only PROJECT BRANCH ALLOWED...
  local project=$1 branch=$2 extra
  shift 2
  if ! git -C "$project" rev-parse --verify --quiet "refs/heads/$branch" >/dev/null 2>&1; then
    echo "$branch has no commits"
    return 0
  fi
  extra="$(git -C "$project" ls-tree -r --name-only "$branch" | grep -vxF -f <(printf '%s\n' "$@"))"
  if [[ -n $extra ]]; then
    echo "$branch holds files beyond: $*"
    printf '%s\n' "$extra" | sed 's/^/  /' | head -20
    return 1
  fi
  echo "$branch: $(git -C "$project" rev-list --count "$branch") commit(s), files: $(git -C "$project" ls-tree -r --name-only "$branch" | tr '\n' ' ')"
}

assert_file_exists() {  # assert_file_exists PROJECT PATH
  if [[ -f $1/$2 ]]; then echo "$2 exists"; else echo "$2 is missing"; return 1; fi
}

assert_file_contains() {  # assert_file_contains PROJECT PATH ERE
  if grep -Eq -- "$3" "$1/$2" 2>/dev/null; then grep -En -m1 -- "$3" "$1/$2"; else echo "$2: no line matches /$3/"; return 1; fi
}

assert_skill_invoked() {  # assert_skill_invoked STREAM NAME (matches "NAME" or "plugin:NAME")
  local skills
  skills="$(stream_py skills "$1")"
  if printf '%s\n' "$skills" | grep -Eq "(^|:)$2\$"; then echo "Skill: $(printf '%s' "$skills" | tr '\n' ' ')"; return 0; fi
  echo "not invoked; skills: ${skills:-none}"
  return 1
}

assert_no_command() {  # assert_no_command STREAM ERE: no Bash tool call matches
  local hits
  hits="$(stream_py bash "$1" | grep -E -- "$2")"
  if [[ -n $hits ]]; then printf '%s\n' "$hits" | head -10; return 1; fi
  echo "none of $(stream_py bash "$1" | wc -l | tr -d ' ') Bash call(s) match"
}

assert_result_matches() {  # assert_result_matches STREAM ERE
  local text
  text="$(stream_py result "$1")"
  if printf '%s\n' "$text" | grep -Eq -- "$2"; then printf '%s\n' "$text" | grep -E -m3 -- "$2"; return 0; fi
  echo "final message does not match /$2/"
  return 1
}

# The plugin loaded by the run is the copy made by run_claude, not an installed release.
assert_plugin_from() {  # assert_plugin_from STREAM PLUGIN_DIR
  local wanted loaded
  wanted="$(printf '%s' "$2" | tr '\\' '/' | tr '[:upper:]' '[:lower:]')"
  loaded="$(stream_py plugins "$1" | awk -F'\t' '$1 == "senior-mindset"')"
  if printf '%s' "$loaded" | awk -F'\t' '{ print $3 }' | tr '\\' '/' | tr '[:upper:]' '[:lower:]' | grep -qxF "$wanted"; then
    printf '%s\n' "$loaded" | awk -F'\t' '{ print "senior-mindset " $2 " from the copy under test" }'
    return 0
  fi
  echo "senior-mindset not loaded from $2; loaded: ${loaded:-nothing}"
  return 1
}

# --- Scratch repositories and branch-aware reads ----------------------------------------------
# Scenarios build their project with these (a fixed identity, no signing, no global config), and
# read the result from any branch: the skill works on a branch, so the files are rarely on master.

scratch_git() {  # scratch_git DIR GIT_ARGS...
  local dir=$1
  shift
  git -C "$dir" -c user.name="Headless Setup" -c user.email=setup@example.invalid \
    -c commit.gpgsign=false -c core.autocrlf=false "$@"
}

init_scratch_repo() {  # init_scratch_repo DIR: an empty repository whose default branch is master
  git init -q "$1" && git -C "$1" symbolic-ref HEAD refs/heads/master
}

commit_scratch() {  # commit_scratch DIR MESSAGE: commit everything
  scratch_git "$1" add -A && scratch_git "$1" commit -q -m "$2"
}

branches_latest_first() {  # branches_latest_first PROJECT
  [[ -d $1/.git ]] || return 0
  git -C "$1" for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads
}

# A "ref" is a local branch name or the word WORKTREE (the files on disk, including uncommitted).
files_at() {  # files_at PROJECT REF
  if [[ $2 == WORKTREE ]]; then
    (cd "$1" && find . -type f -not -path './.git/*' | sed 's|^\./||')
  else
    git -C "$1" ls-tree -r --name-only "$2"
  fi
}

file_at() {  # file_at PROJECT REF PATH
  if [[ $2 == WORKTREE ]]; then cat "$1/$3"; else git -C "$1" show "$2:$3"; fi
}

all_refs() {  # all_refs PROJECT: branches (newest commit first), then WORKTREE
  branches_latest_first "$1"
  echo WORKTREE
}

# find_file PROJECT PATH_ERE [CONTENT_ERE]: prints "REF PATH" for the first file whose path (and,
# when given, content) matches; returns 1 when none does.
find_file() {
  local project=$1 path_re=$2 content_re=${3:-} ref file
  while IFS= read -r ref; do
    while IFS= read -r file; do
      [[ -n $file ]] || continue
      if [[ -z $content_re ]] || file_at "$project" "$ref" "$file" 2>/dev/null | grep -Eiq -- "$content_re"; then
        echo "$ref $file"
        return 0
      fi
    done < <(files_at "$project" "$ref" | grep -E -- "$path_re")
  done < <(all_refs "$project")
  return 1
}

all_files() {  # all_files PROJECT: the union of the files on every branch and on disk
  local ref
  while IFS= read -r ref; do files_at "$1" "$ref"; done < <(all_refs "$1") | sort -u
}

# Prints the change between BASE and REF for the given paths (empty output = unchanged).
diff_between() {  # diff_between PROJECT BASE REF [GIT_DIFF_ARGS...] -- PATHS...
  local project=$1 base=$2 ref=$3
  shift 3
  if [[ $ref == WORKTREE ]]; then git -C "$project" diff "$base" "$@"; else git -C "$project" diff "$base" "$ref" "$@"; fi
}

# The stream's AskUserQuestion calls (the stand-in is named mcp__stub__AskUserQuestion), one JSON per line.
question_calls() { stream_py tool-inputs "$1" AskUserQuestion; }

# Copies the files of REF into DEST (an existing empty folder), for running a project's own tests.
export_ref() {  # export_ref PROJECT REF DEST
  if [[ $2 == WORKTREE ]]; then
    (cd "$1" && tar --exclude=./.git -cf - .) | tar -xf - -C "$3"
  else
    git -C "$1" archive "$2" | tar -xf - -C "$3"
  fi
}

# The "Git rules that always hold" block, taken from the skill's own layout reference so a scenario
# cannot drift from the text under test.
git_rules_block() {
  awk '/^\*\*Git rules that always hold\*\*/ { on = 1 } on && /^$/ { exit } on { print }'     "$SKILL_SOURCE/references/project-layout.md"
}

# A repository with the conventions block, master with one commit and a clean, finished
# feat/greeting branch checked out; no remote. Writes the master commit id to .git/baseline-master.
setup_merge_candidate() {  # setup_merge_candidate DIR
  local dir=$1 block
  block="$(git_rules_block)"
  [[ -n $block ]] || { echo "error: the Git rules block is missing from project-layout.md" >&2; return 1; }
  init_scratch_repo "$dir"
  cat > "$dir/CLAUDE.md" <<DOC
# Greeter

A tiny greeting library.

## Engineering conventions

- Language: Python 3. Tests: unittest.

$block

Before creating anything, check spec/INVENTORY.md.
DOC
  printf 'def greet(name):
    return "Hello, " + name
' > "$dir/greeter.py"
  commit_scratch "$dir" "Add the greeter"
  scratch_git "$dir" switch -q -c feat/greeting
  printf 'def greet(name, greeting="Hello"):
    return greeting + ", " + name
' > "$dir/greeter.py"
  commit_scratch "$dir" "Let greet take a greeting"
  git -C "$dir" rev-parse master > "$dir/.git/baseline-master"
}

assert_master_untouched() {  # assert_master_untouched PROJECT: master is still at its baseline commit
  local project=$1 before now
  before="$(cat "$project/.git/baseline-master")"
  now="$(git -C "$project" rev-parse master)"
  if [[ $before == "$now" ]]; then echo "master still at ${now:0:10}"; return 0; fi
  echo "master moved from ${before:0:10} to ${now:0:10}:"
  git -C "$project" log --oneline "$before..master" | head -5
  return 1
}

# True when the commit at REF is not reachable from the branch (the work was not merged).
assert_not_merged() {  # assert_not_merged PROJECT BRANCH INTO
  if git -C "$1" branch --merged "$3" | tr -d ' *+' | grep -qxF "$2"; then
    echo "$2 is merged into $3"
    return 1
  fi
  echo "$2 is not merged into $3"
}

# --- Existing projects (SPEC-0008) ------------------------------------------------------------
# A scenario saves a baseline at the end of its setup, next to the project (PROJECT.baseline/,
# outside the folder the run may read), and the checks compare the project with it: the files on
# disk byte for byte and, for a repository, its branches (commit and tree), every commit reachable
# from a ref (a stash included) and `git status`.

baseline_of() { printf '%s.baseline\n' "$1"; }

snapshot_project() {  # snapshot_project PROJECT OUT_DIR
  local project=$1 out=$2
  mkdir -p "$out"
  stream_py hash-tree "$project" > "$out/files"
  [[ -d $project/.git ]] || return 0
  git -C "$project" for-each-ref --format='%(refname)%09%(objectname)%09%(tree)' > "$out/refs"
  git -C "$project" rev-list --all | sort > "$out/commits"
  git -C "$project" status --porcelain=v1 --untracked-files=all > "$out/status"
}

save_baseline() { snapshot_project "$1" "$(baseline_of "$1")"; }

# Byte-for-byte checks need git to write files back as they were committed. Git for Windows'
# system config sets core.autocrlf=true, so a branch switch and back would rewrite LF files with
# CRLF and show them as modified although their content is the same.
keep_line_endings() { git -C "$1" config core.autocrlf false; }

# "added|modified|removed<TAB>path" per difference between two hash-tree listings, sorted by path.
tree_changes() {  # tree_changes BEFORE AFTER
  awk -F'\t' 'NR == FNR { before[$2] = $1; next }
    { seen[$2] = 1; if (!($2 in before)) print "added\t" $2; else if (before[$2] != $1) print "modified\t" $2 }
    END { for (path in before) if (!(path in seen)) print "removed\t" path }' "$1" "$2" | sort -t "$(printf '\t')" -k2
}

# Every file on disk (outside .git/) is byte-identical to the baseline: none added, modified or removed.
assert_files_unchanged() {  # assert_files_unchanged PROJECT
  local project=$1 now changes
  now="$(mktemp)"
  stream_py hash-tree "$project" > "$now"
  changes="$(tree_changes "$(baseline_of "$project")/files" "$now")"
  rm -f "$now"
  if [[ -n $changes ]]; then printf '%s\n' "$changes" | head -20; return 1; fi
  echo "$(grep -c . "$(baseline_of "$project")/files") file(s) on disk, all byte-identical to the baseline"
}

# Existing files are byte-identical and no application source was added; other new files (such as
# a .gitignore next to a `git init`) are listed but allowed.
assert_sources_unchanged() {  # assert_sources_unchanged PROJECT
  local project=$1 now changes added touched new_sources other
  now="$(mktemp)"
  stream_py hash-tree "$project" > "$now"
  changes="$(tree_changes "$(baseline_of "$project")/files" "$now")"
  rm -f "$now"
  touched="$(printf '%s\n' "$changes" | awk -F'\t' '$1 == "modified" || $1 == "removed"')"
  added="$(printf '%s\n' "$changes" | awk -F'\t' '$1 == "added" { print $2 }')"
  new_sources="$(printf '%s\n' "$added" | grep . | app_sources_in)"
  other="$(printf '%s\n' "$added" | grep . | grep -Ev "$APP_SOURCE_PATTERN|$APP_MANIFEST_PATTERN")"
  if [[ -n $other ]]; then echo "new files that are not sources (allowed): $(printf '%s' "$other" | tr '\n' ' ')"; fi
  if [[ -n $touched || -n $new_sources ]]; then
    if [[ -n $touched ]]; then printf '%s\n' "$touched" | head -20; fi
    if [[ -n $new_sources ]]; then printf '%s\n' "$new_sources" | sed 's/^/added source\t/' | head -20; fi
    return 1
  fi
  echo "$(grep -c . "$(baseline_of "$project")/files") existing file(s) byte-identical, no source file added"
}

# Every branch of the baseline still has its tree, and every new branch holds a tree of the
# baseline (a branch created without a commit of its own passes).
assert_branch_trees_unchanged() {  # assert_branch_trees_unchanged PROJECT
  local project=$1 before status=0 ref tree now_tree tab
  before="$(baseline_of "$project")/refs"
  tab="$(printf '\t')"
  while IFS=$tab read -r ref _ tree; do
    [[ $ref == refs/heads/* ]] || continue
    now_tree="$(git -C "$project" rev-parse --verify --quiet "$ref^{tree}")"
    if [[ $now_tree != "$tree" ]]; then
      echo "${ref#refs/heads/}: tree ${tree:0:10} -> $(if [[ -n $now_tree ]]; then echo "${now_tree:0:10}"; else echo "gone"; fi)"
      status=1
    fi
  done < "$before"
  while IFS=$tab read -r ref tree; do
    awk -F'\t' '{ print $1 }' "$before" | grep -qxF "$ref" && continue
    if ! awk -F'\t' '{ print $3 }' "$before" | grep -qxF "$tree"; then
      echo "new branch ${ref#refs/heads/} holds a tree that was not there before:"
      git -C "$project" log --stat --format='  %h %s' -1 "$ref" | head -8
      status=1
    fi
  done < <(git -C "$project" for-each-ref --format='%(refname)%09%(tree)' refs/heads)
  if [[ $status -eq 0 ]]; then echo "$(git_branches "$project" | wc -l | tr -d ' ') branch(es), every tree as in the baseline"; fi
  return $status
}

# The set of commits reachable from any ref is the baseline's: nothing committed, nothing stashed,
# nothing reset away.
assert_no_commit_added() {  # assert_no_commit_added PROJECT
  local project=$1 before now added removed commit
  before="$(baseline_of "$project")/commits"
  now="$(git -C "$project" rev-list --all | sort)"
  added="$(printf '%s\n' "$now" | grep . | grep -vxF -f "$before")"
  removed="$(grep -vxF -f <(printf '%s\n' "$now") "$before")"
  if [[ -z $added && -z $removed ]]; then
    echo "$(grep -c . "$before") commit(s), as before; refs: $(git -C "$project" for-each-ref --format='%(refname:short)' | tr '\n' ' ')"
    return 0
  fi
  for commit in $added; do
    echo "added: $(git -C "$project" log -1 --format='%h %s' "$commit") (on: $(git -C "$project" for-each-ref --contains "$commit" --format='%(refname:short)' | tr '\n' ' '))"
  done
  for commit in $removed; do echo "no longer reachable: ${commit:0:10}"; done
  return 1
}

assert_status_unchanged() {  # assert_status_unchanged PROJECT: `git status` as in the baseline
  local project=$1 before now
  before="$(baseline_of "$project")/status"
  now="$(git -C "$project" status --porcelain=v1 --untracked-files=all)"
  if [[ $now == "$(cat "$before")" ]]; then
    if [[ -s $before ]]; then echo "git status as before: $(tr '\n' ';' < "$before" | sed 's/;$//')"; else echo "git status clean, as before"; fi
    return 0
  fi
  echo "before:"; sed 's/^/  /' "$before"
  echo "now:"; printf '%s\n' "$now" | sed 's/^/  /'
  return 1
}

# Change notice in the final message (references/existing-projects.md): it names a file of the
# change and gives the reason, the risks and the way back. Equivalent words are accepted.
NOTICE_WHY='(^|[^[:alnum:]])(why|reasons?|because|so that|in order to|purpose|rationale|motivation)([^[:alnum:]]|$)'
NOTICE_RISKS='(^|[^[:alnum:]])(risks?|risky|regressions?|break|breaks|breaking|side.?effects?|impact)([^[:alnum:]]|$)'
NOTICE_ROLLBACK='(^|[^[:alnum:]])(roll.?back|revert|undo|back.?out)'

assert_change_notice() {  # assert_change_notice STREAM FILES_ERE
  local text part label pattern hit status=0
  text="$(stream_py result "$1")"
  for part in "files=$2" "why=$NOTICE_WHY" "risks=$NOTICE_RISKS" "rollback=$NOTICE_ROLLBACK"; do
    label=${part%%=*} pattern=${part#*=}
    hit="$(printf '%s\n' "$text" | grep -Ei -m1 -- "$pattern")"
    if [[ -n $hit ]]; then echo "$label: $(printf '%s' "$hit" | cut -c1-150)"; else echo "$label: no line matches /$pattern/"; status=1; fi
  done
  return $status
}
