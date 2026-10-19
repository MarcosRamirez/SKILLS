# Uncommitted user changes (SPEC-0008 AC-4): the user has a modified tracked file and an untracked
# file, and asks for a small change in another file. The skill must not touch, commit, stash or mix
# those changes: it says which files they are and asks whether to commit them on their own branch,
# stash them or stop, before changing anything. Nobody can answer here, so nothing changes at all.

SCENARIO_DESCRIPTION="uncommitted user changes are left alone, and the agent asks what to do with them"
SCENARIO_PROMPT="Use senior-mindset: make greet() in app/greeter.py strip spaces around the name."
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*)"
SCENARIO_QUESTION_TOOL=error

DIRTY_FILES=(app/config.py notes/todo.txt)
UNCOMMITTED_WORDS='uncommitted|not (yet )?committed|unstaged|untracked|local (changes|edits)|working (tree|copy)|dirty|pending changes'
COMMIT_WORD='(^|[^[:alnum:]])commit'
STASH_WORD='stash'
STOP_WORDS='(^|[^[:alnum:]])(stop|wait|abort|cancel|halt|pause|hold off|do nothing|leave (them|it|those|these|the))'
# Git commands that commit, stage, stash or discard. `git stash list` and `git stash show` only read.
GIT_WRITE="${COMMAND_START}git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?(commit|add|reset|restore|clean|stash|checkout[[:space:]]+(--|\\.))([[:space:]\"]|\\\\n|\$)"

scenario_setup() {  # a committed greeter, then the user's own edit to config.py and a new notes file
  local dir=$1
  init_scratch_repo "$dir"
  keep_line_endings "$dir"
  mkdir -p "$dir/app" "$dir/tests"
  printf '# Greeter\n\nGreets people by name. Tests: `python -m unittest discover -s tests -t .`\n' > "$dir/README.md"
  : > "$dir/app/__init__.py"
  printf 'SETTINGS = {"greeting": "Hello", "timeout_seconds": 30}\n' > "$dir/app/config.py"
  cat > "$dir/app/greeter.py" <<'DOC'
from app.config import SETTINGS


def greet(name):
    return f"{SETTINGS['greeting']}, {name}!"
DOC
  : > "$dir/tests/__init__.py"
  cat > "$dir/tests/test_greeter.py" <<'DOC'
import unittest

from app.greeter import greet


class GreetTest(unittest.TestCase):
    def test_greets_by_name(self):
        self.assertEqual(greet("Ada"), "Hello, Ada!")


if __name__ == "__main__":
    unittest.main()
DOC
  printf '__pycache__/\n*.pyc\n' > "$dir/.gitignore"
  commit_scratch "$dir" "Add the greeter"
  # The user's work in progress: not committed, not staged.
  printf 'SETTINGS = {"greeting": "Hello", "timeout_seconds": 45}  # trying a longer timeout\n' > "$dir/app/config.py"
  mkdir -p "$dir/notes"
  printf -- '- ask about the retry policy\n- maybe a "Hi" greeting for friends\n' > "$dir/notes/todo.txt"
  save_baseline "$dir"
}

# The two files hold the user's bytes and git still reports them as modified and untracked.
assert_user_changes_intact() {  # assert_user_changes_intact PROJECT
  local project=$1 file before now state status=0
  for file in "${DIRTY_FILES[@]}"; do
    before="$(awk -F'\t' -v path="$file" '$2 == path { print $1 }' "$(baseline_of "$project")/files")"
    now="$(stream_py hash "$project/$file" | cut -f1)"
    state="$(git -C "$project" status --porcelain=v1 --untracked-files=all -- "$file")"
    if [[ $now == "$before" && -n $state ]]; then
      echo "$file: same bytes (${now:0:12}), still uncommitted (${state:0:2})"
    else
      echo "$file: sha ${before:0:12} -> ${now:0:12}, git status '${state:-clean}'"
      status=1
    fi
  done
  return $status
}

# What the agent said: the final message plus any question-tool input.
answer_text() {  # answer_text STREAM
  stream_py result "$1"
  question_calls "$1"
}

# Names the uncommitted changes and asks what to do: commit them, stash them or stop.
assert_asks_about_changes() {  # assert_asks_about_changes STREAM
  local text part label pattern hit status=0 names
  text="$(answer_text "$1")"
  names="$(printf '%s\n' "$text" | grep -Eo 'config\.py|todo\.txt' | sort -u | tr '\n' ' ')"
  echo "dirty files named: ${names:-none}"
  for part in "uncommitted=$UNCOMMITTED_WORDS" "commit=$COMMIT_WORD" "stash=$STASH_WORD" "stop=$STOP_WORDS" "question=[?¿]"; do
    label=${part%%=*} pattern=${part#*=}
    hit="$(printf '%s\n' "$text" | grep -Ei -m1 -- "$pattern")"
    if [[ -n $hit ]]; then echo "$label: $(printf '%s' "$hit" | cut -c1-150)"; else echo "$label: nothing matches /$pattern/"; status=1; fi
  done
  return $status
}

assert_no_git_write() {  # assert_no_git_write STREAM: no command commits, stages, stashes or discards
  local hits
  hits="$(stream_py bash "$1" | grep -E -- "$GIT_WRITE" | grep -Ev 'stash[[:space:]]+(list|show)([[:space:]"]|\\n|$)')"
  if [[ -n $hits ]]; then printf '%s\n' "$hits" | head -10; return 1; fi
  echo "none of $(stream_py bash "$1" | wc -l | tr -d ' ') Bash call(s) commits, stages, stashes or discards"
}

assert_files_and_status() {  # assert_files_and_status PROJECT
  local status=0
  assert_files_unchanged "$1" || status=1
  assert_status_unchanged "$1" || status=1
  return $status
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "the uncommitted changes are byte-identical and still uncommitted" assert_user_changes_intact "$project"
  check "nothing committed or stashed (commits as before)" assert_no_commit_added "$project"
  check "no git command commits, stages, stashes or discards" assert_no_git_write "$stream"
  check "the agent asks what to do with them: commit on a branch, stash or stop" assert_asks_about_changes "$stream"
  check "no other file changed (working tree and git status as before)" assert_files_and_status "$project"
  check "no file changed on any branch (tree hashes as before)" assert_branch_trees_unchanged "$project"
}
