# Project layout

## Standard tree

```text
spec/                           everything Spec-Driven Development: the "why" and "how"
  constitution/                 (or a single spec/constitution.md in small projects)
    mission.md                  what we build and for whom — written and approved by the user
    tech-stack.md               stack and conventions, derived from the ADRs (not edited by hand)
    roadmap.md                  order of the features and their state (the bot updates the state)
  features/
    0001-user-auth/             a normal feature: three files
      spec.md                   WHAT and WHY
      plan.medium.md            HOW: design + steps with the recommended tier (tier as suffix)
      tasks.md                  checklist → branches and commits
    0002-fix-login-copy.md      a small feature: one file with Spec / Plan / Tasks
  adr/
    README.md                   index: # | title | status
    0001-use-postgresql.md
  api/
    openapi.yaml                API contract (if there is an API)
  INVENTORY.md                  map of what already exists — check before creating
app/                            the application code, separate from spec/ (see below)
  src/                          hexagonal only when there is a domain (see architecture.md):
    domain/  application/  adapters/inbound/  adapters/outbound/
  tests/   unit/  integration/  e2e/  load/
  package.json · pyproject.toml · …   framework and tooling configs live with the code
CLAUDE.md                       conventions summary + links (read every session)
CHANGELOG.md · cliff.toml       generated changelog (see changelog.md)
.github/                        workflows (see release-automation.md)
.gitignore · .env.example
```

## Code is separate from the spec

- **New projects:** the code goes in `app/`, with its framework and tooling configs inside it.
  `spec/`, `CLAUDE.md`, `.github/` and repo-level files stay at the root.
- **Existing projects:** do not move the code. Record in CLAUDE.md where it lives
  (`Code: src/` or `Code: packages/*`).
- CI and scripts run from the code folder (`working-directory: app`).
- Projects without a domain (landing pages, content sites) use the framework's native structure inside `app/`.

## Naming

- Features and ADRs: 4-digit sequential prefix + English kebab-case slug: `0007-rate-limiting`.
- Next number: highest existing + 1 across `spec/features/`, folders and single files alike.
- References in text and commits: `SPEC-0007`, `PLAN-0007`, `ADR-0007`.
- Inside a feature folder, fixed names: `spec.md`, `plan.<tier>.md` (`high` / `medium` / `low`), `tasks.md`.

## Old layout (`docs/specs`, `docs/plans`, `docs/adr`)

Projects created with senior-mindset 1.x keep their docs under `docs/`. When the skill finds that
layout, it proposes the migration through a change notice, on its own branch:
- `git mv` specs to `spec/features/`;
- move each plan into its feature folder as `plan.<tier>.md`;
- merge `design.md` into the plan's `## Design`;
- move `docs/adr` → `spec/adr`, `docs/INVENTORY.md` → `spec/INVENTORY.md`;
- create the constitution;
- fix links.

History is kept (`git mv`), and nothing is deleted without being merged first.

## CLAUDE.md section (written after the kickoff interview)

```markdown
## Engineering conventions

Managed by the senior-mindset skill. Details and reasons live in the ADRs.

- Mission: [spec/constitution/mission.md](spec/constitution/mission.md)
- Stack: [spec/constitution/tech-stack.md](spec/constitution/tech-stack.md) (ADR-0001…0005)
- Roadmap: [spec/constitution/roadmap.md](spec/constitution/roadmap.md)
- Code: app/
- Naming: TS idiomatic (camelCase / PascalCase / UPPER_SNAKE), kebab-case files
- Git: default branch `master` · Changelog: git-cliff → CHANGELOG.md
- Versioning: SemVer, started at 0.0.1-alpha.1 — current stage = latest git tag
- Lint/format: Biome · Tests: Vitest + Playwright · Package manager: pnpm
- API: REST, OpenAPI 3.1 in spec/api/openapi.yaml

Before creating anything, check [spec/INVENTORY.md](spec/INVENTORY.md).
Features: spec/features/ · ADRs: [spec/adr/README.md](spec/adr/README.md)
```
