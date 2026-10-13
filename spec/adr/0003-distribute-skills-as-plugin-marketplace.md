# ADR-0003: Distribute skills as a plugin marketplace

Status: Superseded by ADR-0005
Date: 2026-10-12

## Context

Installing a skill meant copying folders by hand and, for skills with hooks, editing
`settings.json` with a local path. Updates had to be repeated manually.

## Options considered

1. **Manual copy only** — no extra files, but no updates and error-prone hook setup.
2. **Ask your agent to install from the GitHub URL** — easy, but still a copy with no update path.
3. **Claude Code plugin marketplace** — `/plugin marketplace add MarcosRamirez/SKILLS`, one-command
   install and update, hooks registered automatically via `hooks/hooks.json`.

## Decision

We choose **option 3** as the main path and keep options 1 and 2 documented as alternatives.
Each skill folder is a plugin root (`source: "./skills/<name>"`); a `SKILL.md` at the plugin
root loads as a skill, so no restructuring was needed.

## Consequences

- Positive: one-command install and update; hooks need no manual setup.
- Negative: the skill is invoked namespaced (`/senior-mindset:senior-mindset`); every skill needs a
  `plugin.json` and a marketplace entry; versions must be bumped (ADR-0001).
- Files a plugin uses must live inside its folder: only the plugin directory is copied to the cache.
