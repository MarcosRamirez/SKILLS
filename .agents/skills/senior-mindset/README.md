# senior-mindset

Makes Claude build software the way a pragmatic senior engineer does — by default,
without you having to repeat it in every prompt.

## What it does

Whenever you ask Claude to write code, from a one-off script to a full app, it:

1. **Checks for collisions on first use.** It lists your installed skills, finds the ones
   that contradict its rules (e.g. a git skill that merges locally), asks which one wins in
   each area, and remembers your answer in `~/.claude/senior-mindset.md`. It greets you once
   when installed (with a short summary of what it can do and how to ask for the full help) and
   once per update, never more.
2. **Sizes the task.** A one-off script skips the ceremony but still gets English names
   and clean code. A project follows the full flow, and so does any request for the kickoff.
   In an existing project (code or docs already there), every change starts with a change
   notice and waits for your OK, then happens on its own branch. Your uncommitted changes are
   never touched: it asks whether to commit them on their own branch, stash them or stop.
   An existing project without conventions is **analysed first**, from its files: stack,
   structure, a verified inventory, conventions taken from the linter config, decisions found in
   the code, health, and committed secrets (reported by file and line, never copied). The result
   is `spec/ASSESSMENT.md` plus an "Adopt senior-mindset" spec that maps your existing docs onto
   the standard layout without deleting anything.
3. **Sets up git.** Runs `git init` if needed (default branch `master`, or `main` if you
   prefer: it asks once), writes a safe `.gitignore`, opens **one branch per change**
   (never commits on `master`), commits after every significant change, and delivers
   everything as **pull requests that you merge**. Dependent tasks go in stacked PRs. With
   no remote, it offers to create one. Commit format: `✨ feat(scope): add …`, English, imperative.
   It also loads for git-only requests ("merge", "push", "haz commit"), and writes a short
   "Git rules that always hold" block into the project's conventions so the rules apply even when it does not load.
4. **Interviews you once per project.** It asks about stack, database, deployment platform,
   architecture, naming, logging, linter, changelog and versioning, skipping what doesn't apply.
   It stores the answers as ADRs plus an `## Engineering conventions` section in the
   project's `AGENTS.md` (the standard file Claude Code and other agents read), and never asks again. A kickoff checklist is verified and committed
   before the first feature. Every session it checks the instruction files: a `CLAUDE.md` or
   `CLAUDE.local.md` without the `@AGENTS.md` import gets a proposal (migrate, merge without losing
   anything, or add the import), and nothing changes until you answer.
5. **Asks with clickable answers.** Every closed question (yes/no, pick one of 2–4 options,
   confirm a step) comes with buttons: the recommended option first, each with a one-line
   consequence, and a free-text field to type your own answer. Open questions stay as text.
6. **Writes the spec first (SDD).** A feature goes in `spec/features/NNNN-slug/` with `spec.md` →
   `plan.<tier>.md` → `tasks.md`. A bug that needs a spec goes in `spec/fixes/NNNN-slug.md`: the
   current, expected and unchanged behaviour, the reproduction, the root cause, and a test that
   fails before the fix and passes after it. A trivial fix needs no spec: a regression test that
   fails first and a `fix:` commit. For everything else it **never writes code without your
   explicit approval**. If it can't ask you (e.g. a headless run), it stops with a Draft spec and
   a list of questions.
7. **Evaluates the design.** Monolith or microservices, event-driven or not, test strategy
   (unit, TDD, k6 load tests), contract-first OpenAPI, and the language per component
   (it shows pros and cons, you decide).
8. **Implements.** Reuses what already exists (`spec/INVENTORY.md`), checks official docs first,
   and writes code meant to be read by humans.
9. **Reviews itself.** Lint, tests, OWASP, defensive checks (guard clauses, resource checks, timeouts, limits), computational cost, logs without secrets.
10. **Learns from every bug.** Each fixed bug gets a blameless postmortem (impact, 5 Whys, why it was
   not caught, corrective and preventive actions) and a row in `spec/POSTMORTEMS.md`. The register
   is read before specs and releases, and three bugs in one category trigger a spec that removes the pattern.
11. **Propagates every decision.** Each ADR has an `## Impact` section and runs an impact sweep in the
   same PR: the READMEs, conventions and specs that describe the decision are updated, follow-up work
   becomes Draft specs, and old projects or data get a proposed migration, never a silent one.
12. **Updates the inventory**, so the next session does not reinvent existing tools.
13. **Keeps a changelog and versions the app.** `CHANGELOG.md` is generated by git-cliff from
   the commits. The app starts at `0.0.1-alpha.1` and moves through beta and rc to stable;
   git-cliff computes the next number, and you decide when it changes stage. A release is
   proposed only when something was implemented: writing or approving a spec never moves a version.

## Install

Follows the [Agent Skills](https://agentskills.io) standard. Built and tested on Claude Code; other
agents are planned (SPEC-0013).

**`npx skills` (recommended)**: into your project, for Claude Code plus agents that read `.agents/skills/`:

```bash
npx skills add MarcosRamirez/SKILLS --skill senior-mindset -a claude-code codex --copy
```

- Claude Code only: drop `codex` and `--copy`. For all your projects: add `-g`.
- With `--copy`, commit `.agents/skills/`, `.claude/skills/` and `skills-lock.json` so your team gets it.
- Pin a release tag, because the default branch can hold unreleased changes:
  `npx skills add MarcosRamirez/SKILLS#senior-mindset-vX.Y.Z --skill senior-mindset -a claude-code codex --copy`
  (versions on the [Releases page](https://github.com/MarcosRamirez/SKILLS/releases)).
  `npx skills update` keeps it on that tag; run `add` with the new tag to move.

**Ask your agent**: paste this:

> Install the senior-mindset skill from https://github.com/MarcosRamirez/SKILLS, folder `skills/senior-mindset`,
> at its latest release tag (`senior-mindset-vX.Y.Z`, not the default branch), into this project's
> `.agents/skills/senior-mindset/`. Copy the whole folder, including references/.
> If your agent does not read `.agents/skills/` (Claude Code does not yet), also copy it to
> `.claude/skills/senior-mindset/`. Ask me before installing it globally.

**Manual**: copy the folder into `.agents/skills/` (and `.claude/skills/` for Claude Code); add
`--branch senior-mindset-vX.Y.Z` to the clone to pin a release:

```bash
git clone --depth 1 https://github.com/MarcosRamirez/SKILLS.git /tmp/skills
mkdir -p .agents/skills .claude/skills
cp -r /tmp/skills/skills/senior-mindset .agents/skills/
cp -r /tmp/skills/skills/senior-mindset .claude/skills/
```

**Claude Code plugin marketplace (Claude Code only)**: updates through `/plugin`:

```
/plugin marketplace add MarcosRamirez/SKILLS
/plugin install senior-mindset@marcosramirez-skills
```

The `references/` folder must come along: `SKILL.md` loads those files only when needed.
If senior-mindset is also installed globally as a plugin, Claude Code lists both `senior-mindset`
and `senior-mindset:senior-mindset`. On first use in each project the skill notices it and offers to
disable the global plugin there (or, with only a global copy, to install it in the project).

## Usage

It triggers on its own when you ask to build something:

```
build me a task management app
add password reset to the API
crea una aplicación para gestionar reservas
programa un worker que procese imágenes
```

## Commands

Ask in any language; the skill recognises the intent, and the phrases below are only examples.
Full list, with what each does and where it is specified: [references/commands.md](references/commands.md).

| Command | Example | What it does |
|---|---|---|
| help | "what can you do?", "¿qué puedes hacer?" | Lists the commands and summarises your configuration. Read-only |
| status | "status", "estado del proyecto" | Specs and plans with their states, open PRs, version and tags, automations. Read-only |
| list plans | "list plans", "lista los planes" | Plans with state and tier, marking which can run now. Read-only |
| run plan | "run plan 0008", "ejecuta el plan 0008" | Executes an approved plan step by step |
| release | "release the beta", "saca la versión 2.1" | Proposes the version and opens the release PR |
| reconfigure | "reconfigure senior-mindset" | Runs the first-use collision setup again |
| update senior-mindset | "update senior-mindset" | Installs the latest release over the project's copies, on a branch, and opens a PR with its changelog |
| automations | "add the docs check" | Installs or removes an automation through a PR |

## Customize your defaults

Edit [references/stack.md](references/stack.md). It holds your default framework,
database, platform and tooling per use case. Rows marked `TODO` make Claude ask you
and suggest 2–3 options.

| File | What it controls |
|---|---|
| `references/stack.md` | Default stack per use case |
| `references/platforms.md` | Hosting options (Cloudflare default) |
| `references/commands.md` | Every command as an intent (help, status, list plans, run plan, release, reconfigure, update, automations): example phrases in several languages, what it does, where it is specified |
| `references/setup.md` | First-use collision check with other skills, `~/.claude/senior-mindset.md`, the install check (global, project or duplicate copies) and the update command |
| `references/versioning.md` | App versioning: `0.0.1-alpha.1` → beta → rc → stable, the "nothing to release" check, git-cliff bump, release steps |
| `references/changelog.md` | Dated CHANGELOG.md with git-cliff (tested `cliff.toml`), per-package changelogs |
| `references/git.md` | Branch per change, pull-request flow, stacked PRs, commit format |
| `references/code-style.md` | Naming conventions per language |
| `references/architecture.md` | When to use hexagonal, SOLID, DRY, KISS |
| `references/defensive-programming.md` | Trust boundaries, guard clauses, resource checks (disk space…), timeouts, limits |
| `references/automations.md` | Catalog of automations offered at kickoff (multi-select question): release-automation, docs-check |
| `references/questions.md` | Closed questions asked with the question tool: format, click or type, examples, numbered fallback |
| `references/existing-projects.md` | Hard rule 4 in practice: the change notice template, edge cases (no git, uncommitted changes, other branch, AI config, CI), conventions win, no drive-by refactors |
| `references/onboarding.md` | Onboarding an existing project: state detection, the six-stage code analysis with a verification gate for the inventory, secrets reported by location only, mapping existing docs (spec-kit, Kiro, ADRs, loose documents, wikis) onto the standard layout, the `spec/ASSESSMENT.md` template and the adoption spec |
| `references/constitution.md` | Mission, tech stack (from ADRs) and roadmap (updated by the bot) |
| `references/plans.md` | The plan of each spec (`plan.<tier>.md`, or the `## Plan` section of a single-file spec or fix), "run plan X" |
| `references/models.md` | Tier (high/medium/low) → Claude and open models |
| `references/release-automation.md` | Specs close on merge, releases tag themselves (`on-merge.yml`); templates in `templates/release-automation/` |
| `references/security.md` | OWASP Top 10 checklist |
| `references/performance.md` | Computational cost rules |
| `references/sdd.md` · `adr.md` | Spec templates (feature and fix, and when a fix needs a spec) and the ADR template with its `## Impact` section and the impact sweep |
| `references/system-design.md` | Monolith vs microservices, event-driven |
| `references/testing.md` | Test pyramid, TDD, k6 / JMeter, trying a platform on a throwaway repo or in CI first |
| `references/api-design.md` | OpenAPI contract-first, REST standards |
| `references/observability.md` | Logging and tracing libraries and rules |
| `references/languages.md` | Choosing a language per component |
| `references/project-layout.md` | Folder tree and AGENTS.md section |
| `references/agents-md.md` | `AGENTS.md` as the single source of project instructions: the case table (new, only CLAUDE.md, both…), the `@AGENTS.md` safety rule, what stays in CLAUDE.md, and how to merge both files (nothing lost, conflicts asked), symlinks and `CLAUDE.local.md` |
| `references/inventory-template.md` | `spec/INVENTORY.md` template |
| `references/postmortem.md` | Blameless postmortem for every bug: method, `## Postmortem` template, `spec/POSTMORTEMS.md` register, categories, pattern rule |

## What it creates in your project

```text
spec/
  constitution/               mission.md · tech-stack.md · roadmap.md
  features/
    NNNN-slug/                spec.md · plan.<tier>.md · tasks.md
    NNNN-slug.md              small feature in a single file
  fixes/
    NNNN-slug.md              a fix in a single file; shares the numbering with features
  adr/                        README.md + NNNN-*.md
  api/openapi.yaml            (if there is an API)
  INVENTORY.md
  POSTMORTEMS.md              one row per fixed bug, created at the first bug
src/ · app/ · apps/<name>/    the code, separate from spec/: you choose where at kickoff
                              (or type any other folder)
AGENTS.md                     ## Engineering conventions (no CLAUDE.md in new projects)
CHANGELOG.md + cliff.toml     generated from commits, newest first
```
