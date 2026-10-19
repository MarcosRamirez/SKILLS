#!/usr/bin/env bash
# Creates "<name>-v<version>" tags and GitHub Releases for skills whose version has no tag yet.
#
# A version moves only when something users can run changed (SPEC-0023). So a new tag is refused
# when nothing changed in the skill's folder since its previous "<name>-v*" tag, not counting
# CHANGELOG.md, .claude-plugin/plugin.json and the version line of SKILL.md. A skill's first tag
# has nothing to compare with and passes. A refusal prints an error and a GitHub Actions
# annotation, the other skills are still handled, and the script exits 1 at the end (also with
# DRY_RUN=1, which reports the refusals too).
#
# Inputs (env):
#   TARGET_SHA  commit to tag — the merge commit that bumped the version (default: HEAD)
#   DRY_RUN     "1" prints what would be done without tagging or releasing
#   GH_TOKEN    token for `gh release create` (not needed in dry run)
#
# Exit status: 0 when every new version was tagged (or would be) or is already tagged;
#              1 when a manifest is invalid or at least one tag was refused.
set -euo pipefail

TARGET_SHA="${TARGET_SHA:-$(git rev-parse HEAD)}"
DRY_RUN="${DRY_RUN:-0}"
PYTHON="${PYTHON:-python3}"
SEMVER_RE='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'
# A SKILL.md line that holds only the version, e.g. `  version: "1.0.2"` (metadata.version).
# It must be indented, so a top-level line of the body is not taken for it.
VERSION_LINE_RE="^[[:space:]]+version:[[:space:]]*[\"']?[0-9][^[:space:]]*[[:space:]]*\$"
refused=0

# `git diff --quiet "$@"` as a test: succeeds when the trees differ, fails when they do not.
# Any other git status is a real failure, and it stops the script instead of letting a tag through.
differs() {
  local status=0
  git diff --quiet "$@" || status=$?
  case "$status" in
    0) return 1 ;;
    1) return 0 ;;
    *) echo "error: git diff --quiet $* failed with status $status" >&2; exit 1 ;;
  esac
}

# SKILL.md ($2) as it is at commit $1, without the lines that hold only the version.
skill_text() {
  git show "$1:$2" 2>/dev/null | grep -avE "$VERSION_LINE_RE" || true
}

# Succeeds when the skill folder $1 differs between the commits $2 and $3 in a way that counts.
changed_since() {
  local dir="$1" from="$2" to="$3"
  # Every file except the three that change with each release: any difference counts.
  if differs "$from" "$to" -- "$dir" ":(exclude)$dir/CHANGELOG.md" \
    ":(exclude)$dir/.claude-plugin/plugin.json" ":(exclude)$dir/SKILL.md"; then
    return 0
  fi
  # SKILL.md counts when its text changed apart from the version lines. Other files keep theirs:
  # a `version:` line there is content.
  [ "$(skill_text "$from" "$dir/SKILL.md")" != "$(skill_text "$to" "$dir/SKILL.md")" ]
}

git fetch --quiet --tags origin 2>/dev/null || true

shopt -s nullglob
manifests=(skills/*/.claude-plugin/plugin.json)
shopt -u nullglob
if [ "${#manifests[@]}" -eq 0 ]; then
  echo "no skills/*/.claude-plugin/plugin.json found — nothing to tag" >&2
  exit 0
fi

for manifest in "${manifests[@]}"; do
  skill_dir="${manifest%/.claude-plugin/plugin.json}"
  read -r name version < <("$PYTHON" -c '
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
print(data.get("name", ""), data.get("version", ""))
' "$manifest")
  # Strip a trailing CR (Python on Windows prints CRLF) so local runs match CI.
  name="${name%$'\r'}"
  version="${version%$'\r'}"

  if [ -z "$name" ] || [ -z "$version" ]; then
    echo "error: $manifest needs both name and version" >&2
    exit 1
  fi
  if ! [[ "$version" =~ $SEMVER_RE ]]; then
    echo "error: $manifest version '$version' is not SemVer" >&2
    exit 1
  fi

  tag="$name-v$version"
  if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    echo "$tag exists — skipping" >&2
    continue
  fi

  # The previous release is the nearest "<name>-v*" tag in the history of the commit to tag. The
  # commit graph decides, not the order of the tag names: git sorts 1.0.0-rc.1 after 1.0.0 unless
  # versionsort.suffix is set. A skill with no tag yet has nothing to compare with and passes.
  previous_tag="$(git describe --tags --abbrev=0 --match "$name-v*" "$TARGET_SHA" 2>/dev/null || true)"
  if [ -z "$previous_tag" ] && [ -n "$(git tag -l "$name-v*")" ]; then
    echo "warning: no $name-v* tag is an ancestor of $TARGET_SHA — not checking what changed in $skill_dir/" >&2
  fi
  if false; then
    message="refusing to tag $tag: nothing changed in $skill_dir/ since $previous_tag besides the version and changelog"
    echo "error: $message" >&2
    echo "::error::$message"
    refused=$((refused + 1))
    continue
  fi

  changelog="$skill_dir/CHANGELOG.md"
  notes_file="$(mktemp)"
  if [ -f "$changelog" ]; then
    # Section from "## [<tag>]" up to the next "## [" heading.
    awk -v head="## [$tag]" '
      index($0, head) == 1 { inside = 1; next }
      inside && /^## \[/ { exit }
      inside { print }
    ' "$changelog" >"$notes_file"
  fi
  [ -s "$notes_file" ] || echo "Release $tag." >"$notes_file"

  prerelease_flag=()
  [[ "$version" == *-* ]] && prerelease_flag=(--prerelease)

  if [ "$DRY_RUN" = "1" ]; then
    echo "would tag $tag at $TARGET_SHA ${prerelease_flag[*]:-} — notes:"
    sed 's/^/  | /' "$notes_file"
    rm -f "$notes_file"
    continue
  fi

  git tag -a "$tag" "$TARGET_SHA" -m "$name $version"
  git push --quiet origin "refs/tags/$tag"
  gh release create "$tag" --title "$name $version" --notes-file "$notes_file" --verify-tag "${prerelease_flag[@]}"
  rm -f "$notes_file"
  echo "tagged and released $tag"
done

if [ "$refused" -gt 0 ]; then
  echo "error: $refused skill version(s) refused, see above" >&2
  exit 1
fi
