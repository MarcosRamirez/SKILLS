#!/usr/bin/env bash
# Marks the specs named in a merged PR body ("Closes-Spec: SPEC-NNNN") as Implemented.
#
# Inputs (env):
#   PR_BODY    body of the merged PR — untrusted, only ever read from this variable
#   PR_NUMBER  number of the merged PR
#   SPECS_DIR  specs folder (default: docs/specs)
# Output: prints the spec files it changed, one per line. Changes nothing else.
set -euo pipefail

: "${PR_BODY:?PR_BODY is required}"
: "${PR_NUMBER:?PR_NUMBER is required}"
SPECS_DIR="${SPECS_DIR:-docs/specs}"

if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "error: PR_NUMBER '$PR_NUMBER' is not a number" >&2
  exit 1
fi

# Collect ids from lines like "Closes-Spec: SPEC-0005" (several lines or comma-separated).
mapfile -t spec_ids < <(
  printf '%s\n' "$PR_BODY" | tr -d '\r' |
    grep -iE '^[[:space:]]*Closes-Spec:' |
    sed -E 's/^[^:]*:[[:space:]]*//' | tr ',' '\n' |
    sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | grep -v '^$' || true
)

if [ "${#spec_ids[@]}" -eq 0 ]; then
  echo "no Closes-Spec line in PR #$PR_NUMBER — nothing to close" >&2
  exit 0
fi

today="$(date -u +%Y-%m-%d)"

for spec_id in "${spec_ids[@]}"; do
  if ! [[ "$spec_id" =~ ^SPEC-([0-9]{4})$ ]]; then
    echo "error: invalid spec id '$spec_id' (expected SPEC-NNNN)" >&2
    exit 1
  fi
  spec_number="${BASH_REMATCH[1]}"

  shopt -s nullglob
  matches=("$SPECS_DIR"/"$spec_number"-*/spec.md)
  shopt -u nullglob
  if [ "${#matches[@]}" -ne 1 ]; then
    echo "error: expected exactly one $SPECS_DIR/$spec_number-*/spec.md for $spec_id, found ${#matches[@]}" >&2
    exit 1
  fi
  spec_file="${matches[0]}"

  status_line="$(grep -m1 -E '^[[:space:]]*(- )?Status:' "$spec_file" || true)"
  if [ -z "$status_line" ]; then
    echo "error: no 'Status:' line in $spec_file" >&2
    exit 1
  fi
  if grep -qi 'Implemented' <<<"$status_line"; then
    echo "$spec_id already Implemented — skipping" >&2
    continue
  fi
  if ! grep -qi 'Approved' <<<"$status_line"; then
    echo "error: $spec_id is not Approved ($status_line); a merged PR cannot close an unapproved spec" >&2
    exit 1
  fi

  # Replace the first Status line, then add the Implemented line right after it.
  awk -v date="$today" -v pr="$PR_NUMBER" '
    !done && /^[[:space:]]*(- )?Status:/ {
      print "Status: Implemented"
      print "Implemented: " date ", PR #" pr
      done = 1
      next
    }
    { print }
  ' "$spec_file" >"$spec_file.tmp"
  mv "$spec_file.tmp" "$spec_file"
  echo "$spec_file"
done
