# Tech stack

Derived from the ADRs — do not edit by hand; change the ADR and regenerate.

| Area | Choice | ADR |
|---|---|---|
| Versioning | SemVer 2.0 per skill, in `metadata.version` of its `SKILL.md`; Claude Code plugin data only in `.claude-plugin/marketplace.json` | [ADR-0006](../adr/0006-version-in-skill-md.md) |
| Changelog | git-cliff from Conventional Commits; per-skill changelogs with dated sections | [ADR-0002](../adr/0002-generate-changelog-with-git-cliff.md) |
| Distribution | `npx skills` into `.agents/skills/` (standard), with a `.claude/skills/` copy for Claude Code; the Claude Code plugin marketplace is optional | [ADR-0005](../adr/0005-standard-locations-first.md) |
| Installs in projects | Project by default, global only on request; standard locations first (AGENTS.md, `.agents/skills/`); agent folders only for agent-specific files; MCPs in each agent's own file | [ADR-0005](../adr/0005-standard-locations-first.md) |

## Conventions

- Content: Markdown skills, JSON manifests, shell and Python scripts for hooks and automation.
- Checks instead of a linter: `claude plugin validate .` (marketplace), `check-docs.py` (relative links resolve) and `check-versions.py` (marketplace versions match each SKILL.md).
- Automation: `.github/workflows/on-merge.yml` closes features and tags releases on merge.
- Git, language, documentation and versioning rules: [AGENTS.md](../../AGENTS.md).
