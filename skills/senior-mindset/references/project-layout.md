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
<code>/                         the application code, separate from spec/ — the user chooses
                                where at kickoff: src/ (recommended), app/, apps/<name>/ or any
                                folder they type (see below)
CLAUDE.md                       conventions summary + links (read every session)
CHANGELOG.md · cliff.toml       generated changelog (see changelog.md)
.github/                        workflows (see release-automation.md)
.gitignore · .env.example
```

## Where the code goes (asked at kickoff)

The code never mixes with `spec/`, but **the user decides where it lives**. Kickoff question
(question tool, recommended option first, plus the free-text field):

| Option | Layout | Good for |
|---|---|---|
| **`src/`** (Recommended for one app) | Manifests and configs at the root (`package.json`, `pyproject.toml`…), code in `src/`, tests in `tests/` | What most frameworks expect; a single app |
| **`app/`** | The whole project (configs, `src/`, tests) inside `app/`; the root keeps only `spec/`, `CLAUDE.md`, `.github/` | A clean root with one deployable |
| **`apps/<name>/`** | One folder per deployable (`apps/web`, `apps/api`) with a workspace tool (pnpm/npm workspaces, uv workspace, Cargo workspace) | Several deployables (monorepo) |
| **Another folder** | Whatever the user types, e.g. `backend/` + `frontend/`, `packages/core/` | The user's own conventions |

- **A typed folder is validated before use:** a relative path inside the repo, no `..`, not absolute,
  not `spec/`, `.github/` or `.git/`, only letters, digits, `-`, `_`, `.` and `/`. If it is invalid,
  say why and ask again.
- Record the answer in CLAUDE.md (`Code: src/`). Paths in specs, plans, CI and scripts follow it.
- Hexagonal layers, when there is a domain, go in the language's source folder: `src/domain/…`
  with `src/`, `app/src/domain/…` with `app/` (see architecture.md).
- CI runs from the code folder when it is not the root (`working-directory: app`, or a matrix over `apps/*`).
- Projects without a domain (landing pages, content sites) use the framework's native structure inside the code folder.
- **Existing projects are not asked:** do not move the code; record where it already lives
  (`Code: src/`, `Code: packages/*`).

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
- Code: src/
- Naming: TS idiomatic (camelCase / PascalCase / UPPER_SNAKE), kebab-case files
- Git: default branch `master` · Changelog: git-cliff → CHANGELOG.md
- Versioning: SemVer, started at 0.0.1-alpha.1 — current stage = latest git tag
- Lint/format: Biome · Tests: Vitest + Playwright · Package manager: pnpm
- API: REST, OpenAPI 3.1 in spec/api/openapi.yaml

Before creating anything, check [spec/INVENTORY.md](spec/INVENTORY.md).
Features: spec/features/ · ADRs: [spec/adr/README.md](spec/adr/README.md)
```
