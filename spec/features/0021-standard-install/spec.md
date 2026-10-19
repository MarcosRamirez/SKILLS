# SPEC-0021: install in the project, standard locations first

Type: feature
Status: Approved
Date: 2026-10-13
Approved by: the user, 2026-10-13, "implementa todas las fases, una a una, con subagentes"

## Problem

Every install path documented today is global and puts Claude Code first:

- `/plugin install` defaults to user scope, and the "ask your agent" and manual paths copy into
  `~/.claude/skills/`.
- Other agents (Codex, OpenCode…) are not covered.
- In this repository the skill is not installed in the project at all. It only works because it is
  installed globally (user scope, version 2.1.0 in the plugin cache). No agent loads
  `skills/senior-mindset/`: that folder is the source.

ADR-0005 puts standard locations first and keeps the project as the default scope. ADR-0006 keeps
Claude Code files out of skill folders.

Facts checked on 2026-10-13:

- `npx skills add <owner>/<repo> --skill <name>` (vercel-labs/skills):
  - installs into the project by default, or global with `-g`;
  - writes into each agent's folder: Claude Code `.claude/skills/`, Codex and OpenCode `.agents/skills/`;
  - uses a symlink or a copy (`--copy`);
  - updates with `npx skills update`;
  - finds `skills/<name>/SKILL.md`, this repository's layout.
- Claude Code does not read `.agents/skills/` (anthropics/claude-code#31005).
- In Claude Code, a personal skill wins over a project skill with the same name. An installed plugin
  and a project skill both load, because plugin skills are namespaced.
- A committed symlink breaks when the repository is cloned on Windows.
- Cloud sessions load the repository's `.claude/skills/`, but not the plugins enabled in `.claude/settings.json`.

## Requirements

- R-1 **Default install, in the project:**
  `npx skills add MarcosRamirez/SKILLS --skill senior-mindset --copy`. It writes
  `.agents/skills/senior-mindset/` and `.claude/skills/senior-mindset/` (the bridge for Claude Code),
  both committed. Global (`-g`) only when the user asks.
- R-2 **From the latest release tag** (`senior-mindset-vX.Y.Z`), never from `master`, which can hold
  merged changes that are not released yet.
- R-3 **READMEs, standard first** (root and skill), in this order:
  1. `npx skills`: in the project, or global with `-g`;
  2. the "ask your agent" prompt: install into `.agents/skills/`, plus the bridge for an agent that
     does not read that folder, and ask before installing globally;
  3. manual copy;
  4. the Claude Code plugin marketplace, as an option for Claude Code only.
- R-4 **On first use, detect where the skill loads from and whether it is duplicated:**
  - a global copy (plugin, `~/.claude/skills/` or `~/.agents/skills/`) plus a project copy: in
    Claude Code both load, or the global one wins. Propose disabling the global plugin for this
    project (`.claude/settings.local.json`) or uninstalling it, warning that other projects then
    need their own install;
  - only a global copy: ask once, "Install it in this project (Recommended)" or "Keep it global";
  - the answer is recorded in the setup file.
- R-5 **"update senior-mindset":** take the latest release tag, run `npx skills` on a branch and
  open a PR with that version's changelog section. Both copies move to the same version.
- R-6 **This repository:**
  - the published version goes in `.agents/skills/`, plus the bridge;
  - `skills/senior-mindset/` stays the source;
  - AGENTS.md explains the three locations, how to try the working copy, and that searches skip
    the installed copies.
- R-7 **Skill folders without Claude Code files** (ADR-0006):
  - the manifest data goes in `marketplace.json` and the version in `metadata.version`;
  - the tag script reads `metadata.version`;
  - a check keeps the versions in `marketplace.json` and `SKILL.md` equal.

## Acceptance criteria

- AC-1 Both READMEs put the standard first and offer the project before global, for `npx skills`,
  "ask your agent" and the manual copy. The marketplace appears as an option for Claude Code only.
- AC-2 In a test project, Claude Code and Codex (or OpenCode) both load the skill from the project install.
- AC-3 On first use, duplicates are detected; with only a global copy, the question is asked once and recorded.
- AC-4 The update command opens a PR that installs the latest release tag.
- AC-5 In this repository, Claude Code has a single senior-mindset active (`/senior-mindset`), and
  the installed copy matches the latest release.
- AC-6 After the manifest moves, `claude plugin update` still moves `/plugin` users to a new version,
  and the tag script tags from `metadata.version` (checked with `DRY_RUN`).

## Out of scope

- Install docs for each agent, and portable wording of `SKILL.md` (SPEC-0013).
- AGENTS.md handling (SPEC-0019).
- Where agents other than Claude Code keep the setup record (SPEC-0013).

## Changelog

- 2026-10-14: R-3 and AC-1 (the READMEs) move to SPEC-0024, which ships the standard install docs
  now, after verifying `npx skills`. T-2 keeps the checks on updates, tags and other agents.

## Changelog

- 2026-10-18: this repo's instructions moved to AGENTS.md (SPEC-0019); references to CLAUDE.md as the conventions file now name AGENTS.md.
