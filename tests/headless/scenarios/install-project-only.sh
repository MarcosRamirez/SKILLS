# Install check, project copy only (SPEC-0021 AC-3): the skill loads from the project's
# .claude/skills/ (no plugin in the run) and there is no global copy. Nothing to decide: "help"
# answers without any install or duplicate question, and nothing changes.

SCENARIO_DESCRIPTION="loaded only from the project copy: 'help' raises no install or duplicate question, changes nothing"
SCENARIO_PROMPT="help"
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*),Bash(ls:*),Bash(cat:*)"
SCENARIO_QUESTION_TOOL=error
SCENARIO_LOAD=project

scenario_setup() {
  local dir=$1
  existing_small_project "$dir"
  install_skill_in_project "$dir"
  commit_scratch "$dir" "Add the app and senior-mindset"
  save_baseline "$dir"
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "no install or duplicate question in the answer" assert_result_lacks "$stream" 'keep it global|install it in (this|the) project|disable the global|duplicate|two copies|global copy'
  check "nothing installed, disabled or uninstalled" assert_no_command "$stream" "$INSTALL_CHANGE_COMMAND"
  check "no file changed" assert_files_unchanged "$project"
  check "no commit added" assert_no_commit_added "$project"
}
