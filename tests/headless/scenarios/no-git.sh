# Folder without git (SPEC-0008 AC-5): existing code and no repository, so no way back from a
# change. The skill must propose `git init` and a commit of the current state before changing
# anything, and leave the sources alone. Hard rule 3 allows `git init -b master` only for a NEW
# project, so a `git init` run here without the OK is recorded as an observation (a finding), and
# fails the scenario only through a source file that changed.

SCENARIO_DESCRIPTION="a change to code outside git proposes git init and a snapshot commit first, with no edits"
SCENARIO_PROMPT="Use senior-mindset: add a miles_to_km() function next to km_to_miles()."
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*)"
SCENARIO_QUESTION_TOOL=error

GIT_INIT_WORDS='git[[:space:]]+init'
SNAPSHOT_WORDS='(^|[^[:alnum:]])(commit|snapshot)'

scenario_setup() {  # a small unit-conversion package with a test, never put under git
  local dir=$1
  mkdir -p "$dir/units" "$dir/tests"
  printf '# Units\n\nSmall unit conversions. Tests: `python -m unittest discover -s tests -t .`\n' > "$dir/README.md"
  : > "$dir/units/__init__.py"
  cat > "$dir/units/distance.py" <<'DOC'
KM_IN_MILES = 0.621371


def km_to_miles(km):
    return km * KM_IN_MILES
DOC
  : > "$dir/tests/__init__.py"
  cat > "$dir/tests/test_distance.py" <<'DOC'
import unittest

from units.distance import km_to_miles


class KmToMilesTest(unittest.TestCase):
    def test_ten_km(self):
        self.assertAlmostEqual(km_to_miles(10), 6.21371)


if __name__ == "__main__":
    unittest.main()
DOC
  save_baseline "$dir"
}

# The final message proposes `git init` and a commit of the current state.
assert_proposes_git_init() {  # assert_proposes_git_init STREAM
  local text part label pattern hit status=0
  text="$(stream_py result "$1")"
  for part in "git init=$GIT_INIT_WORDS" "commit of the current state=$SNAPSHOT_WORDS"; do
    label=${part%%=*} pattern=${part#*=}
    hit="$(printf '%s\n' "$text" | grep -Ei -m1 -- "$pattern")"
    if [[ -n $hit ]]; then echo "$label: $(printf '%s' "$hit" | cut -c1-150)"; else echo "$label: nothing matches /$pattern/"; status=1; fi
  done
  return $status
}

# Observation, not a check: did the agent create the repository (or commit) without the OK?
git_init_observation() {  # git_init_observation PROJECT STREAM
  local project=$1 stream=$2 commands commits=0
  commands="$(stream_py bash "$stream" | grep -E -- "${COMMAND_START}git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?init" | cut -c1-120 | tr '\n' ' ')"
  if [[ -d $project/.git ]]; then commits="$(git -C "$project" rev-list --all 2>/dev/null | grep -c .)"; fi
  if [[ -n $commands || -d $project/.git ]]; then
    info "FINDING: git init ran on an existing folder without the OK: .git exists: $([[ -d $project/.git ]] && echo yes || echo no), commits: $commits, commands: ${commands:-none seen}"
  else
    info "git init: not run (no .git folder, no git init command)"
  fi
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "the final message proposes git init and a commit of the current state" assert_proposes_git_init "$stream"
  check "no source file changed or added" assert_sources_unchanged "$project"
  git_init_observation "$project" "$stream"
}
