#!/usr/bin/env bash
# Tests for skills/senior-mindset/templates/release-automation/close-specs.sh and for the id
# extraction of .github/workflows/on-merge.yml (SPEC-0022, SPEC-0029).
#   AC-2  close-specs.sh closes fixes as well as features
#   AC-3  the workflow's id extraction sees specs in spec/fixes/, and falls back to "specs"
#         when the changed files name no spec (pipefail, PM-0009)
#
# Usage: bash tests/ci/test-close-specs.sh [path/to/close-specs.sh] [path/to/on-merge.yml]
# Defaults to the files of the checkout this script lives in. Every case builds its own throwaway
# git repository in a temp folder that is removed at exit, so nothing else is touched.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SCRIPT_SRC="$(realpath "${1:-$REPO/skills/senior-mindset/templates/release-automation/close-specs.sh}")"
WORKFLOW_SRC="$(realpath "${2:-$REPO/.github/workflows/on-merge.yml}")"
WORK="$(mktemp -d)"
trap 'cd "$HERE" && rm -rf "$WORK"' EXIT
PR=99
TODAY="$(date -u +%Y-%m-%d)"

pass=0
fail=0
RC=0
OUT=""
ERR=""

# ---------------------------------------------------------------- assertions
ok() { pass=$((pass + 1)); printf '  PASS  %s\n' "$1"; }
bad() {
  fail=$((fail + 1))
  printf '  FAIL  %s\n' "$1"
  shift
  local line
  for line in "$@"; do printf '          %s\n' "$line"; done
}
section() { printf '\n== %s\n' "$1"; }
eq() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1" "expected: $2" "actual:   $3"; fi; }
has() { if grep -qE -- "$3" <<<"$2"; then ok "$1"; else bad "$1" "pattern: $3" "text:    $2"; fi; }
count() { grep -cE -- "$1" "$2" || true; }                      # lines of file $2 matching regex $1
numstat() { git diff --numstat -- "$1" | awk '{print $1 " " $2}'; }   # "<added> <removed>" for one file
changed() { { git diff --name-only; git ls-files --others --exclude-standard; } | LC_ALL=C sort; }
sorted() { printf '%s\n' "$@" | LC_ALL=C sort; }
# What the script printed, sorted, once per file (with several specs in one PR it prints the roadmap
# once per spec, as it always did; `git add` and the workflow's `sort -u` cope with that).
printed() { printf '%s\n' "$OUT" | sed '/^$/d' | LC_ALL=C sort -u; }

expect_changed() { # expect_changed <description> <file>...   the working tree changed in exactly these files
  local desc="$1"
  shift
  eq "$desc" "$(sorted "$@")" "$(changed)"
}
expect_untouched() { eq "$1" "" "$(changed)"; }
expect_prints_what_changed() { eq "prints the files it changed, nothing else" "$(changed)" "$(printed)"; }

# ---------------------------------------------------------------- fixtures
new_repo() { # new_repo <case>: a fresh repository with the script installed as an app would
  local dir="$WORK/$1"
  rm -rf "$dir"
  mkdir -p "$dir/.github/scripts"
  cd "$dir" || exit 2
  git init -q -b master
  git config user.name scratch
  git config user.email scratch@example.invalid
  git config core.autocrlf false
  git config core.filemode false
  git config commit.gpgsign false
  cp "$SCRIPT_SRC" .github/scripts/close-specs.sh
}
commit_fixture() { git add -A && git commit -q -m fixture; }

single_spec() { # single_spec <path> <id> <type> <status>
  mkdir -p "$(dirname "$1")"
  cat >"$1" <<EOF
# SPEC-$2: a $3 spec

Type: $3
Status: $4
Date: 2026-10-13
Approved by: the user, 2026-10-13, "go"
Plan: low — Claude Haiku 5.5 (small)

## Spec
Body of the spec.

## Plan
### Steps
- T-1 do it

## Tasks
- [ ] T-1 do it (AC-1)
EOF
}

folder_spec() { # folder_spec <dir> <id> <type> <status> [<plan file> [<plan status>]]
  mkdir -p "$1"
  cat >"$1/spec.md" <<EOF
# SPEC-$2: a $3 spec

Type: $3
Status: $4
Date: 2026-10-13
Approved by: the user, 2026-10-13, "go"

## Problem
Body of the spec.
EOF
  printf '# SPEC-%s tasks\n\n- [ ] T-1 do it (AC-1)\n' "$2" >"$1/tasks.md"
  if [ -n "${5:-}" ]; then
    cat >"$1/$5" <<EOF
# PLAN-$2: a plan

Spec: [SPEC-$2](spec.md)
Status: ${6:-In progress}
Recommended overall: medium — Claude Sonnet 5.5

## Design
Body of the plan.
EOF
  fi
}

roadmap() { # roadmap <"id|title|tier|status|deps">...
  mkdir -p spec/constitution
  {
    printf '# Roadmap\n\nIntro line.\n\n'
    printf '| Spec | Title | Tier | Status | Depends on |\n|---|---|---|---|---|\n'
    local row id title tier status deps
    for row in "$@"; do
      IFS='|' read -r id title tier status deps <<<"$row"
      printf '| SPEC-%s | %s | %s | %s | %s |\n' "$id" "$title" "$tier" "$status" "$deps"
    done
  } >spec/constitution/roadmap.md
}

run() { # run <PR_BODY> [VAR=value ...]: the script as the workflow runs it, from the repo root
  local body="$1"
  shift
  OUT="$(env -u SPEC_DIRS -u FEATURES_DIR -u ROADMAP PR_NUMBER="$PR" PR_BODY="$body" "$@" \
    bash .github/scripts/close-specs.sh 2>"$WORK/.stderr")"
  RC=$?
  ERR="$(cat "$WORK/.stderr")"
  printf '  $ %sPR_BODY=%q bash .github/scripts/close-specs.sh   -> exit %s\n' "${*:+$* }" "$body" "$RC"
}

# ---------------------------------------------------------------- AC-2a
case_2a() {
  section "AC-2a  a single-file fix closes: spec/fixes/NNNN-x.md"
  new_repo 2a-single-file-fix
  folder_spec spec/features/0007-rate-limit 0007 feature Approved plan.medium.md "In progress"
  single_spec spec/fixes/0023-bump-rule.md 0023 fix Approved
  roadmap "0007|A feature|medium|Approved|—" "0023|A fix|low|Approved|SPEC-0007"
  commit_fixture
  run 'Closes-Spec: SPEC-0023'
  eq "exit code" 0 "$RC"
  eq "stderr is empty" "" "$ERR"
  expect_changed "changes the fix and the roadmap only" spec/fixes/0023-bump-rule.md spec/constitution/roadmap.md
  expect_prints_what_changed
  eq "fix has 'Status: Implemented'" 1 "$(count '^Status: Implemented$' spec/fixes/0023-bump-rule.md)"
  eq "fix has 'Implemented: <today>, PR #$PR'" 1 "$(count "^Implemented: $TODAY, PR #$PR\$" spec/fixes/0023-bump-rule.md)"
  eq "fix keeps no 'Status: Approved'" 0 "$(count '^Status: Approved$' spec/fixes/0023-bump-rule.md)"
  eq "fix diff is the status change only (+2 -1)" "2 1" "$(numstat spec/fixes/0023-bump-rule.md)"
  eq "fix keeps its 'Type: fix' header" 1 "$(count '^Type: fix$' spec/fixes/0023-bump-rule.md)"
  eq "roadmap row SPEC-0023 is Implemented" 1 "$(count '^\| SPEC-0023 \|.*\| Implemented \|' spec/constitution/roadmap.md)"
  eq "roadmap row SPEC-0007 is untouched (Approved)" 1 "$(count '^\| SPEC-0007 \|.*\| Approved \|' spec/constitution/roadmap.md)"
  eq "roadmap diff is one line (+1 -1)" "1 1" "$(numstat spec/constitution/roadmap.md)"
}

# ---------------------------------------------------------------- AC-2b
case_2b() {
  section "AC-2b  a fix in a folder closes, and so does its plan: spec/fixes/NNNN-x/"
  new_repo 2b-folder-fix
  folder_spec spec/fixes/0024-null-total 0024 fix Approved plan.low.md "In progress"
  roadmap "0024|A folder fix|low|Approved|—"
  commit_fixture
  run 'Closes-Spec: SPEC-0024'
  eq "exit code" 0 "$RC"
  eq "stderr is empty" "" "$ERR"
  expect_changed "changes spec, plan and roadmap (tasks.md untouched)" \
    spec/fixes/0024-null-total/spec.md spec/fixes/0024-null-total/plan.low.md spec/constitution/roadmap.md
  expect_prints_what_changed
  eq "spec has 'Status: Implemented'" 1 "$(count '^Status: Implemented$' spec/fixes/0024-null-total/spec.md)"
  eq "spec has 'Implemented: <today>, PR #$PR'" 1 "$(count "^Implemented: $TODAY, PR #$PR\$" spec/fixes/0024-null-total/spec.md)"
  eq "plan has 'Status: Done'" 1 "$(count '^Status: Done$' spec/fixes/0024-null-total/plan.low.md)"
  eq "plan has 'Done: <today>, PR #$PR'" 1 "$(count "^Done: $TODAY, PR #$PR\$" spec/fixes/0024-null-total/plan.low.md)"
  eq "spec diff is +2 -1" "2 1" "$(numstat spec/fixes/0024-null-total/spec.md)"
  eq "plan diff is +2 -1" "2 1" "$(numstat spec/fixes/0024-null-total/plan.low.md)"
  eq "roadmap row SPEC-0024 is Implemented" 1 "$(count '^\| SPEC-0024 \|.*\| Implemented \|' spec/constitution/roadmap.md)"

  printf '\n-- b2: a fix in a folder that has no plan file yet\n'
  new_repo 2b2-folder-fix-no-plan
  folder_spec spec/fixes/0025-no-plan 0025 fix Approved
  roadmap "0025|A folder fix without plan|low|Approved|—"
  commit_fixture
  run 'Closes-Spec: SPEC-0025'
  eq "exit code" 0 "$RC"
  expect_changed "changes spec and roadmap" spec/fixes/0025-no-plan/spec.md spec/constitution/roadmap.md
  eq "spec has 'Status: Implemented'" 1 "$(count '^Status: Implemented$' spec/fixes/0025-no-plan/spec.md)"
}

# ---------------------------------------------------------------- AC-2c
case_2c() {
  section "AC-2c  existing feature cases still pass"

  printf '\n-- c1: a feature in a folder with a plan\n'
  new_repo 2c1-folder-feature
  folder_spec spec/features/0007-rate-limit 0007 feature Approved plan.medium.md "In progress"
  roadmap "0007|A feature|medium|Approved|—"
  commit_fixture
  run 'Closes-Spec: SPEC-0007'
  eq "exit code" 0 "$RC"
  expect_changed "changes spec, plan and roadmap" \
    spec/features/0007-rate-limit/spec.md spec/features/0007-rate-limit/plan.medium.md spec/constitution/roadmap.md
  expect_prints_what_changed
  eq "spec is Implemented with date and PR" 2 "$(grep -cE "^(Status: Implemented|Implemented: $TODAY, PR #$PR)\$" spec/features/0007-rate-limit/spec.md)"
  eq "plan is Done with date and PR" 2 "$(grep -cE "^(Status: Done|Done: $TODAY, PR #$PR)\$" spec/features/0007-rate-limit/plan.medium.md)"
  eq "roadmap row is Implemented" 1 "$(count '^\| SPEC-0007 \|.*\| Implemented \|' spec/constitution/roadmap.md)"

  printf '\n-- c2: a single-file feature\n'
  new_repo 2c2-single-feature
  single_spec spec/features/0008-small-thing.md 0008 feature Approved
  roadmap "0008|A small feature|low|Approved|—"
  commit_fixture
  run 'Closes-Spec: SPEC-0008'
  eq "exit code" 0 "$RC"
  expect_changed "changes the spec and the roadmap" spec/features/0008-small-thing.md spec/constitution/roadmap.md
  expect_prints_what_changed
  eq "spec is Implemented with date and PR" 2 "$(grep -cE "^(Status: Implemented|Implemented: $TODAY, PR #$PR)\$" spec/features/0008-small-thing.md)"
  eq "roadmap row is Implemented" 1 "$(count '^\| SPEC-0008 \|.*\| Implemented \|' spec/constitution/roadmap.md)"

  printf '\n-- c3: a feature whose plan is the legacy plan.md\n'
  new_repo 2c3-legacy-plan
  folder_spec spec/features/0009-legacy 0009 feature Approved plan.md "In progress"
  commit_fixture
  run 'Closes-Spec: SPEC-0009'
  eq "exit code" 0 "$RC"
  expect_changed "changes spec and plan (no roadmap exists)" spec/features/0009-legacy/spec.md spec/features/0009-legacy/plan.md
  eq "plan.md is Done" 1 "$(count '^Status: Done$' spec/features/0009-legacy/plan.md)"
}

# ---------------------------------------------------------------- AC-2d
case_2d() {
  section "AC-2d  the same number in spec/features and spec/fixes fails and changes nothing"

  printf '\n-- d1: feature folder + fix single file\n'
  new_repo 2d1-collision
  folder_spec spec/features/0010-a-feature 0010 feature Approved plan.low.md "In progress"
  single_spec spec/fixes/0010-a-fix.md 0010 fix Approved
  roadmap "0010|Clashing number|low|Approved|—"
  commit_fixture
  run 'Closes-Spec: SPEC-0010'
  eq "exit code is 1" 1 "$RC"
  eq "stdout is empty (nothing was changed)" "" "$OUT"
  has "error names the spec id" "$ERR" '^error: .*SPEC-0010'
  has "error says nothing changed" "$ERR" 'nothing changed'
  has "error names the feature" "$ERR" 'spec/features/0010-a-feature/spec\.md'
  has "error names the fix" "$ERR" 'spec/fixes/0010-a-fix\.md'
  expect_untouched "working tree is untouched (git status / diff empty)"
  eq "git diff is empty" "" "$(git diff)"

  printf '\n-- d2: feature folder + fix folder\n'
  new_repo 2d2-collision-folders
  folder_spec spec/features/0011-x 0011 feature Approved plan.low.md "In progress"
  folder_spec spec/fixes/0011-y 0011 fix Approved plan.low.md "In progress"
  roadmap "0011|Clashing number|low|Approved|—"
  commit_fixture
  run 'Closes-Spec: SPEC-0011'
  eq "exit code is 1" 1 "$RC"
  has "error names both folders" "$ERR" 'spec/features/0011-x/spec\.md'
  has "error names the fix folder" "$ERR" 'spec/fixes/0011-y/spec\.md'
  expect_untouched "working tree is untouched"

  printf '\n-- d3: folder + single file with the same number in ONE directory (existing rule)\n'
  new_repo 2d3-collision-same-dir
  folder_spec spec/features/0012-x 0012 feature Approved plan.low.md "In progress"
  single_spec spec/features/0012-y.md 0012 feature Approved
  commit_fixture
  run 'Closes-Spec: SPEC-0012'
  eq "exit code is 1" 1 "$RC"
  has "error says nothing changed" "$ERR" 'nothing changed'
  expect_untouched "working tree is untouched"
}

# ---------------------------------------------------------------- AC-2e
case_2e() {
  section "AC-2e  FEATURES_DIR=spec/features still works and ignores spec/fixes"
  mk() { # the fixture shared by e1, e2 and e4
    new_repo "$1"
    folder_spec spec/features/0007-rate-limit 0007 feature Approved plan.medium.md "In progress"
    single_spec spec/fixes/0023-bump-rule.md 0023 fix Approved
    roadmap "0007|A feature|medium|Approved|—" "0023|A fix|low|Approved|—"
    commit_fixture
  }

  printf '\n-- e1: FEATURES_DIR=spec/features closes the feature and leaves the fix alone\n'
  mk 2e1-features-dir
  run 'Closes-Spec: SPEC-0007' FEATURES_DIR=spec/features
  eq "exit code" 0 "$RC"
  expect_changed "changes the feature, its plan and its roadmap row" \
    spec/features/0007-rate-limit/spec.md spec/features/0007-rate-limit/plan.medium.md spec/constitution/roadmap.md
  eq "fix 0023 is still Approved" 1 "$(count '^Status: Approved$' spec/fixes/0023-bump-rule.md)"
  eq "roadmap row SPEC-0023 is still Approved" 1 "$(count '^\| SPEC-0023 \|.*\| Approved \|' spec/constitution/roadmap.md)"

  printf '\n-- e2: FEATURES_DIR=spec/features does not look in spec/fixes\n'
  mk 2e2-features-dir-ignores-fixes
  run 'Closes-Spec: SPEC-0023' FEATURES_DIR=spec/features
  eq "exit code is 1" 1 "$RC"
  has "error says no spec was found, in spec/features" "$ERR" '^error: .*SPEC-0023.*spec/features'
  has "error says nothing changed" "$ERR" 'nothing changed'
  expect_untouched "working tree is untouched"

  printf '\n-- e3: FEATURES_DIR can be any one folder, even with a space in its path\n'
  new_repo 2e3-features-dir-custom
  single_spec "my specs/0002-spaced.md" 0002 feature Approved
  single_spec "docs/specs/0001-old.md" 0001 feature Approved
  commit_fixture
  run 'Closes-Spec: SPEC-0002' FEATURES_DIR="my specs"
  eq "exit code (folder with a space)" 0 "$RC"
  expect_changed "changes the spec in 'my specs/'" "my specs/0002-spaced.md"
  commit_fixture
  run 'Closes-Spec: SPEC-0001' FEATURES_DIR=docs/specs
  eq "exit code (docs/specs)" 0 "$RC"
  expect_changed "changes the spec in docs/specs/" docs/specs/0001-old.md

  printf '\n-- e4: FEATURES_DIR wins over SPEC_DIRS when both are set\n'
  mk 2e4-features-dir-wins
  run 'Closes-Spec: SPEC-0007' FEATURES_DIR=spec/features SPEC_DIRS=spec/fixes
  eq "feature id closes (FEATURES_DIR used)" 0 "$RC"
  git checkout -q -- . && git clean -q -fd
  run 'Closes-Spec: SPEC-0023' FEATURES_DIR=spec/features SPEC_DIRS=spec/fixes
  eq "fix id is not found (SPEC_DIRS ignored)" 1 "$RC"
  expect_untouched "working tree is untouched"

  printf '\n-- e5: SPEC_DIRS picks the folders to look in\n'
  mk 2e5-spec-dirs
  run 'Closes-Spec: SPEC-0023' SPEC_DIRS=spec/fixes
  eq "SPEC_DIRS=spec/fixes closes the fix" 0 "$RC"
  expect_changed "changes the fix and the roadmap only" spec/fixes/0023-bump-rule.md spec/constitution/roadmap.md
  git checkout -q -- . && git clean -q -fd
  run 'Closes-Spec: SPEC-0007' SPEC_DIRS=spec/fixes
  eq "SPEC_DIRS=spec/fixes does not look in spec/features" 1 "$RC"
  expect_untouched "working tree is untouched"
  run 'Closes-Spec: SPEC-0023' SPEC_DIRS="spec/features spec/fixes docs/not-there"
  eq "a list with a folder that does not exist is fine" 0 "$RC"
  git checkout -q -- . && git clean -q -fd
  run 'Closes-Spec: SPEC-0023' SPEC_DIRS=" "
  eq "SPEC_DIRS with no folder at all is an error" 1 "$RC"
  has "error mentions SPEC_DIRS" "$ERR" 'SPEC_DIRS'
  expect_untouched "working tree is untouched"
}

# ---------------------------------------------------------------- AC-2f
case_2f() {
  section "AC-2f  no spec/fixes directory at all: closing features still works"

  new_repo 2f1-no-fixes-dir
  folder_spec spec/features/0007-rate-limit 0007 feature Approved plan.medium.md "In progress"
  roadmap "0007|A feature|medium|Approved|—"
  commit_fixture
  eq "spec/fixes does not exist in the fixture" "no" "$([ -e spec/fixes ] && echo yes || echo no)"
  run 'Closes-Spec: SPEC-0007'
  eq "exit code" 0 "$RC"
  eq "stderr is empty (a missing spec/fixes is not an error)" "" "$ERR"
  expect_changed "changes spec, plan and roadmap" \
    spec/features/0007-rate-limit/spec.md spec/features/0007-rate-limit/plan.medium.md spec/constitution/roadmap.md

  printf '\n-- f2: a number that exists nowhere, with no spec/fixes\n'
  new_repo 2f2-unknown-number
  folder_spec spec/features/0007-rate-limit 0007 feature Approved plan.medium.md "In progress"
  commit_fixture
  run 'Closes-Spec: SPEC-0099'
  eq "exit code is 1" 1 "$RC"
  has "error names SPEC-0099 and says nothing changed" "$ERR" '^error: .*SPEC-0099.*nothing changed'
  expect_untouched "working tree is untouched"

  printf '\n-- f3: only spec/fixes exists (no spec/features)\n'
  new_repo 2f3-no-features-dir
  single_spec spec/fixes/0023-bump-rule.md 0023 fix Approved
  commit_fixture
  run 'Closes-Spec: SPEC-0023'
  eq "exit code" 0 "$RC"
  expect_changed "changes the fix" spec/fixes/0023-bump-rule.md
}

# ---------------------------------------------------------------- one PR, two types
case_pr_two_types() {
  section "extra  one PR closes a feature and a fix"
  mk() {
    new_repo "$1"
    folder_spec spec/features/0007-rate-limit 0007 feature Approved plan.medium.md "In progress"
    single_spec spec/fixes/0023-bump-rule.md 0023 fix Approved
    roadmap "0007|A feature|medium|Approved|—" "0023|A fix|low|Approved|—"
    commit_fixture
  }
  mk x1-two-ids-comma
  run 'Closes-Spec: SPEC-0007, SPEC-0023'
  eq "exit code (comma list)" 0 "$RC"
  expect_changed "changes both specs, the plan and the roadmap" \
    spec/features/0007-rate-limit/spec.md spec/features/0007-rate-limit/plan.medium.md \
    spec/fixes/0023-bump-rule.md spec/constitution/roadmap.md
  expect_prints_what_changed
  eq "roadmap shows both Implemented" 2 "$(count '^\| SPEC-(0007|0023) \|.*\| Implemented \|' spec/constitution/roadmap.md)"
  mk x2-two-lines
  run $'Closes-Spec: SPEC-0007\r\nCloses-Spec: SPEC-0023\r\n'
  eq "exit code (two CRLF lines)" 0 "$RC"
  eq "both rows Implemented" 2 "$(count '^\| SPEC-(0007|0023) \|.*\| Implemented \|' spec/constitution/roadmap.md)"
}

# ---------------------------------------------------------------- regressions
case_regressions() {
  section "extra  guards that existed before keep working (run on fix specs)"

  printf '\n-- r1: idempotent (a closed fix is not touched again)\n'
  new_repo r1-idempotent
  single_spec spec/fixes/0023-bump-rule.md 0023 fix Approved
  roadmap "0023|A fix|low|Approved|—"
  commit_fixture
  run 'Closes-Spec: SPEC-0023'
  commit_fixture
  run 'Closes-Spec: SPEC-0023'
  eq "second run exits 0" 0 "$RC"
  eq "second run prints no file" "" "$OUT"
  has "second run says it is already Implemented" "$ERR" 'already Implemented'
  expect_untouched "second run changes nothing"

  printf '\n-- r2: a Draft fix cannot be closed\n'
  new_repo r2-not-approved
  single_spec spec/fixes/0023-bump-rule.md 0023 fix Draft
  commit_fixture
  run 'Closes-Spec: SPEC-0023'
  eq "exit code is 1" 1 "$RC"
  has "error says it is not Approved" "$ERR" 'not Approved'
  expect_untouched "working tree is untouched"

  printf '\n-- r3: a spec without a Status line\n'
  new_repo r3-no-status
  single_spec spec/fixes/0023-bump-rule.md 0023 fix Approved
  grep -v '^Status:' spec/fixes/0023-bump-rule.md >spec/fixes/tmp && mv spec/fixes/tmp spec/fixes/0023-bump-rule.md
  commit_fixture
  run 'Closes-Spec: SPEC-0023'
  eq "exit code is 1" 1 "$RC"
  has "error names the missing Status line" "$ERR" "no 'Status:' line"
  expect_untouched "working tree is untouched"

  printf '\n-- r4: two plans in a fix folder, and a plan without Status\n'
  new_repo r4-two-plans
  folder_spec spec/fixes/0024-null-total 0024 fix Approved plan.low.md "In progress"
  cp spec/fixes/0024-null-total/plan.low.md spec/fixes/0024-null-total/plan.medium.md
  commit_fixture
  run 'Closes-Spec: SPEC-0024'
  eq "two plans: exit code is 1" 1 "$RC"
  has "two plans: error says more than one plan" "$ERR" 'more than one plan'
  expect_untouched "two plans: working tree is untouched"
  new_repo r4b-plan-without-status
  folder_spec spec/fixes/0024-null-total 0024 fix Approved plan.low.md "In progress"
  printf '# PLAN-0024: no status here\n' >spec/fixes/0024-null-total/plan.low.md
  commit_fixture
  run 'Closes-Spec: SPEC-0024'
  eq "plan without Status: exit code is 1" 1 "$RC"
  expect_untouched "plan without Status: working tree is untouched"

  printf '\n-- r5: invalid ids never reach the file system\n'
  new_repo r5-injection
  single_spec spec/fixes/0023-bump-rule.md 0023 fix Approved
  commit_fixture
  run 'Closes-Spec: SPEC-0023; touch pwned'
  eq "id with a command: exit code is 1" 1 "$RC"
  run 'Closes-Spec: SPEC-1'
  eq "short id: exit code is 1" 1 "$RC"
  run 'Closes-Spec: SPEC-*'
  eq "glob in id: exit code is 1" 1 "$RC"
  run 'Closes-Spec: ../../etc/passwd'
  eq "path in id: exit code is 1" 1 "$RC"
  eq "no 'pwned' file was created" "no" "$([ -e pwned ] && echo yes || echo no)"
  expect_untouched "working tree is untouched"

  printf '\n-- r6: no Closes-Spec line, no roadmap, bad PR_NUMBER\n'
  new_repo r6-misc
  single_spec spec/fixes/0023-bump-rule.md 0023 fix Approved
  commit_fixture
  run 'just a normal PR body'
  eq "no Closes-Spec line: exit code 0" 0 "$RC"
  has "no Closes-Spec line: says nothing to close" "$ERR" 'nothing to close'
  expect_untouched "no Closes-Spec line: working tree is untouched"
  run 'Closes-Spec: SPEC-0023'
  eq "no roadmap file: exit code 0" 0 "$RC"
  expect_changed "no roadmap file: only the fix changed" spec/fixes/0023-bump-rule.md
  git checkout -q -- .
  OUT="$(env -u SPEC_DIRS -u FEATURES_DIR PR_NUMBER='9; touch pwned' PR_BODY='Closes-Spec: SPEC-0023' bash .github/scripts/close-specs.sh 2>"$WORK/.stderr")"
  RC=$?
  ERR="$(cat "$WORK/.stderr")"
  printf '  $ PR_NUMBER=%q PR_BODY=... bash .github/scripts/close-specs.sh   -> exit %s\n' '9; touch pwned' "$RC"
  eq "non-numeric PR_NUMBER: exit code is 1" 1 "$RC"
  eq "non-numeric PR_NUMBER: no 'pwned' file was created" "no" "$([ -e pwned ] && echo yes || echo no)"
  expect_untouched "non-numeric PR_NUMBER: working tree is untouched"
}

# ---------------------------------------------------------------- AC-3
extract() { # extract <changed list>: the id extraction, evaluated exactly as the workflow step runs it
  ( set -euo pipefail; changed="$1"; eval "$ids_line"; printf '%s\n' "$ids" )
}
case_ac3() {
  section "AC-3  the workflow's id extraction sees specs in spec/fixes/"
  ids_line="$(grep -E '^[[:space:]]*ids="\$\(' "$WORKFLOW_SRC" || true)"
  eq "the workflow has exactly one ids= line" 1 "$(printf '%s\n' "$ids_line" | grep -c .)"
  printf '  line under test (from %s):\n    %s\n' "${WORKFLOW_SRC#"$REPO/"}" "$(printf '%s' "$ids_line" | sed -E 's/^[[:space:]]+//')"

  local got rc list

  list=$'spec/features/0007-x/spec.md\nspec/features/0007-x/plan.medium.md\nspec/fixes/0023-y.md\nspec/constitution/roadmap.md'
  got="$(extract "$list" 2>/dev/null)"; rc=$?
  printf '  changed list: %s\n' "$(printf '%s' "$list" | tr '\n' ' ')"
  eq "feature folder + single-file fix: ids" "SPEC-0007,SPEC-0023" "$got"
  eq "feature folder + single-file fix: step does not abort" 0 "$rc"

  list=$'spec/features/0007-x/spec.md\nspec/fixes/0023-y.md'
  got="$(extract "$list" 2>/dev/null)"; rc=$?
  printf '  changed list: %s\n' "$(printf '%s' "$list" | tr '\n' ' ')"
  eq "exactly the two paths of the task: ids" "SPEC-0007,SPEC-0023" "$got"

  list=$'spec/fixes/0023-y.md\nspec/constitution/roadmap.md'
  got="$(extract "$list" 2>/dev/null)"; rc=$?
  printf '  changed list: %s\n' "$(printf '%s' "$list" | tr '\n' ' ')"
  eq "a fix alone: ids" "SPEC-0023" "$got"
  eq "a fix alone: step does not abort" 0 "$rc"

  list=$'spec/fixes/0024-z/spec.md\nspec/fixes/0024-z/plan.low.md\nspec/constitution/roadmap.md'
  got="$(extract "$list" 2>/dev/null)"; rc=$?
  printf '  changed list: %s\n' "$(printf '%s' "$list" | tr '\n' ' ')"
  eq "a fix in a folder, with its plan: one id" "SPEC-0024" "$got"

  printf '\n-- end to end: close-specs.sh output fed to the extraction\n'
  new_repo ac3-end-to-end
  folder_spec spec/features/0007-rate-limit 0007 feature Approved plan.medium.md "In progress"
  single_spec spec/fixes/0023-bump-rule.md 0023 fix Approved
  roadmap "0007|A feature|medium|Approved|—" "0023|A fix|low|Approved|—"
  commit_fixture
  run 'Closes-Spec: SPEC-0007, SPEC-0023'
  got="$(extract "$OUT" 2>/dev/null)"; rc=$?
  eq "ids from the files the script really changed" "SPEC-0007,SPEC-0023" "$got"
  eq "step does not abort" 0 "$rc"

  printf '\n-- fallback: a list with no spec path (pipefail, PM-0009)\n'
  got="$(extract 'spec/constitution/roadmap.md' 2>/dev/null)"; rc=$?
  eq "roadmap only: the step does not abort" 0 "$rc"
  eq "roadmap only: ids is empty before the fallback" "" "$got"
  eq "the workflow falls back to ids=\"specs\"" 1 "$(grep -cE '^[[:space:]]*if \[ -z "\$ids" \]; then ids="specs"; fi' "$WORKFLOW_SRC")"
  old_ids() { printf '%s\n' "$1" | grep -oE '(features|fixes)/[0-9]{4}-' | grep -oE '[0-9]{4}' | sort -u | sed 's/^/SPEC-/' | paste -sd, -; }
  new_ids() { printf '%s\n' "$1" | grep -oE '(features|fixes)/[0-9]{4}-' | grep -oE '[0-9]{4}' | sort -u | sed 's/^/SPEC-/' | paste -sd, - || true; }
  local fn label
  for list in 'spec/constitution/roadmap.md' $'spec/fixes/0023-y.md\nspec/constitution/roadmap.md' $'spec/features/0007-x/spec.md\nspec/fixes/0023-y.md'; do
    label="$(printf '%s' "$list" | tr '\n' ' ')"
    for fn in old_ids new_ids; do
      ( set -euo pipefail; "$fn" "$list" ) >/dev/null 2>&1; rc=$?
      if [ "$fn" = old_ids ] && [ "$list" = 'spec/constitution/roadmap.md' ]; then
        eq "pipefail: the old line (no '|| true') aborts on [$label]" 1 "$rc"
      else
        eq "pipefail: $fn continues on [$label]" 0 "$rc"
      fi
    done
  done
  eq "new_ids on a feature and a fix" "SPEC-0007,SPEC-0023" "$(new_ids $'spec/features/0007-x/spec.md\nspec/fixes/0023-y.md')"

  printf '\n-- probe (information only, not counted)\n'
  got="$(extract $'spec/constitution/roadmap.md' 2>/dev/null)"; rc=$?
  printf '  INFO  a list with no spec path at all (only the roadmap changed) -> exit %s, output %q\n' "$rc" "$got"
}

case_2a
case_2b
case_2c
case_2d
case_2e
case_2f
case_pr_two_types
case_regressions
case_ac3

cd "$HERE" || exit 2
printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
