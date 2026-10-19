#!/usr/bin/env bash
# Runs every CI suite of the release scripts and the docs check (SPEC-0029):
#   bash tests/ci/run.sh
# Each suite builds its fixtures in a temp folder and tests the scripts of this checkout.
# Exit 0 when all pass, 1 when any fails. Suites run one after the other; a failing suite does not
# stop the next, so the summary shows everything that broke.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
suites=(test-close-specs.sh test-tag-skill-releases.sh test-check-docs.sh test-check-versions.sh test-check-catalog.sh)
names=()
results=()
status=0

for suite in "${suites[@]}"; do
  printf '\n######## %s ########\n' "$suite"
  log="$(mktemp)"
  bash "$HERE/$suite" 2>&1 | tee "$log"
  rc=${PIPESTATUS[0]}
  count="$(grep -E '^([0-9]+ passed, [0-9]+ failed|passed: [0-9]+ +failed: [0-9]+)' "$log" | tail -1)"
  rm -f "$log"
  names+=("$suite")
  if [ "$rc" -eq 0 ]; then
    results+=("PASS  ${count:-no summary line}")
  else
    results+=("FAIL  ${count:-no summary line} (exit $rc)")
    status=1
  fi
done

printf '\n######## Summary ########\n'
for i in "${!names[@]}"; do
  printf '%-30s %s\n' "${names[$i]}" "${results[$i]}"
done
if [ "$status" -eq 0 ]; then printf 'all suites passed\n'; else printf 'at least one suite failed\n'; fi
exit "$status"
