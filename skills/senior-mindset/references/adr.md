# Architecture Decision Records

An ADR records **one** significant decision, the context that forced it and the
alternatives that lost. It is how the project remembers *why*.

## When to write one

- Kickoff interview decisions: stack, database, platform, architecture, logging, API style.
- A decision in the plan's `## Design` that reaches beyond its feature: a library, pattern,
  language, platform service, protocol.
- Reversing or replacing an earlier decision.

Not for: decisions local to one feature (those live in the plan's `## Design`).

## Rules

- File: `spec/adr/NNNN-<slug>.md` — sequential, English kebab-case, phrased as the
  decision (`0003-use-hexagonal-architecture.md`). Referenced as `ADR-0003`.
- **Immutable once Accepted.** To change a decision, write a new ADR and set the old
  one's status to `Superseded by ADR-00XX` (status line only — leave the body intact).
- Keep `spec/adr/README.md` updated: `| NNNN | Title | Status |`.

## Template (lightweight MADR)

```markdown
# ADR-NNNN: <Decision as a short imperative phrase>

Status: Proposed | Accepted | Superseded by ADR-00XX
Date: YYYY-MM-DD

## Context
The forces at play: requirements, constraints, team, cost, deadlines.

## Options considered
1. **Option A** — pros / cons
2. **Option B** — pros / cons
3. **Option C** — pros / cons

## Decision
We choose **Option B** because ...

## Consequences
- Positive: ...
- Negative / accepted trade-offs: ...
- Follow-ups: ...
```

## Index template (spec/adr/README.md)

```markdown
# Architecture Decision Records

| # | Title | Status |
|---|---|---|
| 0001 | Use PostgreSQL | Accepted |
| 0002 | Deploy on Cloudflare | Accepted |
```
