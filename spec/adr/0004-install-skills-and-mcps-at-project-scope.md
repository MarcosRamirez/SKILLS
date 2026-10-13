# ADR-0004: Install skills and MCPs at project scope by default

Status: Superseded by ADR-0005
Date: 2026-10-13

## Context

senior-mindset will propose and install skills (SPEC-0011) and MCPs (SPEC-0012). Claude Code can
install both at several scopes, and its own defaults differ: plugins go to `user` (every project)
and MCP servers to `local` (this project, only for you, not shared). A tool installed for every
project adds context and permissions where it is not needed; a tool installed only for you is
missing for the rest of the team.

## Options considered

1. **Claude Code's defaults** (`user` for plugins, `local` for MCPs) — no flags, but plugins load in
   every project and MCPs are not shared with the team.
2. **Global (`user`) for everything** — install once, but every project pays the context and the
   permissions of tools it does not use.
3. **Project scope by default, global on request** — skills in the project's `.claude/settings.json`
   (`claude plugin install … --scope project`), MCPs in `.mcp.json` (`claude mcp add --scope project`),
   both committed so the whole team gets the same tools; "Global" is one option in the install question.

## Decision

We choose **option 3**, as decided by the user. The skill always passes `--scope project`
explicitly, because neither default is the project. Global installs (`--scope user`) happen only
when the user picks them and are recorded in `~/.claude/senior-mindset.md`; project installs are
recorded in the project's INVENTORY.

## Consequences

- Positive: each project carries only the tools it needs, and the team shares them through git.
- Negative: a tool used everywhere (e.g. Context7) is installed once per project unless the user
  picks "Global"; a committed `.mcp.json` needs care with secrets (`${VAR}` references only, SPEC-0012).
- Project-scoped MCP servers ask for approval in interactive sessions, but `claude -p` loads them
  without asking, so headless tests cannot rely on that prompt.
