#!/usr/bin/env bash
# Tests for the docs check (SPEC-0024, SPEC-0029):
#   repo:     .github/scripts/check-docs.py
#   template: skills/senior-mindset/templates/docs-check/check-docs.py (copied into apps)
#
# Usage: bash tests/ci/test-check-docs.sh
#
# Each case builds a small project in a temp folder (removed at exit), copies the script under test
# from the checkout this file lives in to .github/scripts/check-docs.py (the script finds the
# project root two folders up), plants the failure and runs it. Nothing in the checkout is touched.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
REPO_SCRIPT="$REPO/.github/scripts/check-docs.py"
TEMPLATE_SCRIPT="$REPO/skills/senior-mindset/templates/docs-check/check-docs.py"
PYTHON="${PYTHON:-python3}"
WORK="$(mktemp -d)"
trap 'cd "$HERE" && rm -rf "$WORK"' EXIT

pass=0
fail=0
RC=0
OUT=""
N=0

ok()  { pass=$((pass + 1)); printf '  PASS  %s\n' "$1"; }
bad() {
  fail=$((fail + 1))
  printf '  FAIL  %s\n' "$1"
  shift
  local line
  for line in "$@"; do printf '          %s\n' "$line"; done
}
section() { printf '\n== %s\n' "$1"; }
eq()  { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1" "expected: $2" "actual:   $3"; fi; }
has() { if grep -qE -- "$3" <<<"$2"; then ok "$1"; else bad "$1" "pattern: $3" "text:    $2"; fi; }
lacks() { if grep -qE -- "$3" <<<"$2"; then bad "$1" "unexpected pattern: $3" "text:    $2"; else ok "$1"; fi; }

new_project() { # new_project <repo|template>: a clean project with the script installed; cd into it
  local dir="$WORK/p$((N += 1))"
  mkdir -p "$dir/.github/scripts" "$dir/spec/adr" "$dir/spec/constitution" "$dir/docs"
  cd "$dir" || exit 2
  case "$1" in
    repo) cp "$REPO_SCRIPT" .github/scripts/check-docs.py ;;
    template) cp "$TEMPLATE_SCRIPT" .github/scripts/check-docs.py ;;
    *) exit 2 ;;
  esac
  printf '# ADR-0001: old way\n\nStatus: Superseded by [ADR-0002](0002-new-way.md)\n' >spec/adr/0001-old-way.md
  printf '# ADR-0002: new way\n\nStatus: Accepted\nSupersedes: [ADR-0001](0001-old-way.md)\n' >spec/adr/0002-new-way.md
  printf '# ADRs\n\n- [0001](0001-old-way.md) superseded\n- [0002](0002-new-way.md)\n' >spec/adr/README.md
  printf '# Inventory\n\nSee [the README](../README.md).\n' >spec/INVENTORY.md
  printf '# Project\n\nSee [the guide](docs/guide.md) and [the decision](spec/adr/0002-new-way.md).\n' >README.md
  printf '# Guide\n\nBack to the [README](../README.md).\n' >docs/guide.md
}

check() { # check [env VAR=value ...] -- [file ...]: run the check from the project root
  local envs=()
  while [ "$#" -gt 0 ] && [ "$1" != -- ]; do envs+=("$1"); shift; done
  [ "${1:-}" = -- ] && shift
  OUT="$(env "${envs[@]+"${envs[@]}"}" "$PYTHON" .github/scripts/check-docs.py "$@" 2>&1)"
  RC=$?
}

append() { printf '%s\n' "$2" >>"$1"; } # append <file> <line>

suite() { # suite <repo|template>: every case against one script
  local v="$1"
  section "[$v] a clean tree passes"
  new_project "$v"
  check --
  eq "exit code 0" 0 "$RC"
  eq "no output" "" "$OUT"

  section "[$v] a planted broken link fails"
  new_project "$v"
  append README.md 'A [missing page](docs/nope.md) here.'
  check --
  eq "exit code 1" 1 "$RC"
  has "names the file, the line and the link" "$OUT" '^README\.md:4: broken link: docs/nope\.md$'
  eq "reports the one finding only" 1 "$(printf '%s\n' "$OUT" | grep -c .)"

  section "[$v] a broken link in a second document is found too"
  new_project "$v"
  append spec/INVENTORY.md 'See [gone](gone.md).'
  append README.md 'A [missing page](docs/nope.md) here.'
  check --
  eq "exit code 1" 1 "$RC"
  has "finding in README.md (and one in the inventory)" "$OUT" '^README\.md:4: broken link'
  eq "reports both findings" 2 "$(printf '%s\n' "$OUT" | grep -c .)"

  section "[$v] a planted link to a superseded ADR fails"
  new_project "$v"
  append README.md 'The old [decision](spec/adr/0001-old-way.md) still applies.'
  check --
  eq "exit code 1" 1 "$RC"
  has "names the file, the line and the link" "$OUT" '^README\.md:4: link to superseded ADR: spec/adr/0001-old-way\.md$'

  section "[$v] a link with an anchor to a superseded ADR fails too"
  new_project "$v"
  append README.md 'The old [decision](spec/adr/0001-old-way.md#context) still applies.'
  check --
  eq "exit code 1" 1 "$RC"
  has "reported as superseded" "$OUT" 'link to superseded ADR'

  section "[$v] a link to an Accepted ADR passes"
  new_project "$v"
  append README.md 'The current [decision](spec/adr/0002-new-way.md#why).'
  check --
  eq "exit code 0" 0 "$RC"
  eq "no output" "" "$OUT"

  section "[$v] links inside code are ignored"
  new_project "$v"
  {
    printf '\n```md\n[broken](docs/nope.md)\n[old](spec/adr/0001-old-way.md)\n```\n'
    printf '\n~~~\n[broken tilde](docs/nope2.md)\n~~~\n'
    printf '\n````text\n```\n[still inside](docs/nope3.md)\n```\n````\n'
    printf '\nInline `[broken](docs/nope4.md)` code span.\n'
  } >>README.md
  check --
  eq "exit code 0 (fences and code spans)" 0 "$RC"
  eq "no output" "" "$OUT"
  append README.md '[after the fences](docs/nope5.md)'
  check --
  eq "a real link after the fences is still checked" 1 "$RC"
  has "reports line of the link after the fences" "$OUT" 'README\.md:[0-9]+: broken link: docs/nope5\.md'
  eq "only that finding" 1 "$(printf '%s\n' "$OUT" | grep -c .)"

  section "[$v] external, anchor and protocol links are not checked"
  new_project "$v"
  append README.md '[web](https://example.invalid/x) [mail](mailto:a@example.invalid) [here](#top) [proto](//example.invalid/y)'
  check --
  eq "exit code 0" 0 "$RC"

  section "[$v] files inside an adr/ folder may link to superseded ADRs"
  new_project "$v"
  check -- spec/adr/README.md spec/adr/0002-new-way.md
  eq "adr index and a Supersedes line: exit code 0" 0 "$RC"
  eq "no output" "" "$OUT"
  check -- README.md
  eq "the same kind of link from README.md is fine when it is clean" 0 "$RC"
  append README.md '[old](spec/adr/0001-old-way.md)'
  check -- README.md
  eq "a link to the superseded ADR from outside adr/ fails" 1 "$RC"
  check -- spec/adr/README.md
  eq "the same ADR from the adr index still passes" 0 "$RC"
  printf '# ADR-0003: next\n\nStatus: Accepted\n\nBroken [x](nope.md).\n' >spec/adr/0003-next.md
  check -- spec/adr/0003-next.md
  eq "adr/ files are still checked for broken links" 1 "$RC"
  has "reports the broken link" "$OUT" 'spec/adr/0003-next\.md:5: broken link: nope\.md'

  section "[$v] files given as arguments replace the default set"
  new_project "$v"
  append README.md '[missing](docs/nope.md)'
  check -- docs/guide.md
  eq "only the given file is checked" 0 "$RC"
  check -- docs/not-there.md
  eq "a missing file is reported: exit code 1" 1 "$RC"
  has "message says document not found" "$OUT" 'docs/not-there\.md:1: document not found'

  section "[$v] the default set covers the constitution and the inventory"
  new_project "$v"
  append spec/constitution/roadmap.md 'See [x](nope-roadmap.md).'
  check --
  eq "broken link in spec/constitution: exit code 1" 1 "$RC"
  has "finding names the roadmap" "$OUT" '^spec/constitution/roadmap\.md:1: broken link'
  new_project "$v"
  append spec/INVENTORY.md 'See [x](nope-inv.md).'
  check --
  eq "broken link in spec/INVENTORY.md: exit code 1" 1 "$RC"
  has "finding names the inventory" "$OUT" '^spec/INVENTORY\.md:[0-9]+: broken link'

  section "[$v] feature specs carry history and are left out"
  new_project "$v"
  mkdir -p spec/features/0001-x
  printf '# SPEC-0001\n\n[old](../../adr/0001-old-way.md) [gone](nope.md)\n' >spec/features/0001-x/spec.md
  check --
  eq "exit code 0" 0 "$RC"
}

repo_only() {
  section "[repo] skills/*/README.md, SKILL.md and references/*.md are checked"
  new_project repo
  mkdir -p skills/foo/references
  printf '# foo\n\nSee [ref](references/a.md).\n' >skills/foo/README.md
  printf '# a\n' >skills/foo/references/a.md
  printf -- '---\nname: foo\n---\n\n# foo\n' >skills/foo/SKILL.md
  check --
  eq "clean skill: exit code 0" 0 "$RC"
  append skills/foo/README.md '[bad](nope.md)'
  check --
  eq "broken link in a skill README: exit code 1" 1 "$RC"
  has "finding names the README" "$OUT" '^skills/foo/README\.md:[0-9]+: broken link: nope\.md'
  new_project repo
  mkdir -p skills/foo/references
  append skills/foo/references/a.md '[bad](nope.md)'
  check --
  eq "broken link in a reference: exit code 1" 1 "$RC"
  new_project repo
  mkdir -p skills/foo
  append skills/foo/SKILL.md 'Old [decision](../../spec/adr/0001-old-way.md).'
  check --
  eq "SKILL.md linking a superseded ADR: exit code 1" 1 "$RC"
  has "reported as superseded" "$OUT" 'skills/foo/SKILL\.md:[0-9]+: link to superseded ADR'
}

template_only() {
  section "[template] DOCS_CHECK_FILES chooses the documents"
  new_project template
  mkdir -p notes
  printf '# Notes\n\n[bad](nope.md)\n' >notes/n.md
  check --
  eq "notes/ is outside the default set: exit code 0" 0 "$RC"
  check DOCS_CHECK_FILES='notes/*.md' --
  eq "DOCS_CHECK_FILES=notes/*.md checks notes: exit code 1" 1 "$RC"
  has "finding names the note" "$OUT" '^notes/n\.md:3: broken link: nope\.md$'
  append README.md '[also bad](nope-readme.md)'
  check DOCS_CHECK_FILES='notes/*.md' --
  eq "README.md is not checked when it is not listed" 1 "$RC"
  eq "only the note is reported" 1 "$(printf '%s\n' "$OUT" | grep -c .)"
  check DOCS_CHECK_FILES='notes/*.md,README.md' --
  eq "comma separated list: both documents" 2 "$(printf '%s\n' "$OUT" | grep -c .)"
  check DOCS_CHECK_FILES=$'notes/*.md\nREADME.md' --
  eq "newline separated list: both documents" 2 "$(printf '%s\n' "$OUT" | grep -c .)"
  check DOCS_CHECK_FILES='nothing/*.md' --
  eq "a glob that matches nothing is ignored: exit code 0" 0 "$RC"
  check DOCS_CHECK_FILES='notes/*.md' -- README.md
  eq "files given as arguments win over DOCS_CHECK_FILES" 1 "$RC"
  has "reports README.md" "$OUT" '^README\.md:[0-9]+: broken link: nope-readme\.md'
  lacks "does not report the note" "$OUT" 'notes/n\.md'
  new_project template
  mkdir -p notes
  printf '# Notes\n\n[old](../spec/adr/0001-old-way.md)\n' >notes/n.md
  check DOCS_CHECK_FILES='notes/*.md' --
  eq "a superseded ADR link in a listed document fails" 1 "$RC"
  has "reported as superseded" "$OUT" '^notes/n\.md:3: link to superseded ADR'

  section "[template] docs/**/*.md is in the default set"
  new_project template
  mkdir -p docs/deep/er
  printf '# Deep\n\n[bad](nope.md)\n' >docs/deep/er/page.md
  check --
  eq "broken link in docs/deep/er: exit code 1" 1 "$RC"
  has "finding names the page" "$OUT" '^docs/deep/er/page\.md:3: broken link'
}

suite repo
suite template
repo_only
template_only

cd "$HERE" || exit 2
printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
