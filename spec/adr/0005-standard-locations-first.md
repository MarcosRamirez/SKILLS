# ADR-0005: Standard locations first; agent folders only for agent-specific files

Status: Accepted
Date: 2026-10-13
Supersedes: ADR-0003, ADR-0004

## Context

senior-mindset must work in any agent, not only Claude Code. Several conventions are now shared
across agents (checked 2026-10-13):

- **AGENTS.md** holds project instructions, and Claude Code reads it natively since v2.1.277 (SPEC-0019).
- **`.agents/skills/`** (project) and **`~/.agents/skills/`** (user) are the cross-client skills
  convention of the Agent Skills standard (agentskills.io). Codex, OpenCode and others read them.
  Claude Code only reads `.claude/skills/` and `~/.claude/skills/`; the request to support
  `.agents/skills/` is still open (anthropics/claude-code#31005).
- **`npx skills`** (vercel-labs/skills) installs a skill from a repository for many agents at once:
  - into the project by default, or global with `-g`;
  - into each agent's folder (for Claude Code, `.claude/skills/`), as a symlink or a copy (`--copy`);
  - updates with `npx skills update`.
- **MCP servers** have no shared configuration file: each agent keeps its own (Claude Code: `.mcp.json`).

ADR-0003 made the Claude Code plugin marketplace the main install path. ADR-0004 tied the project
default to Claude Code commands (`claude plugin install --scope project`). Both put one vendor first.

## Options considered

1. **Claude Code first** (ADR-0003, ADR-0004): plugin updates work, but other agents get nothing
   and the skill depends on one vendor's mechanism.
2. **Each agent's own folder**: one copy per agent, nothing shared.
3. **Standard first**: use the shared conventions wherever they exist. Use an agent's own folder
   only for what is specific to it, or as a bridge while it does not read the standard location.

## Decision

We choose **option 3**, as decided by the user:

- **Project instructions:** AGENTS.md (SPEC-0019).
- **Skills:** `.agents/skills/<name>/`, installed with `npx skills`. An agent that does not read that
  folder gets a bridge in its own folder. Today that is Claude Code, with a copy in
  `.claude/skills/<name>/`: a copy, because a committed symlink breaks when the repository is
  cloned on Windows.
- **MCP servers:** each agent's own project file (Claude Code: `.mcp.json`), because there is no
  shared standard yet.
- **Agent-specific features** live in that agent's folder or files: Claude Code hooks, enabling and
  disabling MCPs (SPEC-0020), the plugin marketplace.
- **Scope:** the project by default, kept from ADR-0004. Global (`npx skills -g`, `~/.agents/skills/`)
  only when the user asks.
- **Plugin marketplace:** stays as an optional channel that only Claude Code uses.

## Consequences

- Positive:
  - the same project works with Claude Code, Codex, OpenCode and other agents;
  - installs do not depend on one vendor;
  - the skills travel with the repository: the team and cloud sessions get them without installing anything.
- Negative:
  - Claude Code needs the bridge copy until it reads `.agents/skills/`;
  - copies do not update themselves, so updates arrive as pull requests;
  - `npx skills` needs Node.
- When Claude Code reads `.agents/skills/`, the bridge goes away, and that change gets a new ADR.
