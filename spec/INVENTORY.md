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
- `project-layout.md` — project tree and CLAUDE.md section
- `sdd.md` — spec / design / tasks templates
- `release-automation.md` — specs close on merge, releases tag themselves; uses the templates below
- `security.md` — OWASP Top 10 checklist
- `setup.md` — first-use collision check with other skills, `~/.claude/senior-mindset.md`
- `stack.md` — default stack per use case
- `system-design.md` — monolith vs microservices, event-driven
- `testing.md` — test pyramid, TDD, k6
- `versioning.md` — app versioning from `0.0.1-alpha.1`, stages, git-cliff bump, release process

## senior-mindset templates

Copied into app projects by the skill (`skills/senior-mindset/templates/release-automation/`):

- `on-merge.yml` — workflow: tag the release, close specs named in `Closes-Spec:`
- `close-specs.sh` — marks specs Implemented from a PR body (also used by this repo's workflow)
- `tag-release.sh` — tags `v<version>` from package.json / pyproject.toml / Cargo.toml and creates the GitHub Release

## Hooks and scripts

- `save-image-hook.py` — skills/save-image/scripts/save-image-hook.py — UserPromptSubmit hook that saves pasted images — registered by `skills/save-image/hooks/hooks.json` (plugin) or manually in settings.json

## Automation

- `on-merge.yml` — .github/workflows/on-merge.yml — after each merge to master: closes specs named in `Closes-Spec:`, tags new skill versions — runs automatically
- `close-specs.sh` — skills/senior-mindset/templates/release-automation/close-specs.sh — marks specs Implemented from a PR body; shipped with the skill for apps and reused by this repo's workflow (single copy)
- `tag-skill-releases.sh` — .github/scripts/tag-skill-releases.sh — tags `<name>-vX.Y.Z` and creates GitHub Releases — `DRY_RUN=1 bash .github/scripts/tag-skill-releases.sh`

## Repo docs

- `CLAUDE.md` — repo conventions and rules (docs, versioning, git)
- `spec/constitution/` — mission, tech stack (derived from the ADRs) and roadmap (states updated by the bot)
- `spec/features/` — one folder per feature (`spec.md`, `plan.<tier>.md`, `tasks.md`); "run plan NNNN" executes it
- `spec/adr/` — architecture decision records (index in README.md)
- `CHANGELOG.md` + `cliff.toml` — repo changelog generated with git-cliff, dated entries
- `skills/<name>/CHANGELOG.md` — per-skill changelog shipped inside each plugin, one dated section per `<name>-vX.Y.Z` tag
