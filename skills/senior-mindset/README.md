# senior-mindset

Makes Claude build software the way a pragmatic senior engineer does — by default,
without you having to repeat it in every prompt.

## What it does

When you ask Claude to build an app or a feature, it:

1. **Sizes the task.** For a one-off script it skips the ceremony. For a project it
   follows the full flow.
2. **Sets up git.** Runs `git init` if needed (default branch `master`, or `main` if you
   prefer: it asks once), writes a safe `.gitignore`, and follows
   your git skill or the built-in convention (`✨ feat(scope): add …`, English, imperative).
3. **Interviews you once per project.** It asks about stack, database, deployment platform,
   architecture, naming, logging and linter, then stores the answers as ADRs plus an
   `## Engineering conventions` section in the project's `CLAUDE.md`. It never asks again.
4. **Writes the spec first (SDD).** `docs/specs/NNNN-slug/` with `spec.md` → `design.md` →
   `tasks.md`, and waits for your approval before writing code.
5. **Evaluates the design.** Monolith or microservices, event-driven or not, test strategy
   (unit, TDD, k6 load tests), contract-first OpenAPI, and the language per component
   (it shows pros and cons, you decide).
6. **Implements.** Reuses what already exists (`docs/INVENTORY.md`), checks official docs first,
   and writes code meant to be read by humans.
7. **Reviews itself.** Lint, tests, OWASP, computational cost, logs without secrets.
8. **Updates the inventory**, so the next session does not reinvent existing tools.

## Install

**Plugin (recommended)**: install and update with one command:

```
/plugin marketplace add MarcosRamirez/SKILLS
/plugin install senior-mindset@marcosramirez-skills
```

**Ask your agent**: paste this into Claude Code:

> Install the senior-mindset skill from https://github.com/MarcosRamirez/SKILLS/tree/master/skills/senior-mindset
> into ~/.claude/skills/senior-mindset. Copy the whole folder, including references/.

**Manual**:

```bash
git clone --depth 1 https://github.com/MarcosRamirez/SKILLS.git /tmp/skills
cp -r /tmp/skills/skills/senior-mindset ~/.claude/skills/senior-mindset
```

The `references/` folder must come along: `SKILL.md` loads those files only when needed.

## Usage

It triggers on its own when you ask to build something:

```
build me a task management app
add password reset to the API
crea una aplicación para gestionar reservas
programa un worker que procese imágenes
```

## Customize your defaults

Edit [references/stack.md](references/stack.md). It holds your default framework,
database, platform and tooling per use case. Rows marked `TODO` make Claude ask you
and suggest 2–3 options.

| File | What it controls |
|---|---|
| `references/stack.md` | Default stack per use case |
| `references/platforms.md` | Hosting options (Cloudflare default) |
| `references/git.md` | Fallback commit convention (used only when no git skill is installed) |
| `references/code-style.md` | Naming conventions per language |
| `references/architecture.md` | When to use hexagonal, SOLID, DRY, KISS |
| `references/security.md` | OWASP Top 10 checklist |
| `references/performance.md` | Computational cost rules |
| `references/sdd.md` · `adr.md` | Spec and ADR templates |
| `references/system-design.md` | Monolith vs microservices, event-driven |
| `references/testing.md` | Test pyramid, TDD, k6 / JMeter |
| `references/api-design.md` | OpenAPI contract-first, REST standards |
| `references/observability.md` | Logging and tracing libraries and rules |
| `references/languages.md` | Choosing a language per component |
| `references/project-layout.md` | Folder tree and CLAUDE.md section |
| `references/inventory-template.md` | `docs/INVENTORY.md` template |

## What it creates in your project

```
CLAUDE.md                     ## Engineering conventions
docs/INVENTORY.md
docs/adr/README.md + NNNN-*.md
docs/specs/NNNN-*/{spec,design,tasks}.md
docs/api/openapi.yaml         (if there is an API)
tests/load/                   (if load targets exist)
```
