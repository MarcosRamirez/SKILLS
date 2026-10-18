# SPEC-0019: AGENTS.md as the single source of project instructions

Status: Approved
Date: 2026-10-13
Approved by: the user, 2026-10-13, "implementa todas las fases, una a una, con subagentes"

## Problem

senior-mindset writes the project's conventions into `CLAUDE.md`, a Claude-only file. Most coding
agents (Codex, Cursor, Gemini CLI, Copilot, OpenCode, Zed…) read `AGENTS.md`, and so does Claude
Code since v2.1.277 — but only when no `CLAUDE.md` or `CLAUDE.local.md` exists in the working
directory or above. When both exist, Claude reads only `CLAUDE.md` and silently ignores `AGENTS.md`
(source: code.claude.com/docs/en/memory, "AGENTS.md").

## Requirements

- R-1 Everything the skill writes today in `CLAUDE.md` (the `## Engineering conventions` section and
  the links to the constitution, INVENTORY and ADRs) goes to **`AGENTS.md`**.
- R-2 Behaviour per case:

| Case | What the skill does |
|---|---|
| New project | Creates **only `AGENTS.md`**. No `CLAUDE.md`: Claude Code reads AGENTS.md natively |
| Only `CLAUDE.md` | Proposes migrating: `git mv CLAUDE.md AGENTS.md` (keeps history) and a new `CLAUDE.md` with `@AGENTS.md` plus, below it, only Claude Code-specific content. Change notice + branch |
| Only `AGENTS.md` | Uses it as the source. Does **not** create a `CLAUDE.md` |
| Both; `CLAUDE.md` already imports `@AGENTS.md` | Nothing to migrate; moves anything that is not Claude-specific from `CLAUDE.md` into `AGENTS.md`, if any |
| Both, with different content | **Warns** that Claude currently ignores `AGENTS.md`. Proposes merging into `AGENTS.md`: non-conflicting content merges by itself, each contradictory rule is asked with the question tool, nothing is lost. `CLAUDE.md` keeps only the import. Change notice + branch |
| `CLAUDE.md` is a symlink | On Windows or shared repos, replaces it with the `@AGENTS.md` import (symlinks break on Windows clones) |
| `CLAUDE.local.md` present | Respected; it must start with `@AGENTS.md` (see R-2b) |
| Monorepo with an `AGENTS.md` per package | Same rule per folder; the closest `AGENTS.md` wins |

- R-2b **Safety rule:** in a project with `AGENTS.md`, any `CLAUDE.md` or `CLAUDE.local.md` must start
  with `@AGENTS.md`. When the skill creates one or finds one without that line, it proposes adding it,
  because otherwise Claude stops reading `AGENTS.md`. If a session does not see `AGENTS.md` (Claude Code
  older than v2.1.277, sessions without support; check with `/memory`), the documented fix is the
  one-line `CLAUDE.md`.
- R-3 Claude Code-specific content stays in `CLAUDE.md`: hooks, skills, plugins, slash commands,
  subagents, `/config` and settings. Everything else goes to `AGENTS.md`.
- R-4 Unchanged: `~/.claude/CLAUDE.md` (user global) and `~/.claude/senior-mindset.md`.
- R-5 Other AI configs (`.cursorrules`, `.github/copilot-instructions.md`, `GEMINI.md`) are handled by
  SPEC-0013 (portability), which now links here instead of "generate AGENTS.md next to CLAUDE.md".
- R-6 This repository migrates: `git mv CLAUDE.md AGENTS.md` and a one-line `CLAUDE.md` with `@AGENTS.md`.

## Acceptance criteria

- AC-1 Skill and references no longer name `CLAUDE.md` as the home of the conventions, except the one-line import file.
- AC-2 Headless tests, one per case:
  - new project → only `AGENTS.md`, **no `CLAUDE.md`**;
  - only CLAUDE → migration proposed;
  - only AGENTS → no CLAUDE.md created;
  - both different → warning and merge proposal, nothing touched;
  - both with import → nothing to do;
  - `CLAUDE.local.md` without the import → proposes adding it.
- AC-3 In a real session in this repo, `/memory` shows `AGENTS.md` loaded through `CLAUDE.md`.
- AC-4 This repo migrated with history kept (`git log --follow AGENTS.md`).

## Out of scope

- Other agents' config files (SPEC-0013).
