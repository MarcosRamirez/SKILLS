# Inventory

What already exists in this repo. Check before creating; update after changing.
Format: `name — path — purpose — usage`.

## Marketplace

- `marcosramirez-skills` — .claude-plugin/marketplace.json — lists every skill as a plugin — `/plugin marketplace add MarcosRamirez/SKILLS`

## Skills (plugins)

- `senior-mindset` — skills/senior-mindset/ — Claude works like a pragmatic senior engineer — `/plugin install senior-mindset@marcosramirez-skills`
- `save-image` — skills/save-image/ — saves pasted images to disk — `/plugin install save-image@marcosramirez-skills`

## senior-mindset references

Loaded on demand from `SKILL.md`. One topic per file:

- `adr.md` — ADR template and rules
- `agents-md.md` — AGENTS.md as the project's instructions: case table, `@AGENTS.md` safety rule, what stays in CLAUDE.md, merge procedure, symlinks, `CLAUDE.local.md`
- `api-design.md` — OpenAPI contract-first, REST standards
- `architecture.md` — hexagonal, SOLID, DRY, KISS, YAGNI and when not to apply them
- `automations.md` — catalog of automations offered at kickoff
- `constitution.md` — mission, tech stack (from ADRs) and roadmap formats
- `changelog.md` — CHANGELOG with git-cliff, tested `cliff.toml`
- `code-style.md` — naming per language, readability
- `defensive-programming.md` — trust boundaries, guard clauses, resource checks, timeouts, limits, cleanup
- `git.md` — branch per change, pull-request flow, stacked PRs, commit format
- `inventory-template.md` — template for a project's `spec/INVENTORY.md`
- `languages.md` — choosing a language per component
- `observability.md` — logging, tracing, error tracking
- `plans.md` — a plan per spec, naming with tier suffix, lifecycle, "run plan X"
- `models.md` — tier → Claude and open models (dated table)
- `performance.md` — computational cost rules
- `platforms.md` — hosting options (Cloudflare default)
- `postmortem.md` — blameless postmortem per bug: method, `## Postmortem` template, `spec/POSTMORTEMS.md` register, categories, pattern rule
- `project-layout.md` — project tree and AGENTS.md section
- `questions.md` — closed questions with clickable options (question tool): format, examples, numbered fallback
- `existing-projects.md` — working on existing projects (hard rule 4): change notice template, edge-case table, examples
- `sdd.md` — spec / design / tasks templates
- `release-automation.md` — specs close on merge, releases tag themselves; uses the templates below
- `security.md` — OWASP Top 10 checklist
- `setup.md` — first-use collision check with other skills, `~/.claude/senior-mindset.md`
- `stack.md` — default stack per use case
- `system-design.md` — monolith vs microservices, event-driven
- `testing.md` — test pyramid, TDD, k6
- `versioning.md` — app versioning from `0.0.1-alpha.1`, stages, git-cliff bump, release process

## senior-mindset templates

Copied into app projects by the skill (`skills/senior-mindset/templates/release-automation/` and `docs-check/`):

- `on-merge.yml` — workflow: tag the release, close specs named in `Closes-Spec:`
- `close-specs.sh` — marks specs Implemented from a PR body (also used by this repo's workflow)
- `docs-check/check-docs.py` — skills/senior-mindset/templates/docs-check/check-docs.py — generalised `check-docs.py` copied to `.github/scripts/` in app projects (default documents, `DOCS_CHECK_FILES` override)
- `docs-check/checks.yml` — skills/senior-mindset/templates/docs-check/checks.yml — pull-request workflow that runs it, copied to `.github/workflows/checks.yml`
- `tag-release.sh` — tags `v<version>` from package.json / pyproject.toml / Cargo.toml and creates the GitHub Release

## Hooks and scripts

- `save-image-hook.py` — skills/save-image/scripts/save-image-hook.py — UserPromptSubmit hook that saves pasted images — registered by `skills/save-image/hooks/hooks.json` (plugin) or manually in settings.json

## Automation

- `on-merge.yml` — .github/workflows/on-merge.yml — after each merge to master: closes specs named in `Closes-Spec:`, tags new skill versions — runs automatically
- `checks.yml` — .github/workflows/checks.yml — on every pull request (and manually): job `docs` runs `check-docs.py`, job `scripts` runs `tests/ci/run.sh` in a runner-like git configuration
- `close-specs.sh` — skills/senior-mindset/templates/release-automation/close-specs.sh — marks specs Implemented from a PR body; shipped with the skill for apps and reused by this repo's workflow (single copy)
- `tag-skill-releases.sh` — .github/scripts/tag-skill-releases.sh — tags `<name>-vX.Y.Z` and creates GitHub Releases; refuses a version with nothing but the version and changelog changed since the skill's last tag — `DRY_RUN=1 bash .github/scripts/tag-skill-releases.sh`
- `check-docs.py` — .github/scripts/check-docs.py — in the living documents, reports relative links that do not resolve and links to ADRs whose `Status:` is Superseded; exit 1 with `path:line: message` — `python3 .github/scripts/check-docs.py`

## Tests

Headless suite (SPEC-0028): real `claude -p` runs on scratch projects with deterministic checks; costs model usage, run before releases. Guide: `tests/headless/README.md`.

- `run.sh` — tests/headless/run.sh — runs the scenarios against a temp copy of `skills/senior-mindset`, prints each check with evidence and a summary (outcome, checks, cost, model, Claude Code version), fails if a user-level file changed — `bash tests/headless/run.sh [--only NAME] [--runs N] [--isolated-home]`
- `lib.sh` — tests/headless/lib.sh — helpers sourced by the runner and scenarios: scratch folders and repositories, branch-aware file reads, `claude -p` with the isolation flags, user-file hashes, `check` and reusable assertions (files, git branches, stream events)
- `stream.py` — tests/headless/stream.py — reads the stream-json: outcome (ok, usage limit, not logged in), cost, model, skills invoked, tool calls and inputs, Bash commands, permission denials, plugins; also hashes files — `python3 tests/headless/stream.py info <stream.jsonl>`
- `question_stub.py` — tests/headless/question_stub.py — stand-in AskUserQuestion over MCP for headless runs; fails like a client with no UI (`STUB_MODE=error`) or returns no answer
- `approval-gate.sh` — tests/headless/scenarios/approval-gate.sh — PM-0002/PM-0006: "build me a to-do web app" with failing questions must leave no code and Draft documents on a `docs/` branch
- `kickoff-checklist.sh` — tests/headless/scenarios/kickoff-checklist.sh — PM-0003: an approved kickoff leaves conventions, `.gitignore`, ADRs, constitution and `cliff.toml` on a branch, and at most `.gitignore` on `master`
- `script-fast-path.sh` — tests/headless/scenarios/script-fast-path.sh — PM-0004: a script request loads the skill, gives one file with English names, and no spec or ADR
- `trigger-merge.sh` — tests/headless/scenarios/trigger-merge.sh — PM-0011/SPEC-0027: "should we merge?" in English and Spanish merges nothing and asks first; runs 3 times
- `closed-question.sh` — tests/headless/scenarios/closed-question.sh — SPEC-0016: a merge decision is asked with well-formed options (or numbered), and not carried out
- `fix-flow.sh` — tests/headless/scenarios/fix-flow.sh — SPEC-0026: the approved empty-cart fix leaves a fix spec with a postmortem, a register row and a passing regression test
- `impact-sweep.sh` — tests/headless/scenarios/impact-sweep.sh — SPEC-0025: PostgreSQL to SQLite updates the living documents, leaves the Implemented spec and the code alone, and records the follow-up
- `tests/headless/README.md` — how to run the suite, its cost, the isolation it uses, how to write a scenario

## CI tests

Committed tests for the release scripts and the docs check (SPEC-0029): bash, git and python3 only, fixtures in temp folders, the scripts of the checkout under test. Guide: `tests/ci/README.md`.

- `run.sh` — tests/ci/run.sh — runs the three suites below and prints a summary; exit 1 if any fails — `bash tests/ci/run.sh`
- `test-close-specs.sh` — tests/ci/test-close-specs.sh — `close-specs.sh` (features, fixes, collisions, `SPEC_DIRS`, guards) and the on-merge id extraction with its `pipefail` fallback
- `test-tag-skill-releases.sh` — tests/ci/test-tag-skill-releases.sh — `tag-skill-releases.sh` on a scratch repository: the version-only refusal (SPEC-0023), tag selection, real tagging against a scratch remote
- `test-check-docs.sh` — tests/ci/test-check-docs.sh — `check-docs.py` (repo copy and template): broken links, superseded ADRs, code fences, the `adr/` folder rule, `DOCS_CHECK_FILES`
- `fakebin/gh` — tests/ci/fakebin/gh — fake `gh` that records its calls in `$GH_CALLS_LOG`; on `PATH` only inside the tag suite
- `tests/ci/README.md` — what each suite covers and how to run them

## Repo docs

- `AGENTS.md` — repo conventions and rules (docs, versioning, git)
- `CLAUDE.md` — one line: `@AGENTS.md`, the import that makes Claude Code read AGENTS.md; Claude Code-only notes go below it
- `spec/constitution/` — mission, tech stack (derived from the ADRs) and roadmap (states updated by the bot)
- `spec/features/` — one folder per feature (`spec.md`, `plan.<tier>.md`, `tasks.md`); "run plan NNNN" executes it
- `spec/fixes/` — one file per bug fix (current, expected and unchanged behaviour, root cause, postmortem, plan, tasks); same SPEC-NNNN numbering
- `spec/POSTMORTEMS.md` — register of bugs: one row each (category, root cause, why not caught, prevention and its status), the pattern count, proposed specs, and the postmortems of bugs without a fix spec — read before a spec, a review or a release
- `spec/adr/` — architecture decision records (index in README.md)
- `CHANGELOG.md` + `cliff.toml` — repo changelog generated with git-cliff, dated entries
- `skills/<name>/CHANGELOG.md` — per-skill changelog shipped inside each plugin, one dated section per `<name>-vX.Y.Z` tag
