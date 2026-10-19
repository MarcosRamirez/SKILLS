#!/usr/bin/env bash
# Marks the specs named in a merged PR body ("Closes-Spec: SPEC-NNNN") as Implemented.
# A spec is a feature (spec/features/) or a fix (spec/fixes/); both share one SPEC-NNNN numbering,
# so a number must match exactly one spec across all the spec folders.
#
# For each spec it:
#   - sets the spec to "Status: Implemented" + "Implemented: <date>, PR #<n>"
#       folder spec:  <spec folder>/NNNN-<slug>/spec.md
#       single file:  <spec folder>/NNNN-<slug>.md
#   - sets the plan (folder spec: plan*.md inside it) to "Status: Done" + "Done: <date>, PR #<n>"
#   - sets the spec's row in the roadmap to Implemented
# Everything is validated before anything is written, so a failure leaves no half-closed spec.
#
# Inputs (env):
#   PR_BODY       body of the merged PR — untrusted, only ever read from this variable
#   PR_NUMBER     number of the merged PR
#   SPEC_DIRS     spec folders to look in, space-separated. Default: "spec/features spec/fixes".
#                 A folder that does not exist is skipped (no spec/fixes yet is fine).
#   FEATURES_DIR  legacy: when set, it is the only folder looked in and SPEC_DIRS is ignored
#   ROADMAP       default: spec/constitution/roadmap.md (missing roadmap is fine)
# Output: prints every file it changed, one per line. Changes nothing else.
set -euo pipefail

: "${PR_BODY:?PR_BODY is required}"
: "${PR_NUMBER:?PR_NUMBER is required}"
ROADMAP="${ROADMAP:-spec/constitution/roadmap.md}"
STATUS_RE='^[[:space:]]*(- )?Status:'

# FEATURES_DIR is one folder, kept whole even if its path has spaces; SPEC_DIRS is a list.
if [ -n "${FEATURES_DIR:-}" ]; then
  spec_dirs=("$FEATURES_DIR")
else
  read -r -a spec_dirs <<<"${SPEC_DIRS:-spec/features spec/fixes}"
fi
if [ "${#spec_dirs[@]}" -eq 0 ]; then
  echo "error: SPEC_DIRS lists no folder" >&2
  exit 1
fi

if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "error: PR_NUMBER '$PR_NUMBER' is not a number" >&2
  exit 1
fi

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

# set_status <file> <new status> <extra line>: replace the first Status line, add the extra line after it.
set_status() {
  local file="$1" status="$2" extra="$3"
  awk -v status="$status" -v extra="$extra" -v re="$STATUS_RE" '
    !done && $0 ~ re { print "Status: " status; print extra; done = 1; next }
    { print }
  ' "$file" >"$file.tmp"
  mv "$file.tmp" "$file"
}

for spec_id in "${spec_ids[@]}"; do
  if ! [[ "$spec_id" =~ ^SPEC-([0-9]{4})$ ]]; then
    echo "error: invalid spec id '$spec_id' (expected SPEC-NNNN)" >&2
    exit 1
  fi
  number="${BASH_REMATCH[1]}"

  # ---- locate and validate everything first ----
  # Look in every spec folder, as a folder spec (NNNN-*/spec.md) and as a single file (NNNN-*.md).
  # A folder that does not exist has no match, so a project without spec/fixes is not an error.
  shopt -s nullglob
  matches=()
  for dir in "${spec_dirs[@]}"; do
    matches+=("$dir"/"$number"-*/spec.md "$dir"/"$number"-*.md)
  done
  shopt -u nullglob
  if [ "${#matches[@]}" -eq 0 ]; then
    echo "error: no spec found for $spec_id in ${spec_dirs[*]} — nothing changed" >&2
    exit 1
  fi
  if [ "${#matches[@]}" -gt 1 ]; then
    echo "error: $spec_id matches more than one spec (a number is used once) — nothing changed" >&2
    printf '  %s\n' "${matches[@]}" >&2
    exit 1
  fi
  spec_file="${matches[0]}"

  plan_file=""
  if [[ "$spec_file" == */spec.md ]]; then
    # folder spec: its plan is inside the same folder
    shopt -s nullglob
    plans=("$(dirname "$spec_file")"/plan*.md)
    shopt -u nullglob
    if [ "${#plans[@]}" -gt 1 ]; then
      echo "error: more than one plan for $spec_id — nothing changed" >&2
      exit 1
    fi
    [ "${#plans[@]}" -eq 1 ] && plan_file="${plans[0]}"
  fi

  status_line="$(grep -m1 -E "$STATUS_RE" "$spec_file" || true)"
  if [ -z "$status_line" ]; then
    echo "error: no 'Status:' line in $spec_file — nothing changed" >&2
    exit 1
  fi
  if [ -n "$plan_file" ] && ! grep -qE "$STATUS_RE" "$plan_file"; then
    echo "error: no 'Status:' line in $plan_file — nothing changed" >&2
    exit 1
  fi

  spec_done=0
  if grep -qi 'Implemented' <<<"$status_line"; then
    spec_done=1
    echo "$spec_id already Implemented — checking plan and roadmap" >&2
  elif ! grep -qi 'Approved' <<<"$status_line"; then
    echo "error: $spec_id is not Approved ($status_line); a merged PR cannot close an unapproved spec" >&2
    exit 1
  fi

  # ---- write ----
  if [ "$spec_done" -eq 0 ]; then
    set_status "$spec_file" "Implemented" "Implemented: $today, PR #$PR_NUMBER"
    echo "$spec_file"
  fi

  if [ -n "$plan_file" ] && ! grep -m1 -E "$STATUS_RE" "$plan_file" | grep -qi 'Done'; then
    set_status "$plan_file" "Done" "Done: $today, PR #$PR_NUMBER"
    echo "$plan_file"
  fi

  # Roadmap row: "| SPEC-NNNN | title | tier | <status> | depends |" → status column = Implemented.
  if [ -f "$ROADMAP" ] && grep -qE "^\|[[:space:]]*\[?$spec_id\]?" "$ROADMAP"; then
    before="$(cat "$ROADMAP")"
    awk -v id="$spec_id" -F'|' -v OFS='|' '
      $2 ~ id && $5 !~ /Implemented/ { $5 = " Implemented " }
      { print }
    ' "$ROADMAP" >"$ROADMAP.tmp"
    mv "$ROADMAP.tmp" "$ROADMAP"
    if [ "$before" != "$(cat "$ROADMAP")" ]; then
      echo "$ROADMAP"
    fi
  fi
done
