# Spec-Driven Development

No code before an approved spec. Each feature answers three questions in three files:
- **what and why** (`spec.md`) — the contract between the user and the implementation;
- **how** (`plan.<tier>.md`) — technical design and execution steps;
- **the checklist** (`tasks.md`) — which makes it executable and testable.

## Location and naming

- **Normal feature:** `spec/features/NNNN-<slug>/` with `spec.md`, `plan.<tier>.md`, `tasks.md`.
- **Small feature:** `spec/features/NNNN-<slug>.md`, a single file with `## Spec`, `## Plan` and
  `## Tasks` sections. Use it when the whole thing fits on one screen; when it grows, turn it into
  a folder with `git mv`.
- 4-digit sequential number (highest existing + 1), English kebab-case slug, referenced as `SPEC-0007`.
- Each new feature gets a row in `spec/constitution/roadmap.md` ([constitution.md](constitution.md)).

## Lifecycle

`Draft` → (user approves) → `Approved` → (the user merges the feature's last PR) → `Implemented`

**`Implemented` is set at merge time, never inside the PR and never by hand.** The last PR of a
feature carries `Closes-Spec: SPEC-NNNN` in its body. When the user merges it, the `on-merge.yml`
workflow does three things ([release-automation.md](release-automation.md)):
- marks the spec Implemented, with the date and PR number;
- sets its plan to `Done`;
- updates its roadmap row.

Checks that only make sense after the merge go in the PR body under "Post-merge checks", not in
`tasks.md`. Without GitHub Actions, the status is set in the next PR (manual fallback).

Edit freely while Draft. After Approved, scope changes go back to the user and are noted in a
`## Changelog` section at the bottom of the spec.

- A feature is ready for approval only when its spec, plan and tasks exist (three files, or the
  three sections of a single file).
- Moving to `Approved` requires the user's explicit approval, recorded as
  `Approved by: <user>, <date>, "<their words>"`. The AI never sets it on its own.
- A spec never jumps from `Draft` to `Implemented`.
- `tasks.md` drives the work: each task (or group of small coupled tasks) gets its own branch and
  at least one commit (see [git.md](git.md)).

## spec.md

```markdown
# SPEC-NNNN: <Title>

Status: Draft
Date: YYYY-MM-DD
Approved by: (empty until the user explicitly approves)

## Problem
Who has the problem, what it is, why it matters now. Link the mission if relevant.

## Requirements
- R-1 ...
- R-2 ...

## Acceptance criteria
- AC-1 Given ..., when ..., then ...
- AC-2 ...
- AC-3 (non-functional) p95 latency < 300 ms at 200 RPS; error rate < 1%

## Out of scope
- ...

## Open questions
- ... (must be empty before Approved)
```

## plan.<tier>.md

The how, technical and operational, in one place. The full template and its lifecycle are in
[plans.md](plans.md). Its `## Design` section holds what a separate design document used to:
- decisions, each with a one-line justification (project-wide decisions link to their ADR);
- components touched or created, reusing what `spec/INVENTORY.md` lists first;
- data (tables, migrations);
- API (the changed paths in `spec/api/openapi.yaml`);
- security threats and mitigations;
- observability.

## tasks.md

```markdown
# SPEC-NNNN tasks

- [ ] T-1 Add `invoices` table migration (AC-1) — test: migration up/down
- [ ] T-2 `CreateInvoice` use case (AC-1, AC-2) — test: unit
- [ ] T-3 `POST /v1/invoices` adapter (AC-2) — test: integration + contract
- [ ] T-4 k6 load script `app/tests/load/invoices.js` (AC-3)
- [ ] T-5 Update spec/INVENTORY.md
```

Rules: every task references at least one AC; every AC is covered by at least one test; one commit per task.

## Small feature (single file)

```markdown
# SPEC-NNNN: <Title>

Status: Draft
Date: YYYY-MM-DD
Approved by: (empty until the user explicitly approves)
Plan: low — <agent / model> (why)

## Spec
Problem, requirements, acceptance criteria, out of scope — short.

## Plan
Design notes and steps, each with its tier when it differs.

## Tasks
- [ ] T-1 … (AC-1)
```

The single file has one `Status:` line for the whole feature. When it closes, the bot marks it Implemented.
