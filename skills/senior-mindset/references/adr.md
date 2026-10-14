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

## Impact
Replaces terms: `old` → `new`, ...
| Document | Action |
|---|---|
| README.md (install) | updated in this PR |
| spec/features/0012-.../spec.md | updated in this PR (Changelog line) |
| skill behaviour | follow-up: SPEC-NNNN |
Existing projects/data: none | migration proposed via change notice (SPEC-0008)
```

An ADR may write `none` in Impact with a one-line reason (e.g. "a new decision, nothing describes
it yet"). The section is not optional.

## The impact sweep

A decision lives in its ADR, but READMEs, conventions, the constitution, references and other specs
describe it. The sweep makes the change reach them, in the same PR.

**Living documents** are the ones that must describe the project as it is now: `README.md`,
the conventions in `AGENTS.md` / `CLAUDE.md`, `spec/constitution/*.md`, `references/*.md` (in a
skill), `spec/INVENTORY.md` and `spec/POSTMORTEMS.md`. History is not living: Implemented specs,
ADR files and changelogs stay as written.

**When it runs:** an ADR is accepted or superseded, or a spec changes a convention, a layout or a
behaviour that documents describe.

1. **Search.** `git grep -n "ADR-0005\|0005-use-postgresql\|PostgreSQL\|<files of the area>"`: the
   ADR id and file name, the replaced terms, and the files of the area. Review every hit; a term
   can stay valid elsewhere.
2. **Update in the same PR** the living documents and the text of Draft and Approved specs.
3. **Keep history.** Implemented specs, ADR files and changelogs are not rewritten. A spec whose
   text changes gets a line in its `## Changelog`.
4. **Decided but not implemented:** write "changing in SPEC-NNNN" next to the old description.
   Never hide the change, never claim it early.
5. **Implementation work** (code, config, data) becomes Draft specs, linked from the Impact table
   as `follow-up: SPEC-NNNN`.
6. **Old projects and data.** If a layout, file names or a format change for what already exists,
   list the migration in Impact and propose it through the change notice (SPEC-0008), on a branch.
   Never apply it silently.

The Impact table is the record of the sweep.

**Example:** ADR-0009 (SQLite) supersedes ADR-0005 (PostgreSQL).

```markdown
## Impact
Replaces terms: `PostgreSQL` → `SQLite`, `DATABASE_URL` → `DB_PATH`
| Document | Action |
|---|---|
| README.md (setup) | updated in this PR |
| CLAUDE.md (conventions) | updated in this PR |
| spec/constitution/tech-stack.md | updated in this PR |
| spec/features/0012-reports/spec.md (Draft) | updated in this PR (Changelog line) |
| spec/features/0003-login/spec.md (Implemented) | kept as written |
| code, docker-compose, CI | follow-up: SPEC-0031 (Draft) |
Existing projects/data: migration proposed via change notice (SPEC-0008)
```

The README says "changing in SPEC-0031" for the database until that spec is implemented.

## Index template (spec/adr/README.md)

```markdown
# Architecture Decision Records

| # | Title | Status |
|---|---|---|
| 0001 | Use PostgreSQL | Accepted |
| 0002 | Deploy on Cloudflare | Accepted |
```
