# Constitution: mission, tech stack, roadmap

The constitution is what every feature is measured against. It lives in `spec/constitution/`,
as three files, or in a single `spec/constitution.md` in small projects.

| File | Answers | Who writes it |
|---|---|---|
| `mission.md` | What we build, for whom, why | The user, helped by the AI; the user approves it |
| `tech-stack.md` | Which technologies and conventions | Derived from the ADRs; never edited by hand |
| `roadmap.md` | In which order the specs (features and fixes) come, and where each one stands | The AI adds rows; the bot updates states on merge |

## mission.md

Asked at kickoff, before any feature. Use the question tool for closed choices, and plain text for
the open answers. Show the draft and get explicit approval.

```markdown
# Mission

Status: Approved
Approved by: <user>, <date>

## What
One or two sentences: what the product is.

## For whom
Who uses it, and the problem they have today.

## Why now
What makes it worth building now.

## What it is not
Explicit non-goals, so features can be rejected against them.

## Success looks like
Two or three observable outcomes.
```

- Each spec's Problem section can link the mission. A feature that contradicts it is flagged to the user.
- A mission change is a decision: record why in an ADR.

## tech-stack.md

A readable summary of the stack and conventions, built **from the ADRs**, so there is a single
source of truth. Regenerate it whenever an ADR is added or superseded.

```markdown
# Tech stack

Derived from the ADRs — do not edit by hand; change the ADR and regenerate.

| Area | Choice | ADR |
|---|---|---|
| Framework | Next.js | [ADR-0001](../adr/0001-use-nextjs.md) |
| Database | PostgreSQL | [ADR-0002](../adr/0002-use-postgresql.md) |
| Platform | Cloudflare | [ADR-0003](../adr/0003-deploy-on-cloudflare.md) |

## Conventions
Naming, linter, formatter, tests, package manager — each linked to its ADR or to AGENTS.md.
```

## roadmap.md

The order of the specs (features and fixes) and their state. It replaces keeping the "what's next" list in chat.

```markdown
# Roadmap

| Spec | Title | Tier | Status | Depends on |
|---|---|---|---|---|
| SPEC-0001 | User sign-up | medium | Implemented | — |
| SPEC-0002 | Task board | high | In progress | SPEC-0001 |
| SPEC-0003 | Email reminders | medium | Draft | SPEC-0002 |
```

- **Order = row order**: the next spec to run is the first row that is not Implemented and whose
  dependencies are Implemented.
- A new spec, feature or fix, gets its row when it is created (state `Draft`).
- States: `Draft` → `Approved` → `In progress` → `Implemented`. The AI updates `Approved` and
  `In progress` in the work branch. **The bot sets `Implemented`** when the `Closes-Spec:` PR is merged
  ([release-automation.md](release-automation.md)). Keep the table format: the bot edits the Status column.
- Reordering is a decision of the user.
