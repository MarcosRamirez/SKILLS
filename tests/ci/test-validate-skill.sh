#!/usr/bin/env bash
# Tests for skills/write-skill/scripts/validate-skill.py (SPEC-0032): the standard's rules as
# errors, this repo's budgets as warnings, and --strict for the stricter gate.
#
# Usage: bash tests/ci/test-validate-skill.sh
#
# Each case builds a small skill in a temp folder (removed at exit), plants the failure and runs the
# validator of this checkout against it. Nothing in the checkout is touched.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SCRIPT="$REPO/skills/write-skill/scripts/validate-skill.py"
PYTHON="${PYTHON:-python3}"
WORK="$(mktemp -d)"
trap 'cd "$HERE" && rm -rf "$WORK"' EXIT

pass=0
fail=0
N=0
SK=""
ARGS=()

ok()  { pass=$((pass + 1)); printf '  PASS  %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL  %s\n          %s\n' "$1" "$2"; }

new_skill() { # new_skill: a minimal valid skill at $SK, one line of body
  SK="$WORK/s$((N += 1))/demo"
  mkdir -p "$SK"
  cat >"$SK/SKILL.md" <<'EOF'
---
name: demo
description: Demo skill. Use when testing the validator.
metadata:
  version: "0.0.1-alpha.1"
---
## Body

One line.
EOF
}

expect() { # expect <title> <exit> [pattern]: run the validator on $SK with $ARGS
  local title=$1 want=$2 pattern=${3:-} out rc
  out="$("$PYTHON" "$SCRIPT" "$SK" ${ARGS[@]+"${ARGS[@]}"} 2>&1)"
  rc=$?
  ARGS=()
  if [ "$rc" -ne "$want" ]; then bad "$title" "exit $rc, expected $want: $out"; return; fi
  if [ -n "$pattern" ] && ! grep -qF -- "$pattern" <<<"$out"; then bad "$title" "output lacks '$pattern': $out"; return; fi
  ok "$title"
}

append() { printf '%s\n' "$1" >>"$SK/SKILL.md"; }

new_skill
expect "minimal valid skill  => exit 0" 0 "0 errors, 0 warnings"

new_skill
mkdir -p "$SK/references"
printf '# Reference\n\nA topic.\n' >"$SK/references/topic.md"
append 'See [the topic](references/topic.md).'
expect "linked reference  => exit 0" 0

new_skill
sed -i 's/^name: demo$/name: other/' "$SK/SKILL.md"
expect "name differs from the folder  => exit 1" 1 "does not match the folder name 'demo'"

new_skill
sed -i 's/^name: demo$/name: Demo/' "$SK/SKILL.md"
expect "uppercase name  => exit 1" 1 "must be lowercase letters"

new_skill
sed -i 's/^name: demo$/name: de--mo/' "$SK/SKILL.md"
expect "consecutive hyphens  => exit 1" 1 "must be lowercase letters"

new_skill
sed -i '/^description:/d' "$SK/SKILL.md"
expect "missing description  => exit 1" 1 "missing description"

new_skill
sed -i "s/^description: .*/description: $(printf 'x%.0s' $(seq 1 1025))/" "$SK/SKILL.md"
expect "description over 1024 chars  => exit 1" 1 "the maximum is 1024"

new_skill
sed -i "s/^description: .*/description: $(printf 'x%.0s' $(seq 1 600))/" "$SK/SKILL.md"
expect "description over 500 chars  => exit 0 with a warning" 0 "target is 500"
new_skill
sed -i "s/^description: .*/description: $(printf 'x%.0s' $(seq 1 600))/" "$SK/SKILL.md"
ARGS=(--strict)
expect "description over 500 chars under --strict  => exit 1" 1 "target is 500"

new_skill
for i in $(seq 1 101); do append "- rule $i"; done
expect "body over 100 lines  => exit 0 with a warning" 0 "the target is 100"
new_skill
for i in $(seq 1 101); do append "- rule $i"; done
ARGS=(--strict)
expect "body over 100 lines under --strict  => exit 1" 1 "the target is 100"

new_skill
append "$(printf 'word %.0s' $(seq 1 900))"
expect "body over 800 words  => exit 0 with a warning" 0 "the target is 800"

new_skill
for i in $(seq 1 501); do append "- rule $i"; done
expect "body over 500 lines  => exit 1" 1 "the standard's maximum is 500"

new_skill
append 'See [missing](references/missing.md).'
expect "broken relative link  => exit 1" 1 "broken link"

new_skill
mkdir -p "$SK/references/sub"
printf '# Nested\n' >"$SK/references/sub/nested.md"
expect "folder inside references/  => exit 1" 1 "no folders inside references"

new_skill
mkdir -p "$SK/references"
printf 'See [b](b.md).\n' >"$SK/references/a.md"
printf '# B\n' >"$SK/references/b.md"
append 'Read [a](references/a.md).'
expect "reference linking to a reference  => exit 1" 1 "links to another reference"

new_skill
mkdir -p "$SK/references"
printf '# Orphan\n' >"$SK/references/orphan.md"
expect "reference linked from nowhere  => exit 0 with a warning" 0 "not linked from SKILL.md"

new_skill
mkdir -p "$SK/references"
for i in $(seq 1 151); do printf -- '- line %s\n' "$i"; done >"$SK/references/long.md"
append 'See [long](references/long.md).'
expect "reference over 150 lines  => exit 0 with a warning" 0 "the target is 150"

new_skill
sed -i 's/^  version: "0.0.1-alpha.1"$/  version: "1.0"/' "$SK/SKILL.md"
expect "version that is not SemVer  => exit 1" 1 "is not SemVer"

new_skill
sed -i '/^metadata:$/d; /^  version:/d' "$SK/SKILL.md"
expect "no metadata.version  => exit 0 with a warning" 0 "no metadata.version"

new_skill
append 'TODO: finish this.'
expect "leftover TODO  => exit 0 with a warning" 0 "leftover TODO"

new_skill
append '## Body'
expect "duplicate heading  => exit 0 with a warning" 0 "duplicate heading"

new_skill
printf -- '---\r\nname: demo\r\ndescription: Demo skill.\r\nmetadata:\r\n  version: "0.0.1-alpha.1"\r\n---\r\n\r\n## Body\r\n\r\nOne line.\r\n' >"$SK/SKILL.md"
expect "CRLF line endings  => exit 0" 0

new_skill
out="$("$PYTHON" "$SCRIPT" "$SK" --json 2>&1)"
rc=$?
if [ "$rc" -eq 0 ] && grep -qF '"errors": []' <<<"$out" && grep -qF '"warnings": []' <<<"$out"; then
  ok "valid skill with --json  => exit 0 and empty lists"
else
  bad "valid skill with --json  => exit 0 and empty lists" "exit $rc: $out"
fi

out="$("$PYTHON" "$SCRIPT" 2>&1)"
rc=$?
if [ "$rc" -eq 64 ]; then ok "no arguments  => exit 64"; else bad "no arguments  => exit 64" "exit $rc: $out"; fi

out="$("$PYTHON" "$SCRIPT" "$REPO/skills/write-skill" --strict 2>&1)"
rc=$?
if [ "$rc" -eq 0 ]; then ok "this checkout's write-skill passes --strict"; else bad "this checkout's write-skill passes --strict" "$out"; fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
