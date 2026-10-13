# Tech stack

Derived from the ADRs — do not edit by hand; change the ADR and regenerate.

| Area | Choice | ADR |
|---|---|---|
| Versioning | SemVer 2.0 per skill, in each `plugin.json` | [ADR-0001](../adr/0001-version-each-skill-with-semver.md) |
| Changelog | git-cliff from Conventional Commits; per-skill changelogs with dated sections | [ADR-0002](../adr/0002-generate-changelog-with-git-cliff.md) |
| Distribution | Claude Code plugin marketplace, one plugin per skill | [ADR-0003](../adr/0003-distribute-skills-as-plugin-marketplace.md) |
| Installs in projects | Skills and MCPs at project scope by default; global only on request | [ADR-0004](../adr/0004-install-skills-and-mcps-at-project-scope.md) |

## Conventions

- Content: Markdown skills, JSON manifests, shell and Python scripts for hooks and automation.
- Checks instead of a linter: `claude plugin validate` (marketplace and `--strict` per skill), relative links resolve.
- Automation: `.github/workflows/on-merge.yml` closes features and tags releases on merge.
- Git, language, documentation and versioning rules: [CLAUDE.md](../../CLAUDE.md).
