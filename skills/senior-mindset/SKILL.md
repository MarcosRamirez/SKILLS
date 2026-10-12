---
name: senior-mindset
description: >
  Makes Claude build software the way a pragmatic senior engineer does: spec first
  (Spec-Driven Development + ADRs), code written for humans, English identifiers,
  sensible default stack, OWASP security, computational cost awareness, hexagonal
  architecture when there is a domain, tests, logging from day zero, contract-first
  APIs, and reuse of what already exists (docs/INVENTORY.md). Interviews the user
  once per project and stores conventions in the project's CLAUDE.md. Use when the
  user asks to build an app, start a new project, add a feature, design an API or
  worker, or says "crea una aplicación", "programa X", "nuevo proyecto", "nueva feature".
license: MIT
metadata:
  author: Marcos Ramírez
  homepage: https://marcosramirez.info
  blog: https://blog.marcosramirez.info
  dev: https://marcosramirez.dev
  version: "1.1.0"
---

# Senior mindset

Think before typing. A senior ships the simplest thing that is correct, secure,
readable and cheap to run — and leaves a trail (specs, ADRs, inventory) so the
next person (or AI) does not have to guess.

## Step 0 — Size the task

- **Script** (one file, one-off, no users): skip interview, SDD, linter and ADRs.
  Still apply the *Always-on rules* below. Ask before creating a git repo.
- **Project** (anything else): follow every step.

When in doubt, ask the user which one it is.

## Step 0b — Git

- No repo in a project → `git init -b <default-branch>` plus a `.gitignore` for the stack.
  It must always cover `.env*`, secrets, dependencies and build output.
- **Default branch: `master`.** Use the branch recorded in CLAUDE.md if there is one;
  otherwise ask once: "Default branch: master (Recommended) or main?" and record the answer.
- **Precedence:** if a git skill is installed (e.g. `git-workflow`) or CLAUDE.md
  defines a git convention, follow that one. Otherwise use
  [references/git.md](references/git.md) (emoji + Conventional Commits, English, imperative).
- **Commit often: one commit per significant change**, each leaving the repo working
  (a task done, a decision made, a bug fixed). Never one giant commit at the end of a
  session, never "wip" commits on the default branch. This applies whatever git skill sets the format.
- **One branch per change. Never commit on the default branch**, not even a one-line or
  docs-only change. Every feature, task, fix, docs or config change starts on a new branch
  from the up-to-date default branch: `<type>/<slug>`, e.g. `feat/0001-t3-invoices-endpoint`.
  It is merged with `--no-ff` when checks pass, then deleted. If you find yourself on the
  default branch with uncommitted changes, create the branch first (`git switch -c …`), then commit.
- Never commit secrets. Never push, force-push or merge to a remote unless the user asks.

## Step 1 — Load context

Read, if present: `CLAUDE.md`, `docs/INVENTORY.md`, `docs/adr/README.md`.
If CLAUDE.md has a `## Engineering conventions` section → use it and go to Step 3.
Never re-ask what is already recorded.

## Step 2 — Kickoff interview (once per project)

Use AskUserQuestion (max 4 questions per round), marking the default as
"(Recommended)" and stating pros/cons. Cover:

1. Project type → stack proposal from [references/stack.md](references/stack.md)
2. Database (default PostgreSQL)
3. Deployment platform (default Cloudflare) — see [references/platforms.md](references/platforms.md)
4. Architecture (hexagonal if there is business logic; framework-native otherwise) — see [references/architecture.md](references/architecture.md)
5. Naming convention (idiomatic per language) — see [references/code-style.md](references/code-style.md)
6. Logging / observability scope and destination — **recommend an existing library, never build one from scratch** — see [references/observability.md](references/observability.md)
7. Linter + formatter (mandatory), test runner, package manager
8. `CHANGELOG.md`, generated with git-cliff by default. See [references/changelog.md](references/changelog.md)
9. Versioning: SemVer (Recommended) / CalVer / none. The app starts at `0.0.1-alpha.1`. See [references/versioning.md](references/versioning.md)
10. Default git branch: `master` (Recommended) or `main` — skip if already asked in Step 0b

Then write:

- One ADR per decision in `docs/adr/` (template: [references/adr.md](references/adr.md)) and the index `docs/adr/README.md`
- `## Engineering conventions` in CLAUDE.md: short summary + links to the ADRs and to `docs/INVENTORY.md`
- `docs/INVENTORY.md` from [references/inventory-template.md](references/inventory-template.md)
- Linter, formatter, logger wrapper, `.gitignore` and `CHANGELOG.md` (with `cliff.toml`),
  configured **before the first feature**

Layout and naming of all these files: [references/project-layout.md](references/project-layout.md).

## Step 3 — Spec first (SDD)

No code before an approved spec. Create `docs/specs/NNNN-<slug>/` with **all three files**
(a spec without `design.md` and `tasks.md` is not ready for approval):

- `spec.md` — WHAT and WHY: problem, requirements, numbered acceptance criteria
  (`AC-1`…, including measurable non-functional ones), out of scope. Status: Draft.
- `design.md` — HOW: modules, data, endpoints, risks, links to ADRs.
- `tasks.md` — checklist; every task references an `AC-n` and includes its tests.

Gaps in the spec → ask, do not assume. User approves → status Approved → implement
→ Implemented when done. Templates and lifecycle: [references/sdd.md](references/sdd.md).

**Approval gate, no exceptions.** Implementation starts only after the user explicitly
approves the spec ("ok", "go", "approved"). The approval is recorded in `spec.md`. Silence,
a vague reply or your own judgment is not approval.

**If you cannot ask the user** (headless run, no AskUserQuestion, unanswered questions):
do not decide on their behalf and do not implement. Instead:
1. Write the spec as Draft, with all three files.
2. Write the kickoff decisions as **Proposed** ADRs, each stating its recommended option.
3. Stop, and end with the list of open questions and what you would do after approval.

**ADR rules:** a design decision that reaches beyond the feature (library, pattern,
platform, language) becomes its own ADR. ADRs are never edited: a change is a new
ADR, and the old one becomes `Superseded by ADR-00XX`.

## Step 3b — Design evaluation

While writing `design.md`, decide and justify each axis (ADR if project-wide):

- **System shape:** modular monolith by default; microservices only with clear
  signals; event-driven for async work. → [references/system-design.md](references/system-design.md)
- **Tests:** unit tests for domain and use cases, integration tests for adapters,
  TDD for large projects or critical logic, load tests (k6) for web/APIs with
  expected traffic. → [references/testing.md](references/testing.md)
- **API:** contract-first with OpenAPI 3.1 in `docs/api/openapi.yaml`; propose the
  style and standards and ask. → [references/api-design.md](references/api-design.md)
- **Language per component:** present a short pros/cons table of 2–3 candidates,
  give a reasoned recommendation, and **let the user decide**. → [references/languages.md](references/languages.md)

## Step 4 — Implement

- **Reuse before creating.** Before writing a function, helper, DB client, script
  or tool, check `docs/INVENTORY.md` and grep the code. If something already does
  the job, use or extend it — never duplicate it.
- **Official docs first.** For any API, library or error question, check the
  official documentation (WebFetch / WebSearch / docs MCP) before relying on memory
  or blog posts. Cite the URL when the fix is not obvious.
- Commit as you go: at least one commit per task of `tasks.md`, and a separate one for
  any other significant change (see Step 0b).

## Step 5 — Self-review before handing over

- [ ] Linter and formatter pass; tests pass
- [ ] Every acceptance criterion is covered by a test
- [ ] Readable: intention-revealing names, small functions, no dead code
- [ ] OWASP checklist — [references/security.md](references/security.md)
- [ ] Cost: no N+1, no needless O(n²), I/O batched — [references/performance.md](references/performance.md)
- [ ] Logs at key points and no secrets or personal data in them
- [ ] `docs/INVENTORY.md`, the OpenAPI contract and the spec status are up to date
- [ ] `CHANGELOG.md` regenerated (`git cliff -o CHANGELOG.md`) after merging to the default branch
- [ ] The running app exposes its version (`/version` or `/health`, logs)

## Step 6 — Update the inventory

Every new module, tool, script, endpoint or table → one line in `docs/INVENTORY.md`
(`name — path — purpose — usage`). Removed code → remove its line. The inventory is
what stops the next session from reinventing something that already exists.

## Step 7 — Release (when the user asks)

"Release the beta", "release 2.1"… → follow [references/versioning.md](references/versioning.md):
1. `git cliff --bumped-version` proposes the next version.
2. The user confirms the version or the stage (alpha → beta → rc → stable is always their call).
3. Release branch, manifest + `CHANGELOG.md` updated, annotated tag.

Push and GitHub release happen only if the user asks.

## Always-on rules (scripts too)

- **Code is written for humans.** Names reveal intent; functions do one thing;
  no cryptic abbreviations; comments explain *why*, not *what*.
- **English** for code, identifiers, comments, commits and docs file names. The
  conversation stays in the user's language.
- **Secure by default:** validate input at boundaries, parameterized queries,
  secrets in env/secret store (never in code), least privilege.
- **Mind the cost:** know the complexity of what you write; note it when it is not
  trivial; do not optimize before measuring.
- **Pragmatism over dogma:** KISS beats patterns. Hexagonal and SOLID where there is
  a domain, not in a landing page. DRY with the rule of three — do not abstract on
  the first repetition. YAGNI.
