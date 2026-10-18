# AGENTS.md: the project's instructions

The project's conventions live in **`AGENTS.md`**, the file most coding agents read (Codex, Cursor,
Gemini CLI, Copilot, OpenCode, Zed…). Claude Code reads it natively since v2.1.277, but **only when
no `CLAUDE.md` or `CLAUDE.local.md` exists** in the working directory or above. When both exist,
Claude reads only `CLAUDE.md` and silently ignores `AGENTS.md`
(source: code.claude.com/docs/en/memory, "AGENTS.md").

The kickoff writes to `AGENTS.md`: the `## Engineering conventions` section, the links to
`spec/constitution/`, `spec/INVENTORY.md` and `spec/adr/README.md`, the "Git rules that always hold"
block, `Code: <folder>` and every recorded choice (`Automations: …`, `Default branch: …`).
The section template is in [project-layout.md](project-layout.md).

## What stays in CLAUDE.md

Only what is specific to Claude Code: hooks, skills, plugins, slash commands, subagents, `/config` and
settings. Everything else goes to `AGENTS.md`. A `CLAUDE.md` looks like this:

```markdown
@AGENTS.md

## Claude Code
(hooks, skills, plugins, slash commands, settings: only if any)
```

## Cases

Detect `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md` and `.claude/AGENTS.md` at the
root and above, and per package in a monorepo. Check whether each CLAUDE file starts with `@AGENTS.md`.

| Case | What the skill does |
|---|---|
| New project | Creates **only `AGENTS.md`**. No `CLAUDE.md`: Claude Code reads AGENTS.md natively |
| Only `CLAUDE.md` | Proposes migrating: `git mv CLAUDE.md AGENTS.md` (keeps history) and a new `CLAUDE.md` with `@AGENTS.md` plus, below it, only Claude Code-specific content. Change notice + branch |
| Only `AGENTS.md` | Uses it as the source. Does **not** create a `CLAUDE.md` |
| Both; `CLAUDE.md` already imports `@AGENTS.md` | Nothing to migrate; moves anything that is not Claude-specific from `CLAUDE.md` into `AGENTS.md`, if any |
| Both, with different content | **Warns** that Claude currently ignores `AGENTS.md`. Proposes merging into `AGENTS.md`: non-conflicting content merges by itself, each contradictory rule is asked with the question tool, nothing is lost. `CLAUDE.md` keeps only the import. Change notice + branch |
| `CLAUDE.md` is a symlink | On Windows or shared repos, replaces it with the `@AGENTS.md` import (symlinks break on Windows clones) |
| `CLAUDE.local.md` present | Respected; it must start with `@AGENTS.md` (see the safety rule) |
| Monorepo with an `AGENTS.md` per package | Same rule per folder; the closest `AGENTS.md` wins |

## Safety rule

In a project with `AGENTS.md`, any `CLAUDE.md` or `CLAUDE.local.md` must start with `@AGENTS.md`.
When the skill creates one or finds one without that line, it proposes adding it, because otherwise
Claude stops reading `AGENTS.md`. If a session does not see `AGENTS.md` (Claude Code older than
v2.1.277, sessions without support; check with `/memory`), the documented fix is the one-line `CLAUDE.md`.

## Not project instructions

`~/.claude/CLAUDE.md` (the user's global file) and `~/.claude/senior-mindset.md` are user-level and
stay as they are. Other agents' config files (`.cursorrules`, `.github/copilot-instructions.md`,
`GEMINI.md`) are a separate feature (SPEC-0013).
