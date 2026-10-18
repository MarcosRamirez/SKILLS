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
