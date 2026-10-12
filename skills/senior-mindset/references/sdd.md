# Spec-Driven Development

No code before an approved spec. The spec is the contract between the user and the
implementation; the design explains how; the tasks make it executable and testable.

## Location and naming

`docs/specs/NNNN-<slug>/` — 4-digit sequential number (highest existing + 1),
English kebab-case slug. Referenced as `SPEC-0007`. Fixed file names inside.

## Lifecycle

`Draft` → (user approves) → `Approved` → (all tasks done, tests green) → `Implemented`

Edit freely while Draft. After Approved, scope changes go back to the user and are
noted in a `## Changelog` section at the bottom of the spec.

## spec.md

```markdown
# SPEC-NNNN: <Title>

Status: Draft
Date: YYYY-MM-DD

## Problem
Who has the problem, what it is, why it matters now.

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

## design.md

```markdown
# SPEC-NNNN design

## Overview
One paragraph + diagram if it helps.

## Decisions
- System shape, events, API style, language — each with a one-line justification.
- Project-wide decisions link to their ADR: see ADR-0005.

## Components
Modules / use cases / adapters touched or created. Reuse first: list what comes from docs/INVENTORY.md.

## Data
Tables, migrations, entities.

## API
Link to the changed paths in docs/api/openapi.yaml.

## Security
Threats and mitigations (see security.md).

## Observability
What gets logged / traced.

## Risks
What can go wrong and how we would notice.
```

## tasks.md

```markdown
# SPEC-NNNN tasks

- [ ] T-1 Add `invoices` table migration (AC-1) — test: migration up/down
- [ ] T-2 `CreateInvoice` use case (AC-1, AC-2) — test: unit
- [ ] T-3 `POST /v1/invoices` adapter (AC-2) — test: integration + contract
- [ ] T-4 k6 load script `tests/load/invoices.js` (AC-3)
- [ ] T-5 Update docs/INVENTORY.md
```

Rules: every task references at least one AC; every AC is covered by at least one
test; one commit per task.
