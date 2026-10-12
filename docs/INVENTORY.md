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
- `git.md` — fallback git convention when no git skill is installed
- `inventory-template.md` — template for a project's `docs/INVENTORY.md`
- `languages.md` — choosing a language per component
- `observability.md` — logging, tracing, error tracking
- `performance.md` — computational cost rules
- `platforms.md` — hosting options (Cloudflare default)
- `project-layout.md` — project tree and CLAUDE.md section
- `sdd.md` — spec / design / tasks templates
- `security.md` — OWASP Top 10 checklist
- `stack.md` — default stack per use case
- `system-design.md` — monolith vs microservices, event-driven
- `testing.md` — test pyramid, TDD, k6
- `versioning.md` — app versioning from `0.0.1-alpha.1`, stages, git-cliff bump, release process

## Hooks and scripts

- `save-image-hook.py` — skills/save-image/scripts/save-image-hook.py — UserPromptSubmit hook that saves pasted images — registered by `skills/save-image/hooks/hooks.json` (plugin) or manually in settings.json
- `save-image-hook.py` (duplicate) — src/hooks/save-image-hook.py — identical copy, referenced by nothing — candidate for removal

## Repo docs

- `CLAUDE.md` — repo conventions and rules (docs, versioning, git)
- `docs/adr/` — architecture decision records (index in README.md)
- `docs/specs/` — specs for changes to the skills
- `CHANGELOG.md` + `cliff.toml` — changelog generated with git-cliff
