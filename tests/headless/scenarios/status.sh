# Status (SPEC-0014 AC-3): "status" in a repository with a small spec tree (features and fixes in
# different states, roadmap rows, plans with tiers, a tag and an automation) gets every spec with
# the state its file says, the version and the tag, and the automation, and nothing is changed.
# The expected states are read from the scratch files at check time, so the check cross-references
# the answer with the files instead of with constants.

SCENARIO_DESCRIPTION="'status' lists the specs and plans with the states their files say, and changes nothing"
SCENARIO_PROMPT="status"
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*),Bash(ls:*),Bash(cat:*),Bash(grep:*),Bash(find:*),Bash(gh pr list:*),Bash(gh --version:*)"
SCENARIO_QUESTION_TOOL=error

# Spec files whose Status lines (and plans' Status lines) are cross-checked.
SPEC_FILES=(
  spec/features/0001-invoice-export/spec.md
  spec/features/0002-payment-reminders/spec.md
  spec/features/0003-tax-rates.md
  spec/features/0004-customer-portal/spec.md
  spec/fixes/0005-rounding-error.md
  spec/fixes/0006-duplicate-emails.md
)
WRITE_COMMAND="${COMMAND_START}(mkdir|touch|rm|mv|cp|tee|sed[[:space:]]+-i|git[[:space:]]+(init|add|commit|switch|checkout|branch|stash|merge|push|tag[[:space:]]+[^-]))([[:space:]\"]|\\\\n|\$)"

make_spec() {  # make_spec DIR PATH STATUS TYPE TITLE [PLAN_PATH PLAN_STATUS TIER]
  local dir=$1 path=$2 status=$3 type=$4 title=$5 plan_path=${6:-} plan_status=${7:-} tier=${8:-}
  local id
  id="$(echo "$path" | grep -Eo '/[0-9]{4}-' | head -1 | tr -d '/-')"
  mkdir -p "$dir/$(dirname "$path")"
  printf '# SPEC-%s: %s\n\nType: %s\nStatus: %s\nDate: 2026-09-01\n\n## Problem\n\n%s.\n' "$id" "$title" "$type" "$status" "$title" > "$dir/$path"
  if [[ -n $plan_path ]]; then
    printf '# PLAN-%s: %s\n\nSpec: [SPEC-%s](spec.md)\nStatus: %s\nRecommended overall: %s\n\n## Design\n\nTBD.\n' "$id" "$title" "$id" "$plan_status" "$tier" > "$dir/$plan_path"
  fi
}

scenario_setup() {
  local dir=$1
  init_scratch_repo "$dir"
  keep_line_endings "$dir"
  mkdir -p "$dir/spec/constitution" "$dir/.github/workflows"
  printf '[project]\nname = "billing"\nversion = "0.3.0"\n' > "$dir/pyproject.toml"
  cat > "$dir/AGENTS.md" <<'DOC'
# Billing

## Engineering conventions

- Language: Python 3. Default branch: master. Versioning: SemVer (pyproject.toml).
- Automations: docs-check
DOC
  printf 'name: checks\non: pull_request\njobs: {}\n' > "$dir/.github/workflows/checks.yml"
  make_spec "$dir" spec/features/0001-invoice-export/spec.md Implemented feature "Invoice export" spec/features/0001-invoice-export/plan.medium.md Done medium
  make_spec "$dir" spec/features/0002-payment-reminders/spec.md Approved feature "Payment reminders" spec/features/0002-payment-reminders/plan.high.md Ready high
  make_spec "$dir" spec/features/0003-tax-rates.md Draft feature "Tax rates per country"
  make_spec "$dir" spec/features/0004-customer-portal/spec.md Approved feature "Customer portal" spec/features/0004-customer-portal/plan.low.md "In progress" low
  make_spec "$dir" spec/fixes/0005-rounding-error.md Implemented fix "Rounding error in totals"
  make_spec "$dir" spec/fixes/0006-duplicate-emails.md Draft fix "Duplicate reminder emails"
  cat > "$dir/spec/constitution/roadmap.md" <<'DOC'
# Roadmap

| Spec | Title | Tier | Status | Depends on |
|---|---|---|---|---|
| SPEC-0001 | Invoice export | medium | Implemented | — |
| SPEC-0005 | Rounding error in totals | low | Implemented | SPEC-0001 |
| SPEC-0002 | Payment reminders | high | Approved | SPEC-0001 |
| SPEC-0004 | Customer portal | low | Approved | SPEC-0001 |
| SPEC-0003 | Tax rates per country | medium | Draft | SPEC-0002 |
| SPEC-0006 | Duplicate reminder emails | low | Draft | SPEC-0002 |
DOC
  commit_scratch "$dir" "Add the billing specs"
  scratch_git "$dir" tag -a v0.2.0 -m "billing 0.2.0"
  printf '[project]\nname = "billing"\nversion = "0.3.0"\n# bumped\n' > "$dir/pyproject.toml"
  commit_scratch "$dir" "Prepare 0.3.0"
  save_baseline "$dir"
}

status_of() {  # status_of FILE: the first Status: line's value
  tr -d '\r' < "$1" | sed -n 's/^Status:[[:space:]]*//p' | head -1
}

spec_id_of() {  # spec_id_of PATH -> the four digits after the last folder slash
  echo "$1" | grep -Eo '/[0-9]{4}-' | head -1 | tr -d '/-'
}

plan_of() {  # plan_of PROJECT SPEC_FILE -> the plan.<tier>.md next to a folder spec, if any
  ls "$(dirname "$1/$2")"/plan.*.md 2>/dev/null | head -1
}

# The lines of the answer about one spec: the line that names it plus the lines after it until the
# next line that names another spec (a table row is one line, a bullet list is a few).
block_of() {  # block_of TEXT ID
  printf '%s\n' "$1" | awk -v id="$2" '
    { if (match($0, /(^|[^0-9])00[0-9][0-9]([^0-9]|$)/)) { current = (index($0, id) > 0) ? 1 : 0 } }
    current { print }'
}

assert_states_match_files() {  # assert_states_match_files PROJECT STREAM
  local project=$1 text file id title state plan plan_state="" tier="" block missing failed=0
  text="$(stream_py result "$2")"
  for file in "${SPEC_FILES[@]}"; do
    id="$(spec_id_of "$file")"
    title="$(tr -d '\r' < "$project/$file" | sed -n '1s/^# SPEC-[0-9]*: //p')"
    state="$(status_of "$project/$file")"
    block="$(block_of "$text" "$id")"
    plan="$(plan_of "$project" "$file")"
    plan_state="" tier=""
    if [[ -n $plan ]]; then
      plan_state="$(status_of "$plan")"
      tier="$(basename "$plan" | sed 's/^plan\.\(.*\)\.md$/\1/')"
    fi
    missing=""
    if [[ -z $block ]]; then
      missing=" the spec is not named at all"
    else
      printf '%s\n' "$block" | grep -Fiq -- "$state" || missing+=" spec state '$state'"
      if [[ -n $plan ]]; then
        printf '%s\n' "$block" | grep -Fiq -- "$plan_state" || missing+=" plan state '$plan_state'"
        printf '%s\n' "$block" | grep -Fiq -- "$tier" || missing+=" tier '$tier'"
      fi
    fi
    if [[ -n $missing ]]; then
      echo "SPEC-$id ($title): missing$missing"; failed=1
    else
      echo "SPEC-$id ($title): $state${plan:+, plan $plan_state ($tier)}"
    fi
  done
  return $failed
}

# The first line of a spec's block must not carry a spec state that neither its spec nor its plan has.
assert_no_wrong_states() {  # assert_no_wrong_states PROJECT STREAM
  local project=$1 text file id state plan plan_state first other failed=0
  text="$(stream_py result "$2")"
  for file in "${SPEC_FILES[@]}"; do
    id="$(spec_id_of "$file")"
    state="$(status_of "$project/$file")"
    plan="$(plan_of "$project" "$file")"
    plan_state=""
    if [[ -n $plan ]]; then plan_state="$(status_of "$plan")"; fi
    first="$(block_of "$text" "$id" | head -1)"
    for other in Draft Approved Implemented; do
      if [[ $other == "$state" || $other == "$plan_state" ]]; then continue; fi
      if printf '%s\n' "$first" | grep -Eiq -- "(^|[^[:alnum:]])$other([^[:alnum:]]|$)"; then
        echo "SPEC-$id is $state${plan_state:+ (plan $plan_state)}, but its row says $other: $(printf '%s' "$first" | cut -c1-150)"
        failed=1
      fi
    done
  done
  if [[ $failed -eq 0 ]]; then echo "no row names a state that its files do not have"; fi
  return $failed
}

assert_mentions() {  # assert_mentions STREAM LABEL ERE
  local hit
  hit="$(stream_py result "$1" | grep -Ei -m1 -- "$3")"
  if [[ -n $hit ]]; then echo "$2: $(printf '%s' "$hit" | cut -c1-150)"; else echo "$2: nothing matches /$3/"; return 1; fi
}

assert_no_question_calls() {  # assert_no_question_calls STREAM
  local calls
  calls="$(question_calls "$1" | grep -c .)"
  echo "question tool calls: $calls"
  [[ $calls -eq 0 ]]
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "every spec and plan is named with the state, plan state and tier of its file" assert_states_match_files "$project" "$stream"
  check "no spec row carries a state that its files do not have" assert_no_wrong_states "$project" "$stream"
  check "the current version (0.3.0) is named" assert_mentions "$stream" version '0\.3\.0'
  check "the last tag (v0.2.0) is named" assert_mentions "$stream" tag 'v0\.2\.0'
  check "the installed automation (docs-check / checks.yml) is named" assert_mentions "$stream" automation 'docs-check|checks\.yml'
  check "pull requests are covered (listed, or said to be unreadable)" assert_mentions "$stream" "pull requests" 'pull request|(^|[^[:alnum:]])(PRs?|gh)([^[:alnum:]]|$)'
  check "no write command, no commit, no branch, no tag" assert_no_command "$stream" "$WRITE_COMMAND"
  check "no question tool call (no kickoff)" assert_no_question_calls "$stream"
  check "no file changed (working tree as before)" assert_files_unchanged "$project"
  check "no commit added (refs and commits as before)" assert_no_commit_added "$project"
  check "git status as before" assert_status_unchanged "$project"
  check "no branch tree changed" assert_branch_trees_unchanged "$project"
}
