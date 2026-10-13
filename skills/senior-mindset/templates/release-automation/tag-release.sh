#!/usr/bin/env bash
# Tags v<version> from the project manifest and creates a GitHub Release, once per version.
set -euo pipefail
TARGET_SHA="${TARGET_SHA:-$(git rev-parse HEAD)}"
DRY_RUN="${DRY_RUN:-0}"
SEMVER_RE='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'

if [ -f package.json ]; then
  version="$(node -p "require('./package.json').version")"
elif [ -f pyproject.toml ]; then
  version="$(python3 -c 'import tomllib; print(tomllib.load(open("pyproject.toml","rb"))["project"]["version"])')"
elif [ -f Cargo.toml ]; then
  version="$(python3 -c 'import tomllib; print(tomllib.load(open("Cargo.toml","rb"))["package"]["version"])')"
else
  echo "no package.json, pyproject.toml or Cargo.toml — nothing to tag" >&2; exit 0
fi
version="${version%$'\r'}"
[[ "$version" =~ $SEMVER_RE ]] || { echo "error: version '$version' is not SemVer" >&2; exit 1; }

tag="v$version"
git fetch --quiet --tags origin 2>/dev/null || true  # no remote yet: tags are checked locally
if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  echo "$tag exists — skipping" >&2; exit 0
fi

notes="$(mktemp)"
[ -f CHANGELOG.md ] && awk -v head="## [$version]" '
  index($0, head) == 1 { inside = 1; next }
  inside && /^## \[/ { exit }
  inside { print }' CHANGELOG.md >"$notes"
[ -s "$notes" ] || echo "Release $tag." >"$notes"

flags=(); [[ "$version" == *-* ]] && flags=(--prerelease)
if [ "$DRY_RUN" = "1" ]; then echo "would tag $tag at $TARGET_SHA ${flags[*]:-}"; cat "$notes"; exit 0; fi

git tag -a "$tag" "$TARGET_SHA" -m "$tag"
git push --quiet origin "refs/tags/$tag"
gh release create "$tag" --title "$tag" --notes-file "$notes" --verify-tag "${flags[@]}"
