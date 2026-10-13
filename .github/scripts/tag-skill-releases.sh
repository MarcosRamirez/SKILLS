#!/usr/bin/env bash
# Creates "<name>-v<version>" tags and GitHub Releases for skills whose version has no tag yet.
#
# Inputs (env):
#   TARGET_SHA  commit to tag — the merge commit that bumped the version (default: HEAD)
#   DRY_RUN     "1" prints what would be done without tagging or releasing
#   GH_TOKEN    token for `gh release create` (not needed in dry run)
set -euo pipefail

TARGET_SHA="${TARGET_SHA:-$(git rev-parse HEAD)}"
DRY_RUN="${DRY_RUN:-0}"
PYTHON="${PYTHON:-python3}"
SEMVER_RE='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'

git fetch --quiet --tags origin 2>/dev/null || true

shopt -s nullglob
manifests=(skills/*/.claude-plugin/plugin.json)
shopt -u nullglob
if [ "${#manifests[@]}" -eq 0 ]; then
  echo "no skills/*/.claude-plugin/plugin.json found — nothing to tag" >&2
  exit 0
fi

for manifest in "${manifests[@]}"; do
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

  changelog="skills/$name/CHANGELOG.md"
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
