#!/usr/bin/env bash
# Tests for skills/better-castilian/scripts/check_writing.py (SPEC-0032): reports the double tilde,
# the simple tilde, the em dash and the en dash with line and column, and skips code blocks,
# inline code, URLs and tilde paths.
#
# Usage: bash tests/ci/test-check-writing.sh
#
# Each case writes a small text file in a temp folder (removed at exit) and runs the script of this
# checkout on it. Nothing in the checkout is touched.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SCRIPT="$REPO/skills/better-castilian/scripts/check_writing.py"
PYTHON="${PYTHON:-python3}"
WORK="$(mktemp -d)"
trap 'cd "$HERE" && rm -rf "$WORK"' EXIT

pass=0
fail=0

ok()  { pass=$((pass + 1)); printf '  PASS  %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL  %s\n          %s\n' "$1" "$2"; }

expect() { # expect <title> <text> <exit> [expected output, exact; omit for any]
  local out rc
  printf '%b' "$2" >"$WORK/t.md"
  out="$(cd "$WORK" && "$PYTHON" -I "$SCRIPT" t.md 2>&1)"
  rc=$?
  if [ "$rc" -ne "$3" ]; then bad "$1" "exit $rc, expected $3: $out"; return; fi
  if [ "$#" -ge 4 ] && [ "$out" != "$4" ]; then bad "$1" "output differs: $out"; return; fi
  ok "$1"
}

expect "clean text  => no output, exit 0" 'Tardo ±30 min (más o menos).\n' 0 ""
expect "double tilde  => line and column" 'uno\ndos ≈ 3\n' 1 't.md:2:5: ≈ double tilde (use ± for approximate amounts)'
expect "simple tilde  => reported" 'son ~2 h\n' 1 't.md:1:5: ~ tilde used as approximately (use ± for approximate amounts)'
expect "em dash  => reported" 'a — b\n' 1 't.md:1:3: — em dash (use comma, period, colon, parentheses or rewrite)'
expect "en dash  => reported" 'a – b\n' 1 't.md:1:3: – en dash (use comma, period, colon, parentheses or rewrite)'
expect "all three in one file  => three lines" 'a ≈ b\nc ~ d\ne — f\n' 1
expect "tilde path  => no false positive" 'Mira ~/proyecto y ~usuario/dir.\n' 0 ""
expect "URL with a tilde  => no false positive" 'https://ejemplo.org/~usuario/x\n' 0 ""
expect "inline code  => skipped" 'usa `a ≈ b — c ~ d` aquí\n' 0 ""
expect "backtick fence  => skipped" 'antes\n```\na ≈ b — c ~ d\n```\ndespués\n' 0 ""
expect "tilde fence  => skipped" '~~~\n≈ — ~\n~~~\n' 0 ""
expect "text after a closed fence  => checked again" '```\nx\n```\ny ≈ z\n' 1 't.md:4:3: ≈ double tilde (use ± for approximate amounts)'
expect "strikethrough  => no false positive" 'tachado ~~viejo~~ ok\n' 0 ""

# arguments and stdin
out="$("$PYTHON" -I "$SCRIPT" 2>&1)"; rc=$?
if [ "$rc" -eq 2 ] && grep -q usage <<<"$out"; then ok "no arguments  => usage, exit 2"; else bad "no arguments  => usage, exit 2" "exit $rc: $out"; fi
"$PYTHON" -I "$SCRIPT" "$WORK/missing.md" >/dev/null 2>&1; rc=$?
if [ "$rc" -eq 2 ]; then ok "missing file  => exit 2"; else bad "missing file  => exit 2" "exit $rc"; fi
out="$(printf 'a ~ b\n' | "$PYTHON" -I "$SCRIPT" - 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && [[ "$out" == "<stdin>:1:3:"* ]]; then ok "stdin  => <stdin> name, exit 1"; else bad "stdin" "exit $rc: $out"; fi

# SKILL.md: the characters appear only in the bad examples (AC-3 of SPEC-0032)
leaks="$(grep -n '≈\|—' "$REPO/skills/better-castilian/SKILL.md" | grep -v '^[0-9]*:| `' || true)"
if [ -z "$leaks" ]; then ok "SKILL.md uses ≈ and — only in the bad examples"; else bad "SKILL.md leak" "$leaks"; fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
