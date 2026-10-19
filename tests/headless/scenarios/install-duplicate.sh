# Install check, two copies (SPEC-0021 AC-3): the project has its own copy (.agents/skills and the
# .claude/skills bridge, committed) and the run also loads the suite's plugin, like a global
# install. Claude Code lists both. "help" still answers, and the final message names the duplicate
# and proposes disabling the global one for this project. Headless has no question tool, so no
# setting is written and nothing is uninstalled.

SCENARIO_DESCRIPTION="global plugin plus a project copy: 'help' names the duplicate and proposes disabling the global one, changes nothing"
SCENARIO_PROMPT="help"
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*),Bash(ls:*),Bash(cat:*)"
SCENARIO_QUESTION_TOOL=error

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
  check "the answer names the two copies" assert_result_matches "$stream" '[Tt]wo (copies|installs)|[Bb]oth|[Dd]uplicat|[Tt]wice|global (plugin|copy)'
  check "the answer proposes disabling the global one" assert_result_matches "$stream" '[Dd]isabl|[Tt]urn(ing)? (it )?off|[Ss]witch(ing)? (it )?off|[Dd]eactivat|[Dd]esactiv'
  check "nothing installed, disabled or uninstalled" assert_no_command "$stream" "$INSTALL_CHANGE_COMMAND"
  check "no file changed (no .claude/settings.local.json)" assert_files_unchanged "$project"
  check "no commit added" assert_no_commit_added "$project"
}
