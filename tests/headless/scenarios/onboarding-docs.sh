# Onboarding a documentation project (SPEC-0009 AC-2): a docs-only repository with its own patterns
# (spec-kit specs and constitution, an ADR folder without Status lines, a PRD, loose notes) and no
# conventions. Everything is approved in the prompt: the change notice for the assessment and the
# adoption spec, the spec itself and its migration. The run must leave spec/ASSESSMENT.md, an
# "adopt senior-mindset" spec whose mapping names every source file, the docs moved into the
# standard layout on a branch, nothing deleted on any branch, and master untouched.

SCENARIO_DESCRIPTION="onboarding a docs-only project: assessment, adoption spec with the mapping, migration with nothing deleted"
SCENARIO_PROMPT="Analyse this project and adopt senior-mindset. I approve in advance the change notice for the assessment and the adoption spec, the adoption spec itself and its migration. The mission is the vision in docs/prd.md, and no automations. There is no git remote: work on local branches, stop after the commits and summarise."
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*),Bash(ls:*),Bash(cat:*),Bash(grep:*),Bash(find:*),Bash(mkdir:*),Bash(head:*),Bash(wc:*),Bash(sed -n:*)"
SCENARIO_QUESTION_TOOL=error

# The source files and the marker the mapping must name for each (the three spec-kit files may
# share one row, so their folder is enough).
SOURCE_MARKERS=(
  ".specify/memory/constitution.md=constitution.md"
  "specs/001-team-calendar/spec.md=001-team-calendar"
  "specs/001-team-calendar/plan.md=001-team-calendar"
  "specs/001-team-calendar/tasks.md=001-team-calendar"
  "docs/decisions/0001-markdown-as-source.md=0001-markdown-as-source"
  "docs/prd.md=prd.md"
  "notes/ideas.md=ideas.md"
)

scenario_setup() {
  local dir=$1
  init_scratch_repo "$dir"
  keep_line_endings "$dir"
  mkdir -p "$dir/.specify/memory" "$dir/specs/001-team-calendar" "$dir/docs/decisions" "$dir/notes"
  printf '# Team handbook\n\nHow the team works. Specs live in specs/, decisions in docs/decisions/.\n' > "$dir/README.md"
  printf '# Constitution\n\n## Principles\n\n- Plain text first: everything is Markdown in git.\n- One owner per page.\n' > "$dir/.specify/memory/constitution.md"
  printf '# Feature Specification: Team calendar\n\n**Status**: Draft\n\n## User Scenarios\n\n- As a team lead I can see who is off this week.\n\n## Requirements\n\n- FR-001 Show absences per week.\n- FR-002 Absences are read from one Markdown file per person.\n' > "$dir/specs/001-team-calendar/spec.md"
  printf '# Implementation Plan: Team calendar\n\n## Technical Context\n\nA static page generated from the absence files.\n' > "$dir/specs/001-team-calendar/plan.md"
  printf '# Tasks: Team calendar\n\n- [ ] T001 Define the absence file format\n- [ ] T002 Weekly view\n' > "$dir/specs/001-team-calendar/tasks.md"
  printf '# 1. Markdown as the source of truth\n\nDate: 2026-05-02\n\n## Context\n\nThe team edits the handbook in their own editors.\n\n## Decision\n\nAll content is Markdown in git; no wiki.\n' > "$dir/docs/decisions/0001-markdown-as-source.md"
  printf '# Product requirements: Team handbook\n\n## Vision\n\nOne place where a small team finds how it works.\n\n## Features\n\n- Team calendar (specs/001-team-calendar)\n- Onboarding checklist for new members\n' > "$dir/docs/prd.md"
  printf '# Ideas\n\n- Reminders before someone is off\n- Dark mode for the handbook\n' > "$dir/notes/ideas.md"
  commit_scratch "$dir" "Add the team handbook"
  git -C "$dir" rev-parse master > "$dir/.git/baseline-master"
  save_baseline "$dir"
}

assert_found() {  # assert_found PROJECT LABEL PATH_ERE: a file matching PATH_ERE exists on some branch
  local hit
  if hit="$(find_file "$1" "$3")"; then echo "$2: $hit"; else echo "$2: no file matches /$3/ on any branch"; return 1; fi
}

assert_mapping_names_sources() {  # assert_mapping_names_sources PROJECT
  local project=$1 hit ref file text entry marker missing=""
  hit="$(find_file "$project" '^spec/features/[0-9]{4}-adopt[^/]*(/spec\.md|\.md)$')" || { echo "no adoption spec"; return 1; }
  ref=${hit%% *} file=${hit#* }
  text="$(file_at "$project" "$ref" "$file")"
  for entry in "${SOURCE_MARKERS[@]}"; do
    marker=${entry#*=}
    printf '%s\n' "$text" | grep -Fq -- "$marker" || missing+=" ${entry%%=*}"
  done
  if [[ -n $missing ]]; then echo "$file ($ref) does not name:$missing"; return 1; fi
  echo "$file ($ref) names all ${#SOURCE_MARKERS[@]} source files"
}

assert_docs_migrated() {  # assert_docs_migrated PROJECT: the ADR and the spec-kit feature are in the standard layout
  local project=$1 adr feature
  adr="$(find_file "$project" '^spec/adr/0001-[^/]*\.md$' 'Markdown')" || { echo "no spec/adr/0001-*.md with the decision"; return 1; }
  feature="$(find_file "$project" '^spec/features/[0-9]{4}-[^/]*calendar[^/]*(/spec\.md|\.md)$')" || { echo "no team-calendar spec under spec/features/"; return 1; }
  echo "ADR: $adr · feature: $feature"
}

assert_nothing_deleted() {  # assert_nothing_deleted PROJECT: no branch deletes a file of master (renames allowed)
  local project=$1 branch deleted found=0
  while IFS= read -r branch; do
    [[ -n $branch && $branch != master ]] || continue
    deleted="$(git -C "$project" diff -M --diff-filter=D --name-only master "$branch")"
    if [[ -n $deleted ]]; then echo "$branch deletes: $(printf '%s' "$deleted" | tr '\n' ' ')"; found=1; fi
  done < <(git_branches "$project")
  if [[ $found -eq 0 ]]; then echo "no branch deletes a file of master ($(git_branches "$project" | wc -l | tr -d ' ') branch(es))"; fi
  return $found
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "spec/ASSESSMENT.md written on a branch" assert_found "$project" assessment '^spec/ASSESSMENT\.md$'
  check "the adoption spec's mapping names every source file" assert_mapping_names_sources "$project"
  check "the ADR and the spec-kit feature moved into spec/" assert_docs_migrated "$project"
  check "nothing deleted on any branch (git diff -M --diff-filter=D)" assert_nothing_deleted "$project"
  check "master untouched" assert_master_untouched "$project"
}
