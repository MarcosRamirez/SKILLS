# Project layout

## Standard tree

```text
spec/                           everything Spec-Driven Development: the "why" and "how"
  constitution/                 (or a single spec/constitution.md in small projects)
    mission.md                  what we build and for whom — written and approved by the user
    tech-stack.md               stack and conventions, derived from the ADRs (not edited by hand)
    roadmap.md                  order of the specs and their state (the bot updates the state)
  features/                     new or changed behaviour (refactors and upgrades too)
    0001-user-auth/             a normal feature: three files
      spec.md                   WHAT and WHY
      plan.medium.md            HOW: design + steps with the recommended tier (tier as suffix)
      tasks.md                  checklist → branches and commits
    0002-csv-export.md          a small feature: one file with Spec / Plan / Tasks
  fixes/                        behaviour that is wrong; same SPEC-NNNN numbering as features
    0003-cursor-skips-rows.md   a fix: one file with Spec / Plan / Tasks (a folder only when large)
  adr/
    README.md                   index: # | title | status
    0001-use-postgresql.md
  api/
    openapi.yaml                API contract (if there is an API)
  INVENTORY.md                  map of what already exists — check before creating
  POSTMORTEMS.md                register of fixed bugs and their lessons — created at the first bug
<code>/                         the application code, separate from spec/ — the user chooses
                                where at kickoff: src/ (recommended), app/, apps/<name>/ or any
                                folder they type (see below)
AGENTS.md                       conventions summary + links (read every session, by every agent)
CLAUDE.md                       only if one already existed: `@AGENTS.md` + Claude Code-only content
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
| **`app/`** | The whole project (configs, `src/`, tests) inside `app/`; the root keeps only `spec/`, `AGENTS.md`, `.github/` | A clean root with one deployable |
| **`apps/<name>/`** | One folder per deployable (`apps/web`, `apps/api`) with a workspace tool (pnpm/npm workspaces, uv workspace, Cargo workspace) | Several deployables (monorepo) |
| **Another folder** | Whatever the user types, e.g. `backend/` + `frontend/`, `packages/core/` | The user's own conventions |

- **A typed folder is validated before use:** a relative path inside the repo, no `..`, not absolute,
  not `spec/`, `.github/` or `.git/`, only letters, digits, `-`, `_`, `.` and `/`. If it is invalid,
  say why and ask again.
- Record the answer in AGENTS.md (`Code: src/`). Paths in specs, plans, CI and scripts follow it.
- Hexagonal layers, when there is a domain, go in the language's source folder: `src/domain/…`
  with `src/`, `app/src/domain/…` with `app/` (see architecture.md).
- CI runs from the code folder when it is not the root (`working-directory: app`, or a matrix over `apps/*`).
- Projects without a domain (landing pages, content sites) use the framework's native structure inside the code folder.
- **Existing projects are not asked:** do not move the code; record where it already lives
  (`Code: src/`, `Code: packages/*`).

## Naming

- Specs and ADRs: 4-digit sequential prefix + English kebab-case slug: `0007-rate-limiting`.
- **Features and fixes share one numbering.** Next number: highest existing + 1 across
  `spec/features/` and `spec/fixes/`, folders and single files alike. A number is used once, in one folder.
- **The folder tells the type, and the header repeats it** (`Type: feature` or `Type: fix`; specs
  written before this rule have no `Type:` line, and the folder still tells):
  - `spec/features/`: new or changed behaviour. Refactors and upgrades go here too, with acceptance
    criteria stating that behaviour does not change.
  - `spec/fixes/`: behaviour that is wrong (a bug). Create it with the first fix spec; a project
    that only has `spec/features/` is fine as it is.
- `spec/POSTMORTEMS.md` is one file, rows `PM-NNNN`. Method and template: [postmortem.md](postmortem.md).
- References in text and commits: `SPEC-0007`, `PLAN-0007`, `ADR-0007`.
- Inside a spec folder, fixed names: `spec.md`, `plan.<tier>.md` (`high` / `medium` / `low`), `tasks.md`.
- A fix is one file by default, `spec/fixes/NNNN-<slug>.md`, with `## Spec`, `## Plan` and `## Tasks`.
  Only a large fix becomes a folder with the fixed names above. Templates: [sdd.md](sdd.md).

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

## AGENTS.md section (written after the kickoff interview)

It goes in `AGENTS.md` at the project root; see [agents-md.md](agents-md.md) for what happens
when the project already has a `CLAUDE.md`.

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

**Git rules that always hold** (kept here so they apply even when senior-mindset does not load):
- Changes reach `master` through pull requests that the user merges.
- Never merge, push or force-push unless the user asks.
- Confirm with a closed question (options to pick), never by assuming.

Before creating anything, check [spec/INVENTORY.md](spec/INVENTORY.md); before a spec or a release, read [spec/POSTMORTEMS.md](spec/POSTMORTEMS.md) once it exists.
Features: spec/features/ · Fixes: spec/fixes/ · ADRs: [spec/adr/README.md](spec/adr/README.md)
```
