# Impact sweep (SPEC-0025): accepting an ADR that supersedes another updates every living document
# that states the old decision, in the same change, and leaves history and code alone. The project
# is the Tasklog one of the SPEC-0025 T-3 run: PostgreSQL -> SQLite.
#
# Expected: a new ADR with ## Impact and Replaces terms; ADR-0001 changed only in its status line;
# README, conventions, tech-stack and the ADR index updated; the Draft spec changed (with a dated
# ## Changelog line); the Implemented spec untouched; application code untouched; the code work
# recorded as a Draft follow-up spec or as an Impact entry.

SCENARIO_DESCRIPTION="superseding an ADR updates the living documents and records the code work as a follow-up"
SCENARIO_PROMPT="We decided to move from PostgreSQL to SQLite for this project: it is single-user and local-first. I approve the decision. Record it as an ADR following the senior-mindset rules and do everything those rules require in the same change. Do not change application code yet."
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*),Bash(python:*),Bash(python3:*)"
SCENARIO_QUESTION_TOOL=error

# Files at the baseline commit that the run must treat in a given way.
OLD_ADR=spec/adr/0001-use-postgresql.md
DRAFT_SPEC=spec/features/0002-sessions.md
IMPLEMENTED_SPEC=spec/features/0001-store-tasks.md
CODE_PATHS=(tasklog requirements.txt)
LIVING_DOCS=(README.md CLAUDE.md spec/constitution/tech-stack.md spec/adr/README.md)

scenario_setup() {
  local dir=$1
  init_scratch_repo "$dir"
  mkdir -p "$dir/tasklog" "$dir/spec/adr" "$dir/spec/constitution" "$dir/spec/features" "$dir/spec/fixes"
  cat > "$dir/CLAUDE.md" <<DOC
# Tasklog

A one-user task tracker.

## Engineering conventions

- Language: Python 3, Flask. Code folder: \`tasklog/\`.
- Database: PostgreSQL ([ADR-0001](spec/adr/0001-use-postgresql.md)).
- Decisions: [spec/adr/README.md](spec/adr/README.md). Inventory: [spec/INVENTORY.md](spec/INVENTORY.md).

$(git_rules_block)

Features: spec/features/ · Fixes: spec/fixes/
DOC
  cat > "$dir/README.md" <<'DOC'
# Tasklog

A one-user task tracker.

## Run locally

Tasklog needs a PostgreSQL 16 server (see [ADR-0001](spec/adr/0001-use-postgresql.md)).

```bash
docker run -d --name tasklog-db -e POSTGRES_PASSWORD=dev -p 5432:5432 postgres:16
export DATABASE_URL=postgres://postgres:dev@localhost:5432/postgres
pip install -r requirements.txt
flask --app tasklog.app run
```
DOC
  cat > "$dir/spec/adr/0001-use-postgresql.md" <<'DOC'
# ADR-0001: Use PostgreSQL

Status: Accepted
Date: 2026-10-01

## Context

Tasklog stores tasks and sessions and needs a relational database.

## Options considered

1. **PostgreSQL** - mature, relational, JSONB.
2. **SQLite** - a file, no server.

## Decision

We choose **PostgreSQL**.

## Consequences

- Positive: a mature engine.
- Negative: a server to run, even on a laptop.
DOC
  cat > "$dir/spec/adr/README.md" <<'DOC'
# Architecture decision records

| ADR | Title | Status |
|---|---|---|
| [0001](0001-use-postgresql.md) | Use PostgreSQL | Accepted |
DOC
  printf '# Mission\n\nA task tracker for one person, on their own machine.\n\nStatus: Approved\n' > "$dir/spec/constitution/mission.md"
  cat > "$dir/spec/constitution/tech-stack.md" <<'DOC'
# Tech stack

| Area | Choice | Decision |
|---|---|---|
| Language | Python 3 | - |
| Web | Flask | - |
| Database | PostgreSQL 16 | [ADR-0001](../adr/0001-use-postgresql.md) |
DOC
  printf '# Roadmap\n\n| Spec | Feature | Status |\n|---|---|---|\n| [SPEC-0001](../features/0001-store-tasks.md) | Store tasks | Implemented |\n| [SPEC-0002](../features/0002-sessions.md) | Sessions | Draft |\n' > "$dir/spec/constitution/roadmap.md"
  cat > "$dir/spec/INVENTORY.md" <<'DOC'
# Inventory

- `tasklog/db.py` - database access, PostgreSQL through psycopg
- `tasklog/app.py` - the Flask app
DOC
  cat > "$dir/$IMPLEMENTED_SPEC" <<'DOC'
# SPEC-0001: Store tasks

Type: feature
Status: Implemented
Date: 2026-10-02
Implemented: 2026-10-03

## Requirements

- R-1 Store tasks in a `tasks` table in PostgreSQL.

## Acceptance criteria

- AC-1 A created task is still there after a restart.
DOC
  cat > "$dir/$DRAFT_SPEC" <<'DOC'
# SPEC-0002: Sessions

Type: feature
Status: Draft
Date: 2026-10-05
Approved by:

## Requirements

- R-1 A visitor gets a session cookie.
- R-2 Store sessions in PostgreSQL: a `sessions` table with `data` as JSONB and `expires_at`.

## Acceptance criteria

- AC-1 A session survives a restart.
DOC
  : > "$dir/tasklog/__init__.py"
  cat > "$dir/tasklog/db.py" <<'DOC'
"""Database access."""
import os

import psycopg

DATABASE_URL = os.environ.get("DATABASE_URL", "postgres://postgres:dev@localhost:5432/postgres")


def connect():
    return psycopg.connect(DATABASE_URL)
DOC
  printf 'flask\npsycopg[binary]\n' > "$dir/requirements.txt"
  printf '__pycache__/\n*.pyc\n' > "$dir/.gitignore"
  commit_scratch "$dir" "Add Tasklog"
  git -C "$dir" rev-parse HEAD > "$dir/.git/baseline-commit"
}

baseline() { cat "$1/.git/baseline-commit"; }

assert_new_adr() {  # assert_new_adr PROJECT: new ADR with Options, Decision, Consequences, ## Impact and Replaces terms
  local hit ref file text status=0 part
  hit="$(find_file "$1" '^spec/adr/000[2-9]-.*\.md$|^spec/adr/00[1-9][0-9]-.*\.md$')" || { echo "no new ADR (ADR-0002 or later) in spec/adr/"; return 1; }
  ref="${hit%% *}" file="${hit#* }"
  text="$(file_at "$1" "$ref" "$file")"
  echo "$file on $ref"
  for part in '^## Options' '^## Decision' '^## Consequences' '^## Impact'; do
    printf '%s\n' "$text" | grep -Eq -- "$part" || { echo "missing section: $part"; status=1; }
  done
  if printf '%s\n' "$text" | grep -Ei 'Replaces terms' | grep -Ei 'postgres' | grep -Eiq 'sqlite'; then
    printf '%s\n' "$text" | grep -Ei -m1 'Replaces terms'
  else
    echo "no 'Replaces terms' line mapping PostgreSQL to SQLite"
    status=1
  fi
  return $status
}

adr_ref() { find_file "$1" '^spec/adr/000[2-9]-.*\.md$|^spec/adr/00[1-9][0-9]-.*\.md$' | cut -d' ' -f1; }

assert_old_adr_status_only() {  # assert_old_adr_status_only PROJECT: one line out, one line in, the status
  local project=$1 ref changed removed added
  ref="$(adr_ref "$project")"; [[ -n $ref ]] || { echo "no new ADR, so no change to compare"; return 1; }
  changed="$(diff_between "$project" "$(baseline "$project")" "$ref" -U0 -- "$OLD_ADR" | grep -E '^[+-]' | grep -Ev '^(\+\+\+|---)')"
  removed="$(printf '%s\n' "$changed" | grep -c '^-')"
  added="$(printf '%s\n' "$changed" | grep -c '^+')"
  printf '%s\n' "$changed" | head -6
  [[ $removed -eq 1 && $added -eq 1 ]] && printf '%s\n' "$changed" | grep '^-' | grep -Eq 'Status' && printf '%s\n' "$changed" | grep '^+' | grep -Eq 'Status.*(Superseded|ADR-0*[2-9])'
}

assert_documents_updated() {  # assert_documents_updated PROJECT: changed, and they now say SQLite
  local project=$1 ref doc status=0
  ref="$(adr_ref "$project")"; [[ -n $ref ]] || { echo "no new ADR"; return 1; }
  for doc in "${LIVING_DOCS[@]}"; do
    if [[ -z "$(diff_between "$project" "$(baseline "$project")" "$ref" -- "$doc")" ]]; then
      echo "$doc: unchanged"; status=1
    elif ! file_at "$project" "$ref" "$doc" | grep -Eiq 'sqlite'; then
      echo "$doc: changed but never mentions SQLite"; status=1
    else
      echo "$doc: updated"
    fi
  done
  return $status
}

assert_draft_spec_updated() {  # assert_draft_spec_updated PROJECT
  local project=$1 ref text
  ref="$(adr_ref "$project")"; [[ -n $ref ]] || { echo "no new ADR"; return 1; }
  text="$(file_at "$project" "$ref" "$DRAFT_SPEC")"
  if [[ -z "$(diff_between "$project" "$(baseline "$project")" "$ref" -- "$DRAFT_SPEC")" ]]; then echo "$DRAFT_SPEC unchanged"; return 1; fi
  printf '%s\n' "$text" | grep -Eq '^## Changelog' || { echo "$DRAFT_SPEC has no '## Changelog' section"; return 1; }
  printf '%s\n' "$text" | sed -n '/^## Changelog/,$p' | grep -E -m1 '^- *20[0-9]{2}-[0-9]{2}-[0-9]{2}' || { echo "no dated line under ## Changelog"; return 1; }
}

assert_unchanged() {  # assert_unchanged PROJECT PATH...: no difference from the baseline
  local project=$1 ref out
  shift
  ref="$(adr_ref "$project")"; [[ -n $ref ]] || { echo "no new ADR, nothing to compare"; return 1; }
  out="$(diff_between "$project" "$(baseline "$project")" "$ref" --stat -- "$@")"
  if [[ -n $out ]]; then printf '%s\n' "$out"; return 1; fi
  echo "unchanged on $ref: $*"
}

# The code work is a Draft spec added by the run, or an Impact entry that names the code.
assert_follow_up_recorded() {  # assert_follow_up_recorded PROJECT
  local project=$1 ref file text hit
  ref="$(adr_ref "$project")"; [[ -n $ref ]] || { echo "no new ADR"; return 1; }
  while IFS= read -r file; do
    case $file in spec/features/*|spec/fixes/*) ;; *) continue ;; esac
    git -C "$project" cat-file -e "$(baseline "$project"):$file" 2>/dev/null && continue
    if file_at "$project" "$ref" "$file" | grep -Eiq '^(Status:|\*\*Status)[*: ]*Draft'; then
      echo "new Draft spec: $file"
      return 0
    fi
  done < <(files_at "$project" "$ref")
  hit="$(find_file "$project" '^spec/adr/000[2-9]-.*\.md$|^spec/adr/00[1-9][0-9]-.*\.md$' 'db\.py|tasklog/|requirements')" && { echo "Impact entry naming the code: $hit"; return 0; }
  echo "no new Draft spec, and no ADR line naming tasklog/db.py or requirements.txt"
  return 1
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "new ADR with Options, Decision, Consequences, Impact and Replaces terms" assert_new_adr "$project"
  check "ADR-0001 changed only in its status line" assert_old_adr_status_only "$project"
  check "README, conventions, tech-stack and the ADR index updated" assert_documents_updated "$project"
  check "the Draft spec changed, with a dated ## Changelog line" assert_draft_spec_updated "$project"
  check "the Implemented spec is unchanged" assert_unchanged "$project" "$IMPLEMENTED_SPEC"
  check "application code is unchanged" assert_unchanged "$project" "${CODE_PATHS[@]}"
  check "the code work is a Draft follow-up spec or an Impact entry" assert_follow_up_recorded "$project"
  check "master did not move (the change is on a branch)" assert_master_untouched_at_baseline "$project"
}

assert_master_untouched_at_baseline() {  # assert_master_untouched_at_baseline PROJECT
  local project=$1 now
  now="$(git -C "$project" rev-parse master)"
  if [[ $now == "$(baseline "$project")" ]]; then echo "master still at ${now:0:10}"; return 0; fi
  echo "master moved from $(baseline "$project" | cut -c1-10) to ${now:0:10}"
  return 1
}
