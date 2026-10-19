# Code style

Code is read far more often than it is written. Optimize for the reader.

## Language

- Code, identifiers, comments, commit messages, docs file names: **English**.
- User-facing strings follow the product's locale (use i18n if more than one).

## Naming (idiomatic per language — confirm in the kickoff interview)

| Language | Variables / functions | Types / classes / components | Constants | Files |
|---|---|---|---|---|
| TS / JS | `camelCase` | `PascalCase` | `UPPER_SNAKE_CASE` | `kebab-case.ts` (components may be `PascalCase.tsx` if the framework expects it) |
| Python | `snake_case` | `PascalCase` | `UPPER_SNAKE_CASE` | `snake_case.py` |
| Go | `camelCase` / `PascalCase` (exported) | `PascalCase` | `PascalCase` / `camelCase` | `snake_case.go` |
| Rust | `snake_case` | `PascalCase` | `UPPER_SNAKE_CASE` | `snake_case.rs` |
| SQL | `snake_case` tables (plural) and columns | — | — | `NNNN_description.sql` migrations |
| CSS | `kebab-case` classes | — | `--kebab-case` custom properties | `kebab-case.css` |
| URLs / API paths | `kebab-case`, plural resources | — | — | — |

## Names that reveal intent

- Say what it is, not how it is stored: `activeUsers`, not `list2` or `arr`.
- Booleans read as questions: `isPaid`, `hasAccess`, `canRetry`.
- Functions are verbs: `calculateInvoiceTotal()`, `sendWelcomeEmail()`.
- Units in the name when ambiguous: `timeoutMs`, `priceCents`, `sizeBytes`.
- No cryptic abbreviations (`usrMgr`, `tmpVal2`). Common ones are fine (`id`, `url`, `db`).
- Name length grows with scope: `i` in a 3-line loop, `pendingInvoiceIds` across a module.

## Functions

- One job per function; if you need "and" to describe it, split it.
- Prefer early returns over nested `if`s.
- Few parameters (≤ 3); group the rest in an object/struct.
- Pure where possible; push side effects (I/O, time, randomness) to the edges.

## Comments

- Explain **why** (business rule, workaround, trade-off), never restate **what**.
- Link the source of non-obvious decisions (ADR, issue, official docs URL).
- Delete commented-out code; git remembers it.

## Errors

- Fail fast at boundaries with clear messages; never swallow exceptions silently.
- Domain errors are explicit types, not generic strings.
- Log once, at the boundary that handles the error (see [observability.md](observability.md)).

## Formatting

- Formatter decides; humans do not argue about whitespace.
- Linter + formatter run before every hand-over (and in CI for projects).
