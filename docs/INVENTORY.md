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
- `changelog.md` — CHANGELOG with git-cliff, tested `cliff.toml`
- `code-style.md` — naming per language, readability
- `defensive-programming.md` — trust boundaries, guard clauses, resource checks, timeouts, limits, cleanup
- `git.md` — fallback git convention when no git skill is installed
- `inventory-template.md` — template for a project's `docs/INVENTORY.md`
- `languages.md` — choosing a language per component
- `observability.md` — logging, tracing, error tracking
- `performance.md` — computational cost rules
- `platforms.md` — hosting options (Cloudflare default)
- `project-layout.md` — project tree and CLAUDE.md section
- `sdd.md` — spec / design / tasks templates
- `security.md` — OWASP Top 10 checklist
- `setup.md` — first-use collision check with other skills, `~/.claude/senior-mindset.md`
- `stack.md` — default stack per use case
- `system-design.md` — monolith vs microservices, event-driven
- `testing.md` — test pyramid, TDD, k6
- `versioning.md` — app versioning from `0.0.1-alpha.1`, stages, git-cliff bump, release process

## Hooks and scripts

- `save-image-hook.py` — skills/save-image/scripts/save-image-hook.py — UserPromptSubmit hook that saves pasted images — registered by `skills/save-image/hooks/hooks.json` (plugin) or manually in settings.json

## Repo docs

- `CLAUDE.md` — repo conventions and rules (docs, versioning, git)
- `docs/adr/` — architecture decision records (index in README.md)
- `docs/specs/` — specs for changes to the skills
- `CHANGELOG.md` + `cliff.toml` — repo changelog generated with git-cliff, dated entries
- `skills/<name>/CHANGELOG.md` — per-skill changelog shipped inside each plugin, one dated section per `<name>-vX.Y.Z` tag
