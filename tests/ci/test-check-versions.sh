#!/usr/bin/env bash
# Tests for .github/scripts/check-versions.py (SPEC-0021 T-1, ADR-0006): each marketplace entry
# carries the name and version of its skill's SKILL.md frontmatter.
#
# Usage: bash tests/ci/test-check-versions.sh
#
# Each case builds a small repo in a temp folder (removed at exit) with one skill and its
# marketplace entry, plants the failure and runs the script of this checkout with that folder as
# the root. Nothing in the checkout is touched.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SCRIPT="$REPO/.github/scripts/check-versions.py"
PYTHON="${PYTHON:-python3}"
WORK="$(mktemp -d)"
trap 'cd "$HERE" && rm -rf "$WORK"' EXIT

pass=0
fail=0
N=0
DIR=""

ok()  { pass=$((pass + 1)); printf '  PASS  %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL  %s\n          %s\n' "$1" "$2"; }

new_repo() { # new_repo: skills/demo at 1.2.3 with a matching marketplace entry
  DIR="$WORK/r$((N += 1))"
  mkdir -p "$DIR/.claude-plugin" "$DIR/skills/demo"
  printf -- '---\nname: demo\ndescription: Demo skill.\nmetadata:\n  version: "1.2.3"\n---\n\n# demo\n' \
    >"$DIR/skills/demo/SKILL.md"
  marketplace demo 1.2.3
}
marketplace() { # marketplace <name> <version>: the single entry for ./skills/demo
  printf '{"name": "m", "plugins": [{"name": "%s", "source": "./skills/demo", "version": "%s"}]}\n' "$1" "$2" \
    >"$DIR/.claude-plugin/marketplace.json"
}
expect() { # expect <title> <exit> [pattern]: run the check on $DIR
  local out rc
  out="$("$PYTHON" "$SCRIPT" "$DIR" 2>&1)"
  rc=$?
  if [ "$rc" -ne "$2" ]; then bad "$1" "exit $rc, expected $2: $out"; return; fi
  if [ -n "${3:-}" ] && ! grep -qF -- "$3" <<<"$out"; then bad "$1" "output lacks '$3': $out"; return; fi
  ok "$1"
}

new_repo
expect "matching name and version  => exit 0" 0

new_repo
marketplace demo 1.2.4
expect "marketplace version differs from SKILL.md  => exit 1" 1 "version '1.2.4' differs from SKILL.md metadata.version '1.2.3'"

new_repo
marketplace other 1.2.3
expect "marketplace name differs from SKILL.md name  => exit 1" 1 "name differs from SKILL.md name 'demo'"

new_repo
sed -i 's/^  version: "1.2.3"$/  version: "1.2"/' "$DIR/skills/demo/SKILL.md"
marketplace demo 1.2
expect "version that is not SemVer  => exit 1" 1 "is not SemVer"

new_repo
sed -i '/^metadata:$/d; /^  version:/d' "$DIR/skills/demo/SKILL.md"
expect "SKILL.md without metadata.version  => exit 1" 1 "no metadata.version"

new_repo
printf -- '---\r\nname: demo\r\nmetadata:\r\n  version: "1.2.3"\r\n---\r\n' >"$DIR/skills/demo/SKILL.md"
expect "SKILL.md with CRLF line endings  => exit 0" 0

new_repo
mkdir -p "$DIR/skills/orphan"
printf -- '---\nname: orphan\nmetadata:\n  version: "0.0.1-alpha.1"\n---\n' >"$DIR/skills/orphan/SKILL.md"
expect "skill folder without a marketplace entry  => exit 1" 1 "skills/orphan: no entry"

new_repo
printf '{"plugins": [{"name": "demo", "source": "./skills/demo", "version": "1.2.3"}, {"name": "ext", "source": {"source": "github", "repo": "a/b"}}]}\n' \
  >"$DIR/.claude-plugin/marketplace.json"
expect "external plugin entry is not checked  => exit 0" 0

new_repo
printf -- '---\nname: demo\nmetadata:\n  version: "1.2.3"\n---\n\nversion: "9.9.9"\n' >"$DIR/skills/demo/SKILL.md"
expect "a version line in the body is not the frontmatter version  => exit 0" 0

expect_repo() {
  local out rc
  out="$("$PYTHON" "$SCRIPT" "$REPO" 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ]; then ok "this checkout passes"; else bad "this checkout passes" "$out"; fi
}
expect_repo

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
