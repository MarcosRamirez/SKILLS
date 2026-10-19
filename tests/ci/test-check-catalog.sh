#!/usr/bin/env bash
# Tests for .github/scripts/check-catalog.py (SPEC-0011 AC-2): the curated catalog is rejected
# when an entry is malformed, unpinned, carries a scope flag or looks like it holds a secret.
#
# Usage: bash tests/ci/test-check-catalog.sh
#
# Each case copies the checkout's catalog schema into a temp folder (removed at exit) with a valid
# skills.json and mcps.json, plants one problem with a small Python edit, and runs the script of
# this checkout on that folder. Nothing in the checkout is touched.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SCRIPT="$REPO/.github/scripts/check-catalog.py"
SCHEMA="$REPO/skills/senior-mindset/catalog/catalog.schema.json"
PYTHON="${PYTHON:-python3}"
WORK="$(mktemp -d)"
trap 'cd "$HERE" && rm -rf "$WORK"' EXIT

pass=0
fail=0
N=0
DIR=""

ok()  { pass=$((pass + 1)); printf '  PASS  %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL  %s\n          %s\n' "$1" "$2"; }

new_catalog() { # new_catalog: a valid catalog with one skill and one MCP
  DIR="$WORK/c$((N += 1))"
  mkdir -p "$DIR"
  cp "$SCHEMA" "$DIR/catalog.schema.json"
  cat > "$DIR/skills.json" <<'JSON'
{
  "kind": "skills",
  "entries": [
    {
      "id": "web-design", "name": "Web design", "purpose": "Accessible layouts", "recommended": true,
      "proposeWhen": { "tasks": ["landing page"], "stack": ["astro"] },
      "source": { "repo": "https://github.com/example/skills", "path": "skills/web-design", "ref": "v1.2.0", "license": "MIT" },
      "install": { "npx-skills": "npx skills add example/skills#v1.2.0 --skill web-design" },
      "permissions": "none", "version": "1.2.0", "why": "Covers the web-design task", "added": "2026-10-19"
    }
  ],
  "rejected": [ { "id": "old-skill", "name": "Old skill", "reason": "unmaintained", "date": "2026-10-19" } ]
}
JSON
  cat > "$DIR/mcps.json" <<'JSON'
{
  "kind": "mcps",
  "entries": [
    {
      "id": "docs-server", "name": "Docs server", "purpose": "Library docs", "recommended": false,
      "proposeWhen": { "tasks": ["use a library"], "stack": ["any"] },
      "source": { "repo": "https://github.com/example/docs-mcp", "ref": "npm docs-mcp 2.0.1", "license": "Apache-2.0" },
      "install": { "claude-code": "claude mcp add --transport http docs https://docs.example.com/mcp" },
      "auth": "Optional key in an environment variable", "permissions": "network", "version": "2.0.1",
      "why": "Version-specific docs", "added": "2026-10-19"
    }
  ],
  "rejected": []
}
JSON
}

edit() { # edit FILE PYTHON_EXPRESSION_ON_d: change the parsed JSON `d` and write it back
  "$PYTHON" - "$DIR/$1" "$2" <<'PY'
import json, sys
path, code = sys.argv[1], sys.argv[2]
d = json.load(open(path, encoding="utf-8"))
exec(code)
json.dump(d, open(path, "w", encoding="utf-8"), indent=2)
PY
}

expect() { # expect TITLE EXIT [PATTERN]: run the check on $DIR
  local out rc
  out="$("$PYTHON" "$SCRIPT" "$DIR" 2>&1)"
  rc=$?
  if [ "$rc" -ne "$2" ]; then bad "$1" "exit $rc, expected $2: $out"; return; fi
  if [ -n "${3:-}" ] && ! grep -qF -- "$3" <<<"$out"; then bad "$1" "output lacks '$3': $out"; return; fi
  ok "$1"
}

new_catalog
expect "valid catalog  => exit 0" 0

new_catalog; edit skills.json 'del d["entries"][0]["why"]'
expect "entry without a required field  => exit 1" 1 "missing 'why'"

new_catalog; edit skills.json 'd["entries"][0]["recommended"] = "yes"'
expect "recommended is not a boolean  => exit 1" 1 "expected boolean"

new_catalog; edit mcps.json 'd["entries"][0]["homepage"] = "https://x"'
expect "unknown key in an entry  => exit 1" 1 "unknown key 'homepage'"

new_catalog; edit skills.json 'd["entries"][0]["id"] = "Web Design"'
expect "id that is not kebab-case  => exit 1" 1 "does not match"

new_catalog; edit skills.json 'd["entries"][0]["added"] = "19/10/2026"'
expect "date not in YYYY-MM-DD  => exit 1" 1 ".added"

new_catalog; edit skills.json 'd["entries"].append(dict(d["entries"][0]))'
expect "duplicate id  => exit 1" 1 "appears more than once"

new_catalog; edit skills.json 'd["rejected"][0]["id"] = "web-design"'
expect "an id both an entry and rejected  => exit 1" 1 "both an entry and rejected"

new_catalog; edit skills.json 'd["entries"][0]["source"]["ref"] = "main"'
expect "source.ref on a moving branch  => exit 1" 1 "is not pinned"

new_catalog; edit mcps.json 'd["entries"][0]["version"] = "latest"'
expect "version 'latest'  => exit 1" 1 "is not pinned"

new_catalog; edit skills.json 'd["entries"][0]["install"]["npx-skills"] += " -g"'
expect "skill install with -g  => exit 1" 1 "carries a scope flag"

new_catalog; edit mcps.json 'd["entries"][0]["install"]["claude-code"] = "claude mcp add --scope user --transport http docs https://docs.example.com/mcp"'
expect "MCP install with --scope  => exit 1" 1 "carries a scope flag"

new_catalog; edit skills.json 'd["entries"][0]["install"] = {"npx-skills": "git clone https://github.com/example/skills"}'
expect "skill not installed with npx skills  => exit 1" 1 "must start with 'npx skills add '"

new_catalog; edit mcps.json 'd["entries"][0]["auth"] = "Bearer abcdefghijklmnopqrstuvwxyz0123"'
expect "a string that looks like a secret  => exit 1" 1 "looks like a secret"

new_catalog; edit mcps.json 'd["kind"] = "skills"'
expect "kind that does not match the file  => exit 1" 1 "expected 'mcps'"

new_catalog; printf '{ "kind": "skills", ' > "$DIR/skills.json"
expect "invalid JSON  => exit 1" 1 "skills.json"

DIR="$REPO/skills/senior-mindset/catalog"
expect "this checkout's catalog passes" 0

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
