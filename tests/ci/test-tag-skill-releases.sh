#!/usr/bin/env bash
# Tests for .github/scripts/tag-skill-releases.sh (SPEC-0023, SPEC-0029): the guard that refuses to
# tag a version when nothing but the version and the changelog changed since the skill's previous
# tag, plus the tagging itself.
#
# Usage: bash tests/ci/test-tag-skill-releases.sh
#
# The script under test is copied from the checkout this file lives in. It runs inside a scratch
# repository built here (skills save-image 1.0.1 and senior-mindset 2.2.0, both tagged), so the
# suite does not depend on this repository's history or tags, and needs no network. Every case
# starts from the same base commit and runs the script with DRY_RUN=1. The last two cases run it
# for real against a scratch bare remote with a fake `gh` (tests/ci/fakebin/gh) first in PATH.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
NEW_SCRIPT="$REPO/.github/scripts/tag-skill-releases.sh"
WORK="$(mktemp -d)"
trap 'cd "$HERE" && rm -rf "$WORK"' EXIT
CLONE="$WORK/repo"
PYTHON="${PYTHON:-python3}"
export GIT_CONFIG_NOSYSTEM=1

pass=0
fail=0
OUT=""
RC=0

declare -A CASE_PASS CASE_FAIL CASE_TITLE
CASE_ORDER=()
CASE=""

say()  { printf '%s\n' "$*"; }
ok()   { say "  PASS  $*"; pass=$((pass + 1)); CASE_PASS[$CASE]=$(( ${CASE_PASS[$CASE]:-0} + 1 )); }
bad()  { say "  FAIL  $*"; fail=$((fail + 1)); CASE_FAIL[$CASE]=$(( ${CASE_FAIL[$CASE]:-0} + 1 )); }
die()  { say "harness error: $*"; exit 2; }

new_case() {  # new_case <id> <title>: starts the bookkeeping of a case
  CASE="$1"
  CASE_TITLE[$1]="$2"
  CASE_ORDER+=("$1")
}

env_shown() {  # the env assignments given as arguments, with PATH shortened
  local a out=""
  for a in "$@"; do
    case "$a" in
      PATH=*) out="${out}PATH=<fake>:\$PATH " ;;
      *) out="${out}${a} " ;;
    esac
  done
  printf '%s' "$out"
}

sedi() {  # sedi <expression> <file>: in-place sed that works with GNU and BSD sed
  sed "$1" "$2" >"$2.tmp" && mv "$2.tmp" "$2"
}
to_crlf() {  # to_crlf <file>: rewrite the line endings as CRLF
  "$PYTHON" -c '
import sys
p = sys.argv[1]
data = open(p, "rb").read().replace(b"\r\n", b"\n").replace(b"\n", b"\r\n")
open(p, "wb").write(data)
' "$1"
}

write_skill() {  # write_skill <dir> <name> <version>: a skill as the repository ships them
  local dir="skills/$1"
  mkdir -p "$dir/.claude-plugin" "$dir/scripts"
  printf '{\n  "name": "%s",\n  "version": "%s",\n  "description": "Skill %s for the tests"\n}\n' "$2" "$3" "$2" \
    >"$dir/.claude-plugin/plugin.json"
  cat >"$dir/SKILL.md" <<MD
---
name: $2
description: Skill $2 for the tests.
metadata:
  author: Scratch Tester
  version: "$3"
---

# $2

## How it works

Body of the skill.
MD
  printf '# %s\n\nWhat it does.\n' "$2" >"$dir/README.md"
  printf '# Changelog\n\nGenerated with git-cliff.\n\n## [%s-v%s] - 2026-10-12\n\n### Added\n\n- Initial release\n' "$2" "$3" \
    >"$dir/CHANGELOG.md"
  printf '#!/usr/bin/env python3\nprint("hook")\n' >"$dir/scripts/$2-hook.py"
}

setup() {
  new_case setup "the scratch repository is built"
  mkdir -p "$CLONE" && cd "$CLONE" || die "cd repo"
  git init -q -b master
  git config user.name "Scratch Tester"
  git config user.email "scratch@example.invalid"
  git config core.autocrlf false
  git config commit.gpgsign false
  git config tag.gpgsign false
  git config advice.detachedHead false
  mkdir -p .github/scripts spec
  printf '# Scratch repository\n' >README.md
  printf '# Inventory\n' >spec/INVENTORY.md
  write_skill save-image save-image 1.0.1
  write_skill senior-mindset senior-mindset 2.2.0
  git add -A && git commit -q -m "initial: save-image 1.0.1 and senior-mindset 2.2.0"
  git tag -a save-image-v1.0.1 -m "save-image 1.0.1"
  git tag -a senior-mindset-v2.2.0 -m "senior-mindset 2.2.0"
  # An unreleased change in senior-mindset after its tag, as master carries between releases.
  printf '\nAn unreleased improvement.\n' >>skills/senior-mindset/README.md
  git add -A && git commit -q -m "improve senior-mindset (unreleased)"
  cp "$NEW_SCRIPT" .github/scripts/tag-skill-releases.sh
  git add .github/scripts/tag-skill-releases.sh
  git commit -q -m "test: install the script under test"
  BASE="$(git rev-parse HEAD)"
  git tag -l | sort >"$WORK/original-tags.txt"
  say "repo:     $CLONE"
  say "base:     $BASE"
  say "git:      $(git --version)   bash: ${BASH_VERSION}"
  if cmp -s "$NEW_SCRIPT" .github/scripts/tag-skill-releases.sh; then
    ok "the installed script is the one in the checkout"
  else
    bad "the installed script differs from the checkout"
  fi
}

drop_extra_tags() {  # delete the tags a case created locally
  local t
  while IFS= read -r t; do
    [ -n "$t" ] && git tag -d "$t" >/dev/null
  done < <(git tag -l | grep -vxFf "$WORK/original-tags.txt" || true)
}

# --- case plumbing -------------------------------------------------------------------------------

begin() {  # begin <id> <title>
  new_case "$1" "$2"
  git switch -q --detach "$BASE" || die "switch to base"
  git clean -fdq
  drop_extra_tags
  say
  say "=== $1. $2"
}

commit() {  # commit <message>: stage everything and commit
  git add -A
  if git diff --cached --quiet; then die "case $CASE: nothing to commit ($1)"; fi
  git commit -q -m "$1"
}

changes() {  # changes <tag> <skill>: what git sees in the skill folder since <tag>
  local stat
  stat="$(git diff --stat "$1" HEAD -- "skills/$2")"
  say "changed in skills/$2 since $1:"
  if [ -n "$stat" ]; then printf '%s\n' "$stat" | sed 's/^/  /'; else say "  (nothing)"; fi
}

run_new() {  # run_new [VAR=value ...]: the script under test, DRY_RUN=1
  local before after
  before="$(git tag -l | sort)"
  OUT="$(env DRY_RUN=1 "$@" bash .github/scripts/tag-skill-releases.sh 2>&1)"; RC=$?
  after="$(git tag -l | sort)"
  say "\$ $(env_shown "$@")DRY_RUN=1 bash .github/scripts/tag-skill-releases.sh"
  say "$OUT"
  say "exit=$RC"
  if [ "$before" = "$after" ]; then ok "the dry run created no tag"; else bad "the dry run changed the tags"; fi
}

expect_rc()    { if [ "$RC" -eq "$1" ]; then ok "exit status is $1"; else bad "exit status is $RC, expected $1"; fi; }
expect_has()   { if printf '%s\n' "$OUT" | grep -qF -- "$1"; then ok "output has: $1"; else bad "output lacks: $1"; fi; }
expect_lacks() { if printf '%s\n' "$OUT" | grep -qF -- "$1"; then bad "output has (unexpected): $1"; else ok "output lacks: $1"; fi; }

# --- edits -------------------------------------------------------------------------------------

bump_manifest() {     # bump_manifest <skill> <old> <new>: version in plugin.json
  sedi "s/\"version\": \"$2\"/\"version\": \"$3\"/" "skills/$1/.claude-plugin/plugin.json"
}
bump_frontmatter() {  # bump_frontmatter <skill> <old> <new>: metadata.version in SKILL.md
  sedi "s/^  version: \"$2\"\$/  version: \"$3\"/" "skills/$1/SKILL.md"
}
add_changelog_section() {  # add_changelog_section <skill> <tag>: a new release section, newest first
  local file="skills/$1/CHANGELOG.md"
  awk -v tag="$2" '
    /^## \[/ && !done { print "## [" tag "] - 2026-10-14\n\n### Fixed\n\n- Wording\n"; done = 1 }
    { print }
  ' "$file" >"$file.tmp" && mv "$file.tmp" "$file"
}
change_body() {       # change_body <skill>: a real text change in the body of SKILL.md
  sedi 's/^## How it works$/## How it works (reworded)/' "skills/$1/SKILL.md"
}

REFUSE_SI="error: refusing to tag save-image-v1.0.2: nothing changed in skills/save-image/ since save-image-v1.0.1 besides the version and changelog"

# --- the cases -----------------------------------------------------------------------------------

setup

say
say "################ Required cases (a-g) ################"

begin a "save-image: plugin.json 1.0.1 -> 1.0.2, no other change  => refused, exit 1"
bump_manifest save-image 1.0.1 1.0.2
commit "bump save-image to 1.0.2 (plugin.json only)"
changes save-image-v1.0.1 save-image
run_new
expect_rc 1
expect_has "$REFUSE_SI"
expect_has "::error::refusing to tag save-image-v1.0.2"
expect_lacks "would tag save-image-v1.0.2"
expect_has "senior-mindset-v2.2.0 exists — skipping"

begin b "save-image: bump (plugin.json + SKILL.md version) + a real change in the SKILL.md body  => would tag"
bump_manifest save-image 1.0.1 1.0.2
bump_frontmatter save-image 1.0.1 1.0.2
change_body save-image
commit "bump save-image to 1.0.2 with a reworded heading"
changes save-image-v1.0.1 save-image
run_new
expect_rc 0
expect_has "would tag save-image-v1.0.2 at"
expect_lacks "refusing"

begin b2 "save-image: MINOR bump 1.1.0 (plugin.json + SKILL.md version) + a real change in scripts/  => would tag"
bump_manifest save-image 1.0.1 1.1.0
bump_frontmatter save-image 1.0.1 1.1.0
printf '\n# a real code change\n' >>skills/save-image/scripts/save-image-hook.py
commit "bump save-image to 1.1.0 with a change in the hook"
changes save-image-v1.0.1 save-image
run_new
expect_rc 0
expect_has "would tag save-image-v1.1.0 at"
expect_lacks "refusing"

begin c "save-image: bump (plugin.json + only the SKILL.md version line)  => refused, exit 1"
bump_manifest save-image 1.0.1 1.0.2
bump_frontmatter save-image 1.0.1 1.0.2
commit "bump save-image to 1.0.2 (plugin.json + SKILL.md version line)"
changes save-image-v1.0.1 save-image
run_new
expect_rc 1
expect_has "$REFUSE_SI"
expect_lacks "would tag save-image-v1.0.2"

begin c2 "save-image: same as c, the version line rewritten without quotes (version: 1.0.2)  => refused, exit 1"
bump_manifest save-image 1.0.1 1.0.2
sedi 's/^  version: "1.0.1"$/  version: 1.0.2/' skills/save-image/SKILL.md
commit "bump save-image to 1.0.2 (unquoted version line)"
changes save-image-v1.0.1 save-image
run_new
expect_rc 1
expect_has "$REFUSE_SI"

begin d "save-image: bump (plugin.json) + only CHANGELOG.md changed  => refused, exit 1"
bump_manifest save-image 1.0.1 1.0.2
add_changelog_section save-image save-image-v1.0.2
commit "bump save-image to 1.0.2 (plugin.json + CHANGELOG.md)"
changes save-image-v1.0.1 save-image
run_new
expect_rc 1
expect_has "$REFUSE_SI"
expect_lacks "would tag save-image-v1.0.2"

begin e "brand-new skill skills/new-skill at 0.0.1-alpha.1, no previous tag  => would tag"
mkdir -p skills/new-skill/.claude-plugin
cat >skills/new-skill/.claude-plugin/plugin.json <<'JSON'
{
  "name": "new-skill",
  "version": "0.0.1-alpha.1",
  "description": "A brand-new skill used only by the T-3 tests"
}
JSON
cat >skills/new-skill/SKILL.md <<'MD'
---
name: new-skill
description: A brand-new skill used only by the T-3 tests.
metadata:
  version: "0.0.1-alpha.1"
---

# new-skill
MD
commit "add skills/new-skill"
say "tags of new-skill: $(git tag -l 'new-skill-v*' | wc -l)"
run_new
expect_rc 0
expect_has "would tag new-skill-v0.0.1-alpha.1 at"
expect_has "--prerelease"
expect_lacks "refusing"
expect_lacks "warning"

begin f "nothing bumped: existing tags are skipped (existing tags untouched)"
say "tags before: $(git tag -l | wc -l)"
run_new
expect_rc 0
expect_has "save-image-v1.0.1 exists — skipping"
expect_has "senior-mindset-v2.2.0 exists — skipping"
expect_lacks "refusing"
expect_lacks "would tag"
say "tags after:  $(git tag -l | wc -l)"

begin g "two skills at once: save-image bump-only (refused) + senior-mindset bump with a real change (valid)"
# A local release point at the base keeps this case independent of the unreleased T-2 changes
# that master already carries in skills/senior-mindset since senior-mindset-v2.2.0.
git tag -a senior-mindset-v2.2.1 -m "local test tag" "$BASE"
bump_manifest save-image 1.0.1 1.0.2
bump_manifest senior-mindset 2.2.0 2.2.2
bump_frontmatter senior-mindset 2.2.0 2.2.2
printf '\nA real change.\n' >>skills/senior-mindset/README.md
commit "bump both skills; only senior-mindset has a real change"
changes save-image-v1.0.1 save-image
changes senior-mindset-v2.2.1 senior-mindset
run_new
expect_rc 1
expect_has "$REFUSE_SI"
expect_has "would tag senior-mindset-v2.2.2 at"
expect_lacks "would tag save-image-v1.0.2"

say
say "################ Extra cases (edges of the check) ################"

begin h "save-image: bump + only skills/save-image/README.md changed  => would tag (README counts)"
bump_manifest save-image 1.0.1 1.0.2
printf '\nOne more sentence.\n' >>skills/save-image/README.md
commit "bump save-image to 1.0.2 with a README change"
changes save-image-v1.0.1 save-image
run_new
expect_rc 0
expect_has "would tag save-image-v1.0.2 at"

begin i "release-PR shape: a body change merged earlier, then a commit that only bumps + changelog  => would tag"
change_body save-image
commit "reword a heading (no bump yet)"
bump_manifest save-image 1.0.1 1.0.2
bump_frontmatter save-image 1.0.1 1.0.2
add_changelog_section save-image save-image-v1.0.2
commit "release save-image 1.0.2 (version + changelog only)"
changes save-image-v1.0.1 save-image
say "last commit alone touches: $(git diff --name-only HEAD~1 HEAD | tr '\n' ' ')"
run_new
expect_rc 0
expect_has "would tag save-image-v1.0.2 at"
expect_has "Wording"

begin j "full version-only release: plugin.json + SKILL.md version + CHANGELOG.md, nothing else  => refused"
bump_manifest save-image 1.0.1 1.0.2
bump_frontmatter save-image 1.0.1 1.0.2
add_changelog_section save-image save-image-v1.0.2
commit "release save-image 1.0.2 (version + changelog only)"
changes save-image-v1.0.1 save-image
run_new
expect_rc 1
expect_has "$REFUSE_SI"

begin k "a 'version:' line in another file of the skill counts (the exemption is for SKILL.md only)  => would tag"
mkdir -p skills/save-image/templates
printf 'name: sample\n  version: "1.0.0"\n' >skills/save-image/templates/sample.yml
commit "add a sample template"
git tag -a save-image-v1.0.2 -m "local test tag"
sedi 's/^  version: "1.0.0"$/  version: "1.0.3"/' skills/save-image/templates/sample.yml
bump_manifest save-image 1.0.1 1.0.3
commit "bump save-image to 1.0.3; only the version line of templates/sample.yml changed"
changes save-image-v1.0.2 save-image
run_new
expect_rc 0
expect_has "would tag save-image-v1.0.3 at"

begin l "previous tag = nearest tag in the history, not the highest by name (1.0.0-rc.1 sorts after 1.0.0)"
mkdir -p skills/pre-skill/.claude-plugin
printf '{\n  "name": "pre-skill",\n  "version": "1.0.0-rc.1"\n}\n' >skills/pre-skill/.claude-plugin/plugin.json
printf -- '---\nname: pre-skill\nmetadata:\n  version: "1.0.0-rc.1"\n---\n\n# pre-skill\n\nfirst text\n' >skills/pre-skill/SKILL.md
commit "add pre-skill at 1.0.0-rc.1"
git tag -a pre-skill-v1.0.0-rc.1 -m "local test tag"
sedi 's/^first text$/second text/' skills/pre-skill/SKILL.md
bump_manifest pre-skill 1.0.0-rc.1 1.0.0
bump_frontmatter pre-skill 1.0.0-rc.1 1.0.0
commit "pre-skill 1.0.0 with a real change"
git tag -a pre-skill-v1.0.0 -m "local test tag"
bump_manifest pre-skill 1.0.0 1.0.1
bump_frontmatter pre-skill 1.0.0 1.0.1
commit "bump pre-skill to 1.0.1, nothing else"
say "git tag --sort=-v:refname (highest by name): $(git tag -l 'pre-skill-v*' --sort=-v:refname | head -1)"
say "git describe (nearest in the history):       $(git describe --tags --abbrev=0 --match 'pre-skill-v*' HEAD)"
run_new
expect_rc 1
expect_has "error: refusing to tag pre-skill-v1.0.1: nothing changed in skills/pre-skill/ since pre-skill-v1.0.0 besides"

begin m "TARGET_SHA is the upper bound of the comparison (the workflow passes github.sha)"
bump_manifest save-image 1.0.1 1.0.2
commit "bump save-image to 1.0.2 (plugin.json only)"
X="$(git rev-parse HEAD)"
change_body save-image
commit "real change on top"
Y="$(git rev-parse HEAD)"
say "X (bump only) = $X"
say "Y (X + a real change) = $Y"
run_new TARGET_SHA="$X"
expect_rc 1
expect_has "$REFUSE_SI"
run_new TARGET_SHA="$Y"
expect_rc 0
expect_has "would tag save-image-v1.0.2 at $Y"
run_new
expect_rc 0
expect_has "would tag save-image-v1.0.2 at $Y"

begin n "tags exist but none is an ancestor of the commit to tag  => warning, no check, would tag"
bump_manifest save-image 1.0.1 1.0.2
git add -A
tree="$(git write-tree)"
orphan="$(git commit-tree "$tree" -m "orphan commit with no history")"
git switch -q --detach "$orphan"
say "ancestors of $orphan: $(git rev-list --count HEAD) commit(s)"
run_new
expect_rc 0
expect_has "warning: no save-image-v* tag is an ancestor of $orphan"
expect_has "would tag save-image-v1.0.2 at $orphan"

begin q "bump + changes only outside skills/save-image (root README, spec/, another skill)  => refused"
bump_manifest save-image 1.0.1 1.0.2
printf '\nroot readme change\n' >>README.md
printf '\nspec change\n' >>spec/INVENTORY.md
printf '\nother skill change\n' >>skills/senior-mindset/README.md
commit "bump save-image to 1.0.2; changes elsewhere"
changes save-image-v1.0.1 save-image
run_new
expect_rc 1
expect_has "$REFUSE_SI"
expect_has "senior-mindset-v2.2.0 exists — skipping"

begin t "a top-level 'version: 2' line added to the body of SKILL.md is content  => would tag"
bump_manifest save-image 1.0.1 1.0.2
bump_frontmatter save-image 1.0.1 1.0.2
printf '\nversion: 2\n' >>skills/save-image/SKILL.md
commit "bump save-image to 1.0.2; a 'version:' line in the body"
changes save-image-v1.0.1 save-image
run_new
expect_rc 0
expect_has "would tag save-image-v1.0.2 at"

begin y "T-4 rehearsal: senior-mindset 2.2.0 -> 2.2.1 as a version-only commit; T-2's changes since v2.2.0 are already on master  => would tag"
bump_manifest senior-mindset 2.2.0 2.2.1
bump_frontmatter senior-mindset 2.2.0 2.2.1
commit "release senior-mindset 2.2.1 (version only)"
say "last commit alone touches: $(git diff --name-only HEAD~1 HEAD | tr '\n' ' ')"
changes senior-mindset-v2.2.0 senior-mindset
run_new
expect_rc 0
expect_has "would tag senior-mindset-v2.2.1 at"
expect_has "save-image-v1.0.1 exists — skipping"
expect_lacks "refusing"

begin r "git diff fails (simulated): the script stops with an error instead of letting the tag through"
bump_manifest save-image 1.0.1 1.0.2
commit "bump save-image to 1.0.2 (plugin.json only)"
REAL_GIT="$(command -v git)"
mkdir -p "$WORK/failing-git"
cat >"$WORK/failing-git/git" <<SH
#!/usr/bin/env bash
if [ "\$1" = diff ]; then echo "fatal: simulated failure" >&2; exit 128; fi
exec "$REAL_GIT" "\$@"
SH
chmod +x "$WORK/failing-git/git"
run_new PATH="$WORK/failing-git:$PATH"
expect_rc 1
expect_has "failed with status 128"
expect_lacks "would tag"

begin s "SKILL.md with CRLF line endings: a bump that only changes the version line is still refused"
to_crlf skills/save-image/SKILL.md
commit "convert SKILL.md to CRLF"
say "CR characters in the committed SKILL.md: $(git show HEAD:skills/save-image/SKILL.md | grep -c $'\r')"
git tag -a save-image-v1.0.2 -m "local test tag"
bump_manifest save-image 1.0.1 1.0.3
sedi 's/version: "1\.0\.1"/version: "1.0.3"/' skills/save-image/SKILL.md
commit "bump save-image to 1.0.3 (plugin.json + SKILL.md version line)"
changes save-image-v1.0.2 save-image
run_new
expect_rc 1
expect_has "error: refusing to tag save-image-v1.0.3: nothing changed in skills/save-image/ since save-image-v1.0.2 besides"

begin w "the skill folder comes from the manifest path, not from the plugin name (skills/dir-x holds plugin name-y)"
mkdir -p skills/dir-x/.claude-plugin
printf '{\n  "name": "name-y",\n  "version": "1.0.0"\n}\n' >skills/dir-x/.claude-plugin/plugin.json
printf -- '---\nname: name-y\nmetadata:\n  version: "1.0.0"\n---\n\n# name-y\n' >skills/dir-x/SKILL.md
commit "add skills/dir-x (plugin name-y)"
git tag -a name-y-v1.0.0 -m "local test tag"
bump_manifest dir-x 1.0.0 1.0.1
commit "bump name-y to 1.0.1, nothing else"
run_new
expect_rc 1
expect_has "error: refusing to tag name-y-v1.0.1: nothing changed in skills/dir-x/ since name-y-v1.0.0 besides the version and changelog"

say
say "################ Real mode (no DRY_RUN): scratch bare remote + fake gh ################"
say "(a clone whose origin is a scratch bare repository in the temp folder: nothing leaves this machine)"
git switch -q --detach "$BASE" && git clean -fdq && drop_extra_tags
REALDIR="$WORK/real"
export GH_CALLS_LOG="$WORK/gh-calls.log"
: >"$GH_CALLS_LOG"
git clone -q --bare "$CLONE" "$WORK/remote.git" || die "bare clone"
git -C "$WORK/remote.git" remote remove origin
git clone -q "$WORK/remote.git" "$REALDIR" || die "clone of the remote"
cd "$REALDIR" || die "cd real"
git config user.name "Scratch Tester"
git config user.email "scratch@example.invalid"
git config core.autocrlf false
git config commit.gpgsign false
git config tag.gpgsign false
git config advice.detachedHead false
git switch -q --detach "$BASE"
say "origin of the second clone: $(git remote get-url origin)"
say "push check: the fake gh is only on PATH in run_real: $(command -v gh || echo 'no gh on PATH')"

run_real() {  # the script without DRY_RUN, with the fake gh first in PATH
  OUT="$(env PATH="$HERE/fakebin:$PATH" GH_TOKEN=fake "$@" bash .github/scripts/tag-skill-releases.sh 2>&1)"; RC=$?
  say "\$ GH_TOKEN=fake PATH=<fakebin>:\$PATH bash .github/scripts/tag-skill-releases.sh   # real mode"
  say "$OUT"
  say "exit=$RC"
}
remote_has() { git -C "$WORK/remote.git" tag -l "$1" | grep -qx "$1"; }

say
new_case x1 "real mode: save-image bump-only (refused) + senior-mindset bump with a real change (tagged)"
say "=== x1. ${CASE_TITLE[x1]}"
git tag -a senior-mindset-v2.2.1 -m "local test tag"
bump_manifest save-image 1.0.1 1.0.2
bump_manifest senior-mindset 2.2.0 2.2.2
bump_frontmatter senior-mindset 2.2.0 2.2.2
printf '\nA real change.\n' >>skills/senior-mindset/README.md
git add -A && git commit -q -m "bump both skills; only senior-mindset has a real change"
run_real
expect_rc 1
expect_has "error: refusing to tag save-image-v1.0.2: nothing changed in skills/save-image/ since save-image-v1.0.1 besides the version and changelog"
expect_has "tagged and released senior-mindset-v2.2.2"
if git tag -l | grep -qx 'senior-mindset-v2.2.2'; then ok "local tag senior-mindset-v2.2.2 created"; else bad "local tag senior-mindset-v2.2.2 missing"; fi
if remote_has senior-mindset-v2.2.2; then ok "tag senior-mindset-v2.2.2 pushed to the scratch remote"; else bad "tag not pushed"; fi
if git tag -l | grep -qx 'save-image-v1.0.2'; then bad "save-image-v1.0.2 was created"; else ok "no local tag save-image-v1.0.2"; fi
if remote_has save-image-v1.0.2; then bad "save-image-v1.0.2 was pushed"; else ok "no remote tag save-image-v1.0.2"; fi
say "gh calls: $(tr '\n' '|' <"$GH_CALLS_LOG")"
if [ "$(wc -l <"$GH_CALLS_LOG")" -eq 1 ] && grep -q '^gh release create senior-mindset-v2.2.2 ' "$GH_CALLS_LOG"; then ok "exactly one release, for senior-mindset-v2.2.2"; else bad "unexpected gh calls"; fi

say
new_case x2 "real mode, after a real change lands in save-image: the same bump is now tagged, exit 0"
say "=== x2. ${CASE_TITLE[x2]}"
printf '\nOne more sentence.\n' >>skills/save-image/README.md
git add -A && git commit -q -m "a real change in save-image"
run_real
expect_rc 0
expect_has "tagged and released save-image-v1.0.2"
expect_has "senior-mindset-v2.2.2 exists — skipping"
expect_lacks "refusing"
if remote_has save-image-v1.0.2; then ok "tag save-image-v1.0.2 pushed to the scratch remote"; else bad "tag not pushed"; fi
say "gh calls: $(tr '\n' '|' <"$GH_CALLS_LOG")"
if [ "$(wc -l <"$GH_CALLS_LOG")" -eq 2 ]; then ok "two releases in total"; else bad "unexpected gh calls"; fi


say
say "################ Summary ################"
for id in "${CASE_ORDER[@]}"; do
  p=${CASE_PASS[$id]:-0}; f=${CASE_FAIL[$id]:-0}
  if [ "$f" -eq 0 ]; then verdict=PASS; else verdict=FAIL; fi
  printf '%-5s %-4s %3d checks  %s\n' "$id" "$verdict" "$((p + f))" "${CASE_TITLE[$id]}"
done
say "passed: $pass   failed: $fail"
[ "$fail" -eq 0 ]
