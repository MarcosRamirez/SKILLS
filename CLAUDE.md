# CLAUDE.md

Plug-and-play skills for Claude Code, distributed as a plugin marketplace
(`/plugin marketplace add MarcosRamirez/SKILLS`).

## Engineering conventions

Managed with the senior-mindset skill. Details and reasons live in the ADRs.

- **Project type:** documentation-first repo: Markdown skills, JSON manifests, one Python hook.
  Not applicable here: database, deployment platform, API, logging, load tests (no runtime).
- **Distribution:** plugin marketplace in `.claude-plugin/marketplace.json`, one plugin per skill. See [ADR-0003](docs/adr/0003-distribute-skills-as-plugin-marketplace.md).
- **Versioning:** SemVer 2.0 per skill in its `plugin.json`. See [ADR-0001](docs/adr/0001-version-each-skill-with-semver.md) and the rules below.
- **Changelog:** `CHANGELOG.md` generated with git-cliff from the commit history. See [ADR-0002](docs/adr/0002-generate-changelog-with-git-cliff.md).
- **Checks (instead of a linter):** `claude plugin validate .` and `claude plugin validate ./skills/<name> --strict`, plus relative links in READMEs must resolve.
- **Language:** skill files, READMEs and docs in English.
- **Git:** default branch `master`, conventions from the `git-workflow` skill. Before creating anything, check [docs/INVENTORY.md](docs/INVENTORY.md).

## Git

- **One branch per change, never commit directly on `master`**, not even a one-line or docs-only change.
  Branch `<type>/<slug>`, merge with `git merge --no-ff`, then delete the branch.
- **Commit often:** one commit per significant change, each leaving the repo coherent.
- Scopes: one per skill (`senior-mindset`, `save-image`), plus `marketplace` and `repo`.
- Push, PRs and merges on GitHub only when the user asks.

## Documentation is updated in the same commit as the change

Whenever a skill, a skill feature or a reference is added, or anything changes what a skill
does or how it is installed, update in the same commit:

- Root `README.md`: skills table, the skill's section, the skills-count badge, the repo
  structure and the install instructions if they change.
- The skill's `README.md`: what it does and its `references/` table.
- `.claude-plugin/marketplace.json` and the skill's `plugin.json`: description if it changes,
  version per the rules below.
- `docs/INVENTORY.md` when files are added, moved or removed.

Before committing, check that every relative link in the READMEs resolves.

## Versioning skills (SemVer 2.0)

**Every change inside `skills/<name>/` bumps that skill's version.** Without a bump,
users who installed it with `/plugin` never receive the update.

- Source of truth: `version` in `skills/<name>/.claude-plugin/plugin.json`. Keep
  `metadata.version` in the skill's `SKILL.md` frontmatter identical. No version in `marketplace.json`.
- **PATCH** (`1.1.0 → 1.1.1`): typos, wording, clarifications, examples that do not change behavior.
- **MINOR** (`1.1.0 → 1.2.0`): new rule, step, reference or feature that does not break what was there.
- **MAJOR** (`1.x → 2.0.0`): a skill or command is removed or renamed, installation or required
  setup changes (e.g. a hook that needs a manual step), or behavior is reversed.
- Only the skill whose files changed is bumped. Changes to the root README or this file bump nothing.
- Unpublished changes are grouped: one bump per push, using the highest level that applies.
- The bump goes in the same commit as the change, or in the last commit of the branch before merging.
- **New skills start at `0.0.1-alpha.1`** and reach `1.0.0` when tested and stable.

## Structure

```text
.claude-plugin/marketplace.json   marketplace manifest
skills/<name>/
  SKILL.md                        what Claude loads
  README.md                       for humans
  .claude-plugin/plugin.json      plugin manifest (version lives here)
  references/ scripts/ hooks/     optional
docs/adr/  docs/specs/  docs/INVENTORY.md
CHANGELOG.md  cliff.toml
```
