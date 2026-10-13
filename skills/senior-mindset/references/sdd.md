# Spec-Driven Development

No code before an approved spec. Each spec answers three questions, in three files (or in three
sections of one file):
- **what and why** (`spec.md`) — the contract between the user and the implementation;
- **how** (`plan.<tier>.md`) — technical design and execution steps;
- **the checklist** (`tasks.md`) — which makes it executable and testable.

## Spec types

Two types, one numbering: `SPEC-NNNN` is shared, so the roadmap, `Closes-Spec:` and the bot treat
both the same. Every spec header carries `Type: feature` or `Type: fix`.

| Type | Folder | What it covers |
|---|---|---|
| `feature` | `spec/features/` | New or changed behaviour. Refactors, performance work and upgrades go here too, with an acceptance criterion stating that behaviour does not change |
| `fix` | `spec/fixes/` | Behaviour that is wrong: what is wrong, what must stay as it is, the root cause and a test that reproduces it |

Intended behaviour that is not met is a fix. Intended behaviour that changes is a feature.

## Location and naming

- **Normal feature:** `spec/features/NNNN-<slug>/` with `spec.md`, `plan.<tier>.md`, `tasks.md`.
- **Small feature:** `spec/features/NNNN-<slug>.md`, a single file with `## Spec`, `## Plan` and
  `## Tasks` sections. Use it when the whole thing fits on one screen; when it grows, turn it into
  a folder with `git mv`.
- **Fix:** `spec/fixes/NNNN-<slug>.md`, a single file with the same three sections. Only a large fix
  becomes a folder, `spec/fixes/NNNN-<slug>/`, with the same fixed names as a feature.
- 4-digit sequential number (highest existing + 1 across `spec/features/` and `spec/fixes/`),
  English kebab-case slug, referenced as `SPEC-0007`.
- Each new spec, feature or fix, gets a row in `spec/constitution/roadmap.md` ([constitution.md](constitution.md)).

## Lifecycle

`Draft` → (user approves) → `Approved` → (the user merges the spec's last PR) → `Implemented`

Features and fixes follow the same lifecycle.

**`Implemented` is set at merge time, never inside the PR and never by hand.** The last PR of a
spec carries `Closes-Spec: SPEC-NNNN` in its body. When the user merges it, the `on-merge.yml`
workflow does three things ([release-automation.md](release-automation.md)):
- marks the spec Implemented, with the date and PR number;
- sets its plan to `Done`;
- updates its roadmap row.

Checks that only make sense after the merge go in the PR body under "Post-merge checks", not in
`tasks.md`. Without GitHub Actions, the status is set in the next PR (manual fallback).

Edit freely while Draft. After Approved, scope changes go back to the user and are noted in a
`## Changelog` section at the bottom of the spec.

- A spec is ready for approval only when the what (`spec.md`), the plan and the tasks all exist
  (three files, or the three sections of a single file).
- Moving to `Approved` requires the user's explicit approval, recorded as
  `Approved by: <user>, <date>, "<their words>"`. The AI never sets it on its own.
- A spec never jumps from `Draft` to `Implemented`.
- `tasks.md` drives the work: each task (or group of small coupled tasks) gets its own branch and
  at least one commit (see [git.md](git.md)).

## spec.md

```markdown
# SPEC-NNNN: <Title>

Type: feature
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

In a fix, `## Design` is the root cause and the fix.

## tasks.md

```markdown
# SPEC-NNNN tasks

- [ ] T-1 Add `invoices` table migration (AC-1) — test: migration up/down
- [ ] T-2 `CreateInvoice` use case (AC-1, AC-2) — test: unit
- [ ] T-3 `POST /v1/invoices` adapter (AC-2) — test: integration + contract
- [ ] T-4 k6 load script `tests/load/invoices.js` (AC-3)
- [ ] T-5 Update spec/INVENTORY.md
```

Rules: every task references at least one AC; every AC is covered by at least one test; one commit per task.

## Small feature (single file)

```markdown
# SPEC-NNNN: <Title>

Type: feature
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

## Fix (single file)

For behaviour that is wrong. The template follows
[Kiro's bugfix specs](https://kiro.dev/docs/specs/bugfix-specs/): the current, expected and
unchanged behaviour as conditions and responses, then the root cause and the tests that prove it.

```markdown
# SPEC-NNNN: <Title>

Type: fix
Status: Draft
Date: YYYY-MM-DD
Approved by: (empty until the user explicitly approves)
Plan: low — <agent / model> (why)

## Spec

**Problem.** Who hits the bug, what goes wrong, since when (version or commit), why it matters now.

**Current behaviour**
- WHEN <condition> THEN the system <what it does today, and is wrong>

**Expected behaviour**
- WHEN <condition> THEN the system SHALL <what it must do>

**Unchanged behaviour**
- WHEN <condition> THEN the system SHALL CONTINUE TO <what works today and must not move>

**Reproduction**
1. Steps, or the path of the test that fails today.

**Root cause.** Filled in after the analysis: where it breaks and why (file, function, the wrong
assumption). "To be found in T-2" while it is unknown.

**Fix**
- The smallest change that makes the expected behaviour true, and where it goes.

**Acceptance criteria**
- AC-1 A test that reproduces the bug fails before the fix.
- AC-2 The same test passes after the fix.
- AC-3 The unchanged-behaviour tests stay green.
- AC-4 ... whatever else this bug needs (a data check, a limit)

**Out of scope.** ...

## Plan

### Design
The root cause and the fix: decisions with a one-line justification, components touched (reuse
what `spec/INVENTORY.md` lists first), and what must not move.

### Steps
- T-1 Reproduce with a failing test (AC-1) — <tier>
- T-2 Find the root cause and record it in the Spec (AC-1) — <tier>
- T-3 Fix (AC-2, AC-3) — <tier>

### Verification
The reproduction before and after the fix; the unchanged-behaviour tests.

## Tasks
- [ ] T-1 Reproduce with a failing test (AC-1)
- [ ] T-2 Root cause, written in the spec (AC-1)
- [ ] T-3 Fix (AC-2, AC-3)
```

- The first three acceptance criteria are always there; add more only when the bug needs them.
- Unchanged behaviour is the regression guard: name what is close to the bug and must keep working,
  and give each item a test.
- Same single `Status:` line as any single-file spec; the bot closes it the same way.

## When a fix needs a spec

A **trivial fix** gets no spec: a regression test that fails first and a `fix:` commit are enough
(branch `fix/<slug>`, no number).

A fix needs a spec when:
- the root cause is unknown;
- several modules are involved;
- behaviour changes beyond the bug itself;
- there is data loss or a security impact.

**A vulnerability** keeps its details private until the fix is released. Until then, nothing public
(spec, branch name, commit, PR, issue) says how to trigger it or where the root cause is. Ask the
user where the work happens (a private repository or a private security advisory), and publish the
full spec with the release.

## Fix flow

The spec is approved before the first line of the test or the fix (Hard rules). Reading code and
running the app to understand the bug is fine before that. Then:

1. **Reproduce.** Write a test that fails because of the bug and watch it fail; keep the failing
   output for the PR. If it cannot be automated, write the exact steps in Reproduction and run them
   before and after the fix.
2. **Root cause.** Find why it breaks, not only where, and write it in the spec. If it contradicts
   what the spec assumed, go back to the user before fixing (a scope change after Approved).
3. **Fix.** The smallest change that makes the failing test pass, with the unchanged-behaviour
   tests still green. The test stays: it is the regression guard.

- Branch `fix/NNNN-<slug>` (a task of the spec: `fix/NNNN-tN-<slug>`); commit `🐛 fix(<scope>): …`
  ([git.md](git.md)). The last PR carries `Closes-Spec: SPEC-NNNN`.
- A fix is released as a PATCH ([versioning.md](versioning.md)).
