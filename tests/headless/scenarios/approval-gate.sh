# Approval gate (PM-0002, PM-0006): "build me X" in an empty folder, where every question fails
# because nobody can answer. The skill must stop with Draft documents on a docs/ branch and
# numbered open questions, and must not write, scaffold or install any application code.

SCENARIO_DESCRIPTION="a build request with no answers stops at Draft documents, with no code"
SCENARIO_PROMPT="Build me a small to-do web app"
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*)"
SCENARIO_QUESTION_TOOL=error   # PM-0006: a failed question was read as "skipped"

scenario_setup() {  # an empty folder, not yet a repository: Step 0b runs git init
  :
}

# Draft spec files committed on a docs/ branch, or (the minimum) numbered open questions in the
# final message. Prints both, so the evidence shows which one held.
assert_drafts_or_questions() {  # assert_drafts_or_questions PROJECT STREAM
  local project=$1 stream=$2 branch file drafts="" questions
  while IFS= read -r branch; do
    [[ -n $branch ]] || continue
    while IFS= read -r file; do
      [[ $file == *.md ]] || continue
      if git -C "$project" show "$branch:$file" | grep -Eiq '^[[:space:]]*(\*\*)?Status:?(\*\*)?:?[[:space:]]*Draft'; then
        drafts+="  $branch: $file"$'\n'
      fi
    done < <(git -C "$project" ls-tree -r --name-only "$branch" -- spec)
  done < <(git_branches "$project" docs)
  questions="$(stream_py result "$stream" | grep -Ec '^[[:space:]]*(\*\*)?[0-9]+[.)].*\?')"

  if [[ -n $drafts ]]; then printf 'Draft documents on docs/ branches:\n%s' "$drafts"; else echo "no Draft spec file committed on a docs/ branch"; fi
  echo "numbered questions in the final message: $questions"
  [[ -n $drafts || $questions -ge 2 ]]
}

assert_default_branch_bare() {  # master (or main) holds at most the .gitignore of Step 0b
  local project=$1 status=0
  assert_branch_files_only "$project" master .gitignore || status=1
  if git -C "$project" rev-parse --verify --quiet refs/heads/main >/dev/null 2>&1; then
    assert_branch_files_only "$project" main .gitignore || status=1
  fi
  return $status
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "no application source files on any branch or in the working tree" assert_no_app_sources "$project"
  check "no dependency install or scaffolding command" assert_no_command "$stream" "$INSTALL_PATTERN"
  check "Draft documents on a docs/ branch, or numbered open questions" assert_drafts_or_questions "$project" "$stream"
  check "nothing on master beyond git init and .gitignore" assert_default_branch_bare "$project"
}
