# Inventory

What already exists in this repo. Check before creating; update after changing.
Format: `name — path — purpose — usage`.

## Marketplace

- `marcosramirez-skills` — .claude-plugin/marketplace.json — lists every skill as a plugin; each entry repeats the version of its SKILL.md — `/plugin marketplace add MarcosRamirez/SKILLS`

## The skill installed in this repo (SPEC-0021)

- `.agents/skills/senior-mindset/` — .agents/skills/senior-mindset/ — the published release this repo uses (standard location); installed, never edited — "update senior-mindset"
- `.claude/skills/senior-mindset/` — .claude/skills/senior-mindset/ — the same release, the bridge Claude Code reads — "update senior-mindset"
- `skills-lock.json` — skills-lock.json — what `npx skills` installed, with the release tag in `ref`
- `.ignore` — .ignore — ripgrep (the agent's Grep and Glob) skips the installed copies
- `.gitignore` — .gitignore — keeps `.claude/` local files out of git, except the `.claude/skills/` bridge

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
- `onboarding.md` — onboarding an existing project without conventions: state detection, six-stage code analysis, inventory verification gate, secrets by location only, docs mapping, `spec/ASSESSMENT.md` template, adoption spec flow, no-deletion check
- `sdd.md` — spec / design / tasks templates
- `release-automation.md` — specs close on merge, releases tag themselves; uses the templates below
- `security.md` — OWASP Top 10 checklist
- `commands.md` — the commands as intents (help, status, list plans, run plan, release, reconfigure, update, automations): example phrases, effect, where specified; the single source that help renders
- `setup.md` — first-use collision check with other skills, `~/.claude/senior-mindset.md`, the install check in each project (global, project or duplicate copies) and the update command
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
- `checks.yml` — .github/workflows/checks.yml — on every pull request (and manually): job `docs` runs `check-docs.py` and `check-versions.py`, job `scripts` runs `tests/ci/run.sh` in a runner-like git configuration
- `close-specs.sh` — skills/senior-mindset/templates/release-automation/close-specs.sh — marks specs Implemented from a PR body; shipped with the skill for apps and reused by this repo's workflow (single copy)
- `tag-skill-releases.sh` — .github/scripts/tag-skill-releases.sh — reads each `skills/*/SKILL.md` frontmatter (`name`, `metadata.version`), tags `<name>-vX.Y.Z` and creates GitHub Releases; refuses a version with nothing but the version and changelog changed since the skill's last tag — `DRY_RUN=1 bash .github/scripts/tag-skill-releases.sh`
- `check-docs.py` — .github/scripts/check-docs.py — in the living documents, reports relative links that do not resolve and links to ADRs whose `Status:` is Superseded; exit 1 with `path:line: message` — `python3 .github/scripts/check-docs.py`
- `check-versions.py` — .github/scripts/check-versions.py — each local marketplace entry carries the `name` and `metadata.version` of its skill's SKILL.md (SemVer), and every skill folder has an entry (ADR-0006) — `python3 .github/scripts/check-versions.py`

## Tests

Headless suite (SPEC-0028): real `claude -p` runs on scratch projects with deterministic checks; costs model usage, run before releases. Guide: `tests/headless/README.md`.

- `run.sh` — tests/headless/run.sh — runs the scenarios against a temp copy of `skills/senior-mindset`, prints each check with evidence and a summary (outcome, checks, cost, model, Claude Code version), fails if a user-level file changed — `bash tests/headless/run.sh [--only NAME] [--runs N] [--isolated-home]`
- `lib.sh` — tests/headless/lib.sh — helpers sourced by the runner and scenarios: scratch folders and repositories, branch-aware file reads, `claude -p` with the isolation flags, user-file hashes, project baselines (files, branch trees, commits, status), `check` and reusable assertions (files, git branches, stream events, change notices)
- `stream.py` — tests/headless/stream.py — reads the stream-json: outcome (ok, usage limit, not logged in), cost, model, skills invoked, tool calls and inputs, Bash commands, permission denials, plugins; also hashes files and whole folders (`hash-tree`) — `python3 tests/headless/stream.py info <stream.jsonl>`
- `question_stub.py` — tests/headless/question_stub.py — stand-in AskUserQuestion over MCP for headless runs; fails like a client with no UI (`STUB_MODE=error`) or returns no answer
- `approval-gate.sh` — tests/headless/scenarios/approval-gate.sh — PM-0002/PM-0006: "build me a to-do web app" with failing questions must leave no code and Draft documents on a `docs/` branch
- `kickoff-checklist.sh` — tests/headless/scenarios/kickoff-checklist.sh — PM-0003: an approved kickoff leaves conventions, `.gitignore`, ADRs, constitution and `cliff.toml` on a branch, and at most `.gitignore` on `master`
- `script-fast-path.sh` — tests/headless/scenarios/script-fast-path.sh — PM-0004: a script request loads the skill, gives one file with English names, and no spec or ADR
- `trigger-merge.sh` — tests/headless/scenarios/trigger-merge.sh — PM-0011/SPEC-0027: "should we merge?" in English and Spanish merges nothing and asks first; runs 3 times
- `closed-question.sh` — tests/headless/scenarios/closed-question.sh — SPEC-0016: a merge decision is asked with well-formed options (or numbered), and not carried out
- `fix-flow.sh` — tests/headless/scenarios/fix-flow.sh — SPEC-0026: the approved empty-cart fix leaves a fix spec with a postmortem, a register row and a passing regression test
- `impact-sweep.sh` — tests/headless/scenarios/impact-sweep.sh — SPEC-0025: PostgreSQL to SQLite updates the living documents, leaves the Implemented spec and the code alone, and records the follow-up
- `existing-code-notice.sh` — tests/headless/scenarios/existing-code-notice.sh — SPEC-0008 AC-2: "add validation to the signup form" in an existing code repository ends with a change notice, and no file, branch tree or commit changes
- `existing-docs-notice.sh` — tests/headless/scenarios/existing-docs-notice.sh — SPEC-0008 AC-3: "organise the specs" in a docs-only repository with its own pattern ends with a notice of moves (or an assessment offer), with nothing moved or committed
- `dirty-tree.sh` — tests/headless/scenarios/dirty-tree.sh — SPEC-0008 AC-4: uncommitted user changes stay byte-identical, uncommitted and unstashed, and the agent asks whether to commit them on a branch, stash them or stop
- `no-git.sh` — tests/headless/scenarios/no-git.sh — SPEC-0008 AC-5: code outside git gets a proposal of `git init` and a snapshot commit, with no source changed; a `git init` run without the OK is reported as a finding
- `help-languages.sh` — tests/headless/scenarios/help-languages.sh — SPEC-0014 AC-2/AC-2b: "what can you do?" in Spanish, English and French lists the commands and the configuration in that language, and changes nothing; runs 3 times
- `status.sh` — tests/headless/scenarios/status.sh — SPEC-0014 AC-3: "status" in a repository with a small spec tree names every spec with the state, plan state and tier of its files, plus version, tag and automation, and changes nothing
- `install-global-only.sh` — tests/headless/scenarios/install-global-only.sh — SPEC-0021 AC-3: with the skill loaded only from outside the project, "help" names the project install as a pending decision and changes nothing
- `install-project-only.sh` — tests/headless/scenarios/install-project-only.sh — SPEC-0021 AC-3: with the skill only in the project (`SCENARIO_LOAD=project`), "help" raises no install or duplicate question and changes nothing
- `install-duplicate.sh` — tests/headless/scenarios/install-duplicate.sh — SPEC-0021 AC-3: with a project copy and a plugin, "help" names the duplicate and proposes disabling the global one, with no setting written
- `tests/headless/README.md` — how to run the suite, its cost, the isolation it uses, how to write a scenario

## CI tests

Committed tests for the release scripts and the docs check (SPEC-0029): bash, git and python3 only, fixtures in temp folders, the scripts of the checkout under test. Guide: `tests/ci/README.md`.

- `run.sh` — tests/ci/run.sh — runs the three suites below and prints a summary; exit 1 if any fails — `bash tests/ci/run.sh`
- `test-close-specs.sh` — tests/ci/test-close-specs.sh — `close-specs.sh` (features, fixes, collisions, `SPEC_DIRS`, guards) and the on-merge id extraction with its `pipefail` fallback
- `test-tag-skill-releases.sh` — tests/ci/test-tag-skill-releases.sh — `tag-skill-releases.sh` on a scratch repository: the version-only refusal (SPEC-0023), tag selection, real tagging against a scratch remote
- `test-check-docs.sh` — tests/ci/test-check-docs.sh — `check-docs.py` (repo copy and template): broken links, superseded ADRs, code fences, the `adr/` folder rule, `DOCS_CHECK_FILES`
- `test-check-versions.sh` — tests/ci/test-check-versions.sh — `check-versions.py` on scratch repos: version and name mismatches, non-SemVer, missing version, CRLF, skills without an entry, external entries
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
