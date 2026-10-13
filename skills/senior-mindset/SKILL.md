---
name: senior-mindset
description: >
  Makes Claude build software the way a pragmatic senior engineer does: spec first
  (Spec-Driven Development + ADRs), code written for humans, English identifiers,
  sensible default stack, OWASP security, computational cost awareness, hexagonal
  architecture when there is a domain, tests, logging from day zero, contract-first
  APIs, and reuse of what already exists (spec/INVENTORY.md). Interviews the user
  once per project and stores conventions in the project's CLAUDE.md. Use whenever
  Claude is about to write or change code of any size: an app, a feature, an API,
  a worker, a fix, or a one-off script (scripts take a fast path: no interview, but
  English names and clean code). Also for releases and versioning. Triggers include
  "build", "create", "write a script", "fix", "release", "crea una aplicación",
  "programa X", "hazme un script", "nuevo proyecto", "nueva feature", "saca la versión",
  "run plan 0008", "ejecuta el plan 0008".
license: MIT
metadata:
  author: Marcos Ramírez
  homepage: https://marcosramirez.info
  blog: https://blog.marcosramirez.info
  dev: https://marcosramirez.dev
  version: "2.1.0"
---

# Senior mindset

Think before typing. A senior ships the simplest thing that is correct, secure,
readable and cheap to run — and leaves a trail (specs, ADRs, inventory) so the
next person (or AI) does not have to guess.

## Hard rules: read first, no exceptions

1. **No application code without the user's explicit approval of the spec, given in this
   conversation.** That means no source files, no scaffolding, no dependency installs and no
   build. Approval is the user's own words ("ok", "go", "approved", "adelante").
2. **A question that fails, is skipped, times out or cannot be shown is NOT an answer and NOT
   approval.** Never "choose sensible defaults" to get past rule 1. No answer means no decision,
   and no decision means no code. If the request is "build me X", that is a request for a
   spec, not a license to skip it.
3. **When you cannot get answers** (non-interactive run, AskUserQuestion unavailable, failing
   or skipped), do not stop empty-handed with only questions. **Write the documents first**:
   they are drafts based on your recommended options, cheap to change, and they give the
   user something concrete to approve. Run `git init -b master` for a new project (Step 0b),
   then produce only what needs no approval, and stop:
   - kickoff documents: Proposed ADRs with their recommended option, CLAUDE.md conventions
     marked "proposed", `spec/INVENTORY.md`, and `.gitignore` if you created the repo;
   - the feature as **Draft**, with `spec.md`, `plan.<tier>.md` and `tasks.md` (or a single small-feature file);
   - a commit on a `docs/` branch, never on the default branch;
   - a final message with numbered open questions and what you will build once they are
     answered and the spec is approved.

   Scripts are the exception: they take the fast path in Step 0 and need no spec. So does a
   trivial fix (Step 3).

## Step 0a — First-use setup (once per user)

Read `~/.claude/senior-mindset.md`. **If it does not exist, run the setup in
[references/setup.md](references/setup.md) before anything else:**
1. List the installed skills (names and descriptions only).
2. Find areas where another skill contradicts senior-mindset (git flow, commit format,
   changelog/versioning, specs, review, tests).
3. Ask which one wins in each colliding area.
4. Write the file.
5. Greet once, in the user's language (at most 3 lines):
   > ✅ senior-mindset vX.Y.Z installed and configured.
   > Made by Marcos Ramírez — https://blog.marcosramirez.info/sobre-mi/

Its decisions apply to every project, unless the project's CLAUDE.md overrides them.

**Updated?** If the file exists but its `senior-mindset version` is older than this skill's
`metadata.version`, say once: "🔄 senior-mindset updated to vX.Y.Z — what's new in its
CHANGELOG.md · by Marcos Ramírez, https://blog.marcosramirez.info/sobre-mi/", then record the
new version in the file. Never show either message at any other time.

## Step 0 — Size the task

- **Script** (one file, one-off, no users): skip interview, SDD, linter and ADRs.
  Still apply the *Always-on rules* below. In particular, file name, identifiers, CLI
  flags and comments are in English, even when the user writes in another language
  (only user-facing messages follow the user's language). Ask before creating a git repo.
- **Project** (anything else): follow every step.

When in doubt, ask the user which one it is.

## Step 0b — Git

- No repo in a project → `git init -b <default-branch>` plus a `.gitignore` for the stack.
  It must always cover `.env*`, secrets, dependencies and build output.
- **Default branch: `master`.** Use the branch recorded in CLAUDE.md if there is one;
  otherwise ask once: "Default branch: master (Recommended) or main?" and record the answer.
- **Precedence:** follow the decisions in the project's CLAUDE.md, then
  `~/.claude/senior-mindset.md` (Step 0a), then [references/git.md](references/git.md)
  (emoji + Conventional Commits, English, imperative). Another git skill is followed only
  for the areas where the user chose it in the setup.
- **Commit often: one commit per significant change**, each leaving the repo working
  (a task done, a decision made, a bug fixed). Never one giant commit at the end of a
  session, never "wip" commits on the default branch. This applies whatever git skill sets the format.
- **One branch per change. Never commit on the default branch**, not even a one-line or
  docs-only change. Every feature, task, fix, docs or config change starts on a new branch
  from the up-to-date default branch: `<type>/<slug>`, e.g. `feat/0001-t3-invoices-endpoint`.
  If you find yourself on the default branch with uncommitted changes, create the branch
  first (`git switch -c …`), then commit.
- **Everything reaches the default branch through a pull request; the user merges it.**
  When a task is done and checks pass:
  1. `git push -u origin <branch>`.
  2. `gh pr create --base <base>`, with what and why, `SPEC-NNNN`/`T-n`, the ACs covered and the check results.
  3. Stop. Never merge the PR yourself, unless the user explicitly asks for that PR.

  Dependent tasks are **stacked PRs**: the next branch starts from the previous one, and its
  PR targets that branch, so the work moves on step by step while the user merges in order.
  No remote → offer to create one; if declined, merge locally with `--no-ff`.
  Details: [references/git.md](references/git.md).
- Choosing this flow in the setup is standing permission to push work branches and open PRs.
  Never push to the default branch, never force-push, never commit secrets.

## Step 1 — Load context

Read, if present: `CLAUDE.md`, `spec/constitution/` (mission, tech-stack, roadmap),
`spec/INVENTORY.md`, `spec/adr/README.md`.
**Old layout** (`docs/specs/`, `docs/plans/`, `docs/adr/` from senior-mindset 1.x): propose the
migration to `spec/` through a change notice, on its own branch, keeping history with `git mv`
([references/project-layout.md](references/project-layout.md)). Do not mix it with other work.
If a skill that overlaps one of senior-mindset's areas is installed but missing from
`~/.claude/senior-mindset.md`, ask about that skill only and update the file.
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
11. **Automations to install** — one multi-select question built from
    [references/automations.md](references/automations.md) (e.g. specs that close on merge and
    releases that tag themselves). Recommended ones are marked; ones whose requirements are missing are left out.
12. **Where the code goes** (new projects only): `src/` (Recommended for one app), `app/`,
    `apps/<name>/` (several deployables), or any folder the user types in the free-text field
    (validated: relative, inside the repo, no `..`, not `spec/` or `.github/`). See
    [references/project-layout.md](references/project-layout.md).

**Items that do not apply are skipped, not forced.** A docs repo has no database, and a CLI
has no deployment platform. Mark such items `N/A — <reason>` in CLAUDE.md instead of asking about them.

**Kickoff checklist.** Verify every item before the first feature, and do not start the spec until it is complete:

- [ ] **Constitution** in `spec/constitution/` ([references/constitution.md](references/constitution.md)):
  `mission.md` asked of and **approved by the user**, `tech-stack.md` derived from the ADRs,
  `roadmap.md` with its table (empty until the first feature)
- [ ] **Code folder** chosen in question 12 and recorded in CLAUDE.md (`Code: …`); existing projects
  keep theirs, recorded the same way
- [ ] One ADR per decision in `spec/adr/` (template: [references/adr.md](references/adr.md)) + index `spec/adr/README.md`
- [ ] `## Engineering conventions` in CLAUDE.md: summary, N/A items with reasons, links to the ADRs and `spec/INVENTORY.md`
- [ ] `spec/INVENTORY.md` from [references/inventory-template.md](references/inventory-template.md)
- [ ] `.gitignore`; linter and formatter configured and passing
- [ ] Logger wrapper, unless logging is N/A
- [ ] `cliff.toml` (changelog + `[bump]`) and a generated `CHANGELOG.md`
- [ ] Version `0.0.1-alpha.1` in the manifest, unless versioning is N/A
- [ ] Automations chosen in question 11 installed from the skill's templates and tested
  — [references/automations.md](references/automations.md)
- [ ] **Kickoff committed on its own branch** (`chore/kickoff`) and its PR opened before any
  feature work. Feature branches stack on it until the user merges it.

Layout and naming of all these files: [references/project-layout.md](references/project-layout.md).

## Step 3 — Spec first (SDD)

No code before an approved spec. First choose the **type**. Features and fixes share one
`SPEC-NNNN` numbering, and every spec header carries `Type: feature` or `Type: fix`:

- **feature** → `spec/features/`: new or changed behaviour. Refactors, performance work and
  upgrades too, with a criterion that behaviour does not change.
- **fix** → `spec/fixes/`: behaviour that is wrong. A **trivial fix** (obvious cause, one place,
  nothing changes beyond the bug) gets no spec: a regression test that fails first, then a `fix:`
  commit. A fix needs a spec when the root cause is unknown, several modules are involved,
  behaviour changes beyond the bug, or there is data loss or a security impact (a vulnerability's
  details stay private until the fix is released). In doubt, write the spec.

A feature gets `spec/features/NNNN-<slug>/` with **all three files**
(a feature without its plan and tasks is not ready for approval):

- `spec.md` — WHAT and WHY: problem, requirements, numbered acceptance criteria
  (`AC-1`…, including measurable non-functional ones), out of scope. Status: Draft.
- `plan.<tier>.md` — HOW: `## Design` (decisions, components, data, endpoints, links to ADRs)
  and `## Steps` with the recommended tier per step (Step 3c).
- `tasks.md` — checklist; every task references an `AC-n` and includes its tests.

A small feature that fits on one screen can be a single file `spec/features/NNNN-<slug>.md`
with `## Spec`, `## Plan` and `## Tasks`.

A fix is a single file `spec/fixes/NNNN-<slug>.md` with the same three sections (a folder only
when it is large). Its Spec states the current, expected and **unchanged** behaviour, the
reproduction, the root cause and the fix. Its acceptance criteria always include a test that fails
before the fix and passes after it, plus unchanged-behaviour tests that stay green. Flow:
reproduce with a failing test → root cause → fix, on a `fix/NNNN-<slug>` branch.

Add every new spec to `spec/constitution/roadmap.md`.

Gaps in the spec → ask, do not assume. User approves → status Approved → implement.
**Implemented is set when the user merges the spec's last PR**, never inside the PR: that PR
carries `Closes-Spec: SPEC-NNNN` and `on-merge.yml` flips the status
([references/release-automation.md](references/release-automation.md)).
Templates and lifecycle: [references/sdd.md](references/sdd.md).

**Approval gate:** see the Hard rules at the top. Implementation starts only after explicit
approval, recorded in `spec.md` (`Approved by:`). Silence, a vague reply, a failed or skipped
question, or your own judgment is not approval.

**ADR rules:** a design decision that reaches beyond the feature (library, pattern,
platform, language) becomes its own ADR. ADRs are never edited: a change is a new
ADR, and the old one becomes `Superseded by ADR-00XX`.

## Step 3b — Design evaluation

While writing the plan's `## Design`, decide and justify each axis (ADR if project-wide):

- **System shape:** modular monolith by default; microservices only with clear
  signals; event-driven for async work. → [references/system-design.md](references/system-design.md)
- **Tests:** unit tests for domain and use cases, integration tests for adapters,
  TDD for large projects or critical logic, load tests (k6) for web/APIs with
  expected traffic. → [references/testing.md](references/testing.md)
- **API:** contract-first with OpenAPI 3.1 in `spec/api/openapi.yaml`; propose the
  style and standards and ask. → [references/api-design.md](references/api-design.md)
- **Language per component:** present a short pros/cons table of 2–3 candidates,
  give a reasoned recommendation, and **let the user decide**. → [references/languages.md](references/languages.md)

## Step 3c — Plan

With the spec approved, write its plan before implementing:
`spec/features/NNNN-<slug>/plan.<tier>.md`, inside the feature folder, with the overall tier
(`high`/`medium`/`low`) as a suffix; a single-file spec (small feature or fix) keeps it in its
`## Plan` section. Its `## Design` section holds the technical how (in a fix, the root cause and
the fix). The plan has context, one step per task with its
recommended tier and agent/model ([references/models.md](references/models.md)), verification,
risks and out of scope. It is part of what the user approves. Template, lifecycle and naming:
[references/plans.md](references/plans.md).

**"Run plan X" / "ejecuta el plan X":** read the plan and its spec, check approval (ask if the
spec is still Draft), set the plan to `In progress`, and execute the steps with branches and PRs.
The last PR carries `Closes-Spec: SPEC-X`, and the bot marks the spec Implemented and the plan Done.

## Step 4 — Implement

Follow the plan step by step. If reality diverges from the plan, update the plan in the same
branch and tell the user, instead of silently doing something else.


- **Reuse before creating.** Before writing a function, helper, DB client, script
  or tool, check `spec/INVENTORY.md` and grep the code. If something already does
  the job, use or extend it — never duplicate it.
- **Official docs first.** For any API, library or error question, check the
  official documentation (WebFetch / WebSearch / docs MCP) before relying on memory
  or blog posts. Cite the URL when the fix is not obvious.
- Commit as you go: at least one commit per task of `tasks.md`, and a separate one for
  any other significant change (see Step 0b). **A whole feature in a single commit is a
  failure of this rule**, even when the feature is small.

## Step 5 — Self-review before handing over

- [ ] Linter and formatter pass; tests pass
- [ ] Every acceptance criterion is covered by a test
- [ ] Readable: intention-revealing names, small functions, no dead code
- [ ] OWASP checklist — [references/security.md](references/security.md)
- [ ] Defensive: guard clauses, resource checks, timeouts, limits, no partial state on failure — [references/defensive-programming.md](references/defensive-programming.md)
- [ ] Cost: no N+1, no needless O(n²), I/O batched — [references/performance.md](references/performance.md)
- [ ] Logs at key points and no secrets or personal data in them
- [ ] `spec/INVENTORY.md`, the OpenAPI contract and the spec status are up to date
- [ ] `CHANGELOG.md` regenerated (`git cliff -o CHANGELOG.md`) on the work branch
- [ ] Branch pushed and PR opened (or merged locally if there is no remote); not merged by you
- [ ] The running app exposes its version (`/version` or `/health`, logs)

## Step 6 — Update the inventory

Every new module, tool, script, endpoint or table → one line in `spec/INVENTORY.md`
(`name — path — purpose — usage`). Removed code → remove its line. The inventory is
what stops the next session from reinventing something that already exists.

## Step 7 — Release (when the user asks)

"Release the beta", "release 2.1"… → follow [references/versioning.md](references/versioning.md):
1. `git cliff --bumped-version` proposes the next version.
2. The user confirms the version or the stage (alpha → beta → rc → stable is always their call).
3. Release branch with manifest + `CHANGELOG.md` → release PR → the user merges.
4. With `on-merge.yml`, the tag and the GitHub Release are created at merge time
   ([references/release-automation.md](references/release-automation.md)). Without it,
   tag the merge commit by hand; push it and create the release only if the user asks.

## Always-on rules (scripts too)

- **Code is written for humans.** Names reveal intent; functions do one thing;
  no cryptic abbreviations; comments explain *why*, not *what*.
- **English** for code, identifiers, comments, commits and docs file names. The
  conversation stays in the user's language.
- **Secure by default:** validate input at boundaries, parameterized queries,
  secrets in env/secret store (never in code), least privilege.
- **Defensive by default:** never trust input (user, files, env, external APIs). Use guard
  clauses and fail fast. Check resources before acting (e.g. free disk space before writing
  an upload), and still handle the failure the check cannot prevent. Put a timeout on every
  external call, a limit on everything unbounded, and leave no partial state when something
  fails halfway. Validate at boundaries, trust typed values inside.
  → [references/defensive-programming.md](references/defensive-programming.md)
- **Mind the cost:** know the complexity of what you write; note it when it is not
  trivial; do not optimize before measuring.
- **Pragmatism over dogma:** KISS beats patterns. Hexagonal and SOLID where there is
  a domain, not in a landing page. DRY with the rule of three — do not abstract on
  the first repetition. YAGNI.
