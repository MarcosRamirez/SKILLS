# ADR-0006: Version each skill in its SKILL.md; no Claude Code files inside skill folders

Status: Accepted
Date: 2026-10-13
Supersedes: ADR-0001

## Context

ADR-0001 put each skill's SemVer version in `skills/<name>/.claude-plugin/plugin.json`, with the
`SKILL.md` frontmatter mirroring it. ADR-0005 makes the standard install the main path: a skill
folder is copied as it is into `.agents/skills/<name>/` and, as a bridge for Claude Code, into
`.claude/skills/<name>/`. A Claude Code manifest inside that folder has two effects:

- the standard copy carries a file that only Claude Code reads;
- Claude Code loads a `.claude/skills/` folder that contains `.claude-plugin/plugin.json` as a
  skills-directory plugin, not as a plain skill. The skill is then namespaced
  (`/senior-mindset:senior-mindset`), loads only from the session's primary working directory, and
  only after the workspace trust dialog (code.claude.com/docs/en/plugins/loading).

The Agent Skills standard already has a place for this data: the `metadata` field of the
`SKILL.md` frontmatter, which each skill already uses for `metadata.version`. A Claude Code
marketplace entry can act as the plugin manifest when the plugin has no `plugin.json` ("the entry
is the manifest"), and its `version` is then the one `claude plugin update` compares.

## Options considered

1. **Keep `plugin.json` in each skill folder** (ADR-0001): no change, but every standard copy
   carries a Claude Code file and loads in Claude Code as a namespaced plugin.
2. **Version in `SKILL.md` `metadata.version`; Claude Code plugin data in the marketplace entry**:
   the skill folder is pure Agent Skills, and the optional marketplace keeps working.
3. **Strip `.claude-plugin/` when copying**: the source stays as it is, but every installer and
   copy has to remember to strip it.

## Decision

We choose **option 2**, as decided by the user:

- Each skill keeps SemVer 2.0. Its source of truth is `metadata.version` in its `SKILL.md` frontmatter.
- No `.claude-plugin/` folder inside `skills/<name>/`.
- The Claude Code plugin data (name, description, version, author, homepage, repository, licence)
  lives in the skill's entry in `.claude-plugin/marketplace.json` at the repository root.
- A check keeps the entry's `version` equal to `metadata.version`.
- The bump rules, the `0.0.1-alpha.1` start and per-skill tags (`<name>-vX.Y.Z`) do not change.

## Consequences

- Positive:
  - a skill folder works in any agent as it is;
  - Claude Code loads the bridge copy as a plain `/senior-mindset` skill;
  - the marketplace remains an optional channel.
- Negative:
  - the tag script reads `SKILL.md` instead of `plugin.json`;
  - `claude plugin validate ./skills/<name> --strict` no longer applies, so validation runs on the marketplace;
  - the version appears in two places (`SKILL.md` and the marketplace entry), which the check keeps in sync.
- Must be verified when implemented: `claude plugin update` still moves plugin users to a new
  version once the manifest lives only in the marketplace entry.
