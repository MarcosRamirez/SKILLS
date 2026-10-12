# SPEC-0002 design

## Decisions

- **"On install" means "on first use".** A skill cannot run code on install. Step 0a checks
  `~/.claude/senior-mindset.md`, a user-level file, so the setup happens once per user;
  projects may override decisions in their CLAUDE.md.
- **Collisions are resolved per area, not all-or-nothing.** For example, commit format from
  another skill and branch/PR flow from senior-mindset.
- **Cheap inventory:** read skill names and descriptions only (the in-context skills list plus
  `SKILL.md` frontmatter on disk), never whole skill bodies.
- **PR flow:**
  - Choosing it in the setup grants standing permission to push work branches and open PRs.
  - The AI never merges a PR or pushes to the default branch.
  - Dependent tasks are stacked: each PR's base is the previous task's branch; GitHub retargets the PR when the base branch is deleted after merge.
- **Dated changelog:**
  - Entries in `[Unreleased]` show their commit date.
  - Released sections are dated by their tag.
  - Per-skill changelogs use `git cliff --include-path "skills/<name>/**" --tag-pattern "<name>-v.*"`.
  - Tags go on the release merge commit (the one that bumps the version). A tag on a commit outside the include path is filtered out and lost — verified in a scratch clone.

## Components

- New: `skills/senior-mindset/references/setup.md`, `skills/*/CHANGELOG.md`.
- Changed: `SKILL.md` (Steps 0a, 0b, 4, 7), `references/git.md`, `references/versioning.md`,
  `references/changelog.md`, repo `cliff.toml`, `CHANGELOG.md`, `CLAUDE.md`, READMEs, `docs/INVENTORY.md`.
- Tags: `senior-mindset-v1.0.0` (7bba629), `-v1.1.0` (57a65e4), `-v1.2.0` (e1a91df), `save-image-v1.0.0` (7bba629).

## Risks

- The setup asks questions on first use, which is friction → only areas with a real collision are asked about.
- Stacked PRs merged out of order → each PR body states its base and its merge order.
