# Kickoff checklist and branch flow (PM-0003): a new project whose user approves the defaults must
# get the kickoff artifacts on a branch of its own, and nothing on master beyond what Step 0b allows
# (git init and a .gitignore). The 1.1.0 run skipped CHANGELOG.md and cliff.toml and committed the
# whole app at once on master.

SCENARIO_DESCRIPTION="an approved kickoff leaves its checklist artifacts on a branch, not on master"
SCENARIO_PROMPT="Start a tiny Python CLI project with senior-mindset: it prints a greeting for a name given as an argument. I approve the recommended defaults for every kickoff question, and this mission: a minimal command-line greeter for one developer, no server and no database."
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*),Bash(python:*),Bash(python3:*)"
SCENARIO_QUESTION_TOOL=error

scenario_setup() {  # an empty folder, not yet a repository: Step 0b runs git init
  :
}

assert_found() {  # assert_found PROJECT PATH_ERE [CONTENT_ERE]
  local hit
  if hit="$(find_file "$@")"; then echo "$hit"; else echo "no file matches /$2/${3:+ with /$3/}"; return 1; fi
}

assert_all_found() {  # assert_all_found PROJECT PATH_ERE...
  local project=$1 status=0 path_re
  shift
  for path_re in "$@"; do assert_found "$project" "$path_re" || status=1; done
  return $status
}

# Some branch other than the default holds the file (the kickoff is committed on its own branch).
assert_on_work_branch() {  # assert_on_work_branch PROJECT PATH_ERE
  local project=$1 branch found=""
  while IFS= read -r branch; do
    [[ $branch == master || $branch == main ]] && continue
    if git -C "$project" ls-tree -r --name-only "$branch" | grep -Eq -- "$2"; then found+="$branch "; fi
  done < <(git_branches "$project")
  if [[ -n $found ]]; then echo "on: $found"; else echo "no branch besides master/main holds /$2/ (branches: $(git_branches "$project" | tr '\n' ' '))"; return 1; fi
}

assert_default_branch_minimal() {  # at most one commit on master, holding at most .gitignore
  local project=$1 status=0 branch count
  for branch in master main; do
    git -C "$project" rev-parse --verify --quiet "refs/heads/$branch" >/dev/null 2>&1 || continue
    assert_branch_files_only "$project" "$branch" .gitignore || status=1
    count="$(git -C "$project" rev-list --count "$branch")"
    if [[ $count -gt 1 ]]; then echo "$branch has $count commits (Step 0b allows one)"; status=1; fi
  done
  return $status
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "conventions: AGENTS.md or CLAUDE.md with an Engineering conventions section" assert_found "$project" '^(AGENTS|CLAUDE)\.md$' 'Engineering conventions'
  check "the always-hold Git rules block is in the conventions" assert_found "$project" '^(AGENTS|CLAUDE)\.md$' 'Git rules that always hold'
  check ".gitignore exists" assert_found "$project" '^\.gitignore$'
  check "at least one ADR in spec/adr/ (Proposed or Accepted)" assert_found "$project" '^spec/adr/[0-9]{4}-.*\.md$'
  check "constitution: mission.md and tech-stack.md in spec/constitution/" assert_all_found "$project" '^spec/constitution/mission\.md$' '^spec/constitution/tech-stack\.md$'
  check "changelog setup: cliff.toml" assert_found "$project" '(^|/)cliff\.toml$'
  check "kickoff artifacts committed on a branch other than master" assert_on_work_branch "$project" '^(AGENTS|CLAUDE)\.md$'
  check "master holds one commit at most, with .gitignore only" assert_default_branch_minimal "$project"
}
