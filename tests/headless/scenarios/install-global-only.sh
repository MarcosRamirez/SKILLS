# Install check, global copy only (SPEC-0021 AC-3): the skill loads from a copy outside the project
# (the suite's plugin, like a global install) and the project has no copy. "help" still answers,
# and the final message names installing the skill in the project as a pending decision. Headless
# has no question tool, so nothing is installed and nothing is recorded.

SCENARIO_DESCRIPTION="loaded only from a global copy: 'help' names the project install as pending, changes nothing"
SCENARIO_PROMPT="help"
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*),Bash(ls:*),Bash(cat:*)"
SCENARIO_QUESTION_TOOL=error

scenario_setup() {
  local dir=$1
  existing_small_project "$dir"
  commit_scratch "$dir" "Add the app"
  save_baseline "$dir"
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "the answer names installing the skill in the project" assert_result_matches "$stream" '\.agents/skills|\.claude/skills|[Ii]nstall[^.]{0,60}(this|the) project|project (copy|install)'
  check "the answer leaves the decision to the user" assert_result_matches "$stream" '[Pp]ending|[Kk]eep it global|[Dd]ecid|[Aa]nswer|[Cc]hoose|[Qq]uestion|[Cc]onfirm'
  check "nothing installed, disabled or uninstalled" assert_no_command "$stream" "$INSTALL_CHANGE_COMMAND"
  check "no file changed (no project copy, no settings)" assert_files_unchanged "$project"
  check "no commit added" assert_no_commit_added "$project"
}
