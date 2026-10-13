# SPEC-0020: enable and disable MCPs as the work needs them

Status: Draft
Date: 2026-10-13
Approved by: (empty until the user explicitly approves)

## Problem

Every enabled MCP server costs something: context window (in agents that load all tool
definitions upfront), noise in tool selection, and risk (a server with write access that stays on
when nothing needs it). Some agents let you switch servers on and off; the skill should use that, so
only the MCPs the current work needs are active.

How each agent behaves (verified in their official docs, 2026-10-13):

| Agent | Context cost of an enabled MCP | How to switch one off |
|---|---|---|
| **OpenCode** | Every enabled server adds all its tools to the context ("This can quickly add up if you have a lot of tools") | `"enabled": false` in the server's entry in `opencode.json`; per tool or per agent with `tools` globs (`"github_*": false`) |
| **Claude Code** | Low by default: **tool search** loads only tool names and server instructions at start and the definitions on demand. Upfront loading happens with `ENABLE_TOOL_SEARCH=false`, servers with `alwaysLoad: true`, and some deployments (non-first-party `ANTHROPIC_BASE_URL`, Foundry on Azure, pre-4.5 models on Google Cloud) | `/mcp` panel (per project, stored in `~/.claude.json` as `disabledMcpServers`); project `.mcp.json` servers via `disabledMcpjsonServers` / `enabledMcpjsonServers`; `ENABLE_TOOL_SEARCH=auto:N` threshold mode |

## Requirements

- R-1 **Plans declare the MCPs they need**: each step of a plan may list `MCPs: <names>` (none by default).
- R-2 **Enable what the step needs, disable what it does not**, where the agent allows it from configuration:
  - OpenCode: edit `opencode.json` (`enabled`, or `tools` globs, per agent when useful);
  - Claude Code: check that tool search is active. If it is, only servers with write access or
    `alwaysLoad` are worth switching off; otherwise propose switching off the unused ones. The AI
    cannot press `/mcp`, so it proposes the action to the user, or edits `disabledMcpjsonServers` for
    project servers in `.claude/settings.local.json`, effective next session;
  - other agents: follow their docs if they support toggling (portability: SPEC-0013), else document only.
- R-3 Never switch anything on or off without telling the user, and never touch servers outside the
  project's scope (user-level servers are proposed, not edited).
- R-4 **Safety first:** servers with write access (databases, cloud, GitHub write) are off unless the
  current step needs them, even when context is not a concern.
- R-5 Command "which MCPs are active and why" lists enabled servers, what each costs (upfront or
  deferred) and which steps need them (fits SPEC-0014 status).
- R-6 Never set `alwaysLoad: true` except for a tiny server the user wants on every turn.

## Acceptance criteria

- AC-1 `references/mcp-toggle.md` with the per-agent table, the plan `MCPs:` field and the rules.
- AC-2 Headless test in OpenCode: a plan step that needs no GitHub MCP → proposes `enabled: false` for it, applies only after consent.
- AC-3 Headless test in Claude Code with tool search off (`ENABLE_TOOL_SEARCH=false`) → proposes disabling unused servers; with tool search on → only write-access servers are proposed.
- AC-4 No toggle happens without telling the user (checked in both tests).

## Out of scope

- Building or hosting MCP servers.
- Choosing and installing MCPs (SPEC-0012).
