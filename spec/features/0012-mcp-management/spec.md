# SPEC-0012: propose, install and manage MCPs from the curated catalog

Status: Draft
Date: 2026-10-13
Approved by: (empty until the user explicitly approves)

## Problem

MCPs (GitHub, databases, browsers, docs) make agents far more capable, but choosing, installing
and keeping them safe is manual and easy to get wrong (secrets in config, over-broad access).

## Requirements

- R-1 Proposals come from `catalog/mcps.json` (SPEC-0011), matched to the project's stack and tasks.
- R-2 Install only with consent, **in the project by default**, in the agent's own project file:
  there is no shared MCP configuration standard (ADR-0005). In Claude Code, `claude mcp add --scope project` →
  `.mcp.json` committed **without secrets** (environment variables), recorded in INVENTORY. The flag
  is always explicit, because Claude Code's default scope is `local` (only this user, not shared).
  Global (`--scope user`) only when the user asks for it (SPEC-0011 R-8).
- R-3 Least privilege by default (e.g. read-only database role, scoped tokens).
- R-4 Management: list, update, and propose removing unused MCPs.
- R-5 **MCP question at each project's kickoff.** The skill lists `catalog/mcps.json` as a
  multi-select question, recommended entries first and marked "(Recommended)", and installs only
  what the user picks:
  - for each pick: "This project (Recommended)" or "Global (all your projects)" (SPEC-0011 R-8);
  - servers already available (global, or already in `.mcp.json`) are shown as installed and not
    proposed again;
  - projects set up before this version are asked once, the next time the skill loads them; the
    answer, even "none", is recorded in the project's conventions so it is not asked again.
- R-6 **Context7 is a recommended entry from the start** (the user's pick; more will be added):
  - up-to-date documentation for libraries and frameworks, by Upstash, MIT licence, read-only;
  - project install: the remote server `https://mcp.context7.com/mcp` in the agent's project MCP file
    (Claude Code: `.mcp.json`);
  - optional free API key for higher rate limits, as `${CONTEXT7_API_KEY}` in the authorization
    header; the value lives in the user's environment and is never committed;
  - the guided `npx ctx7 setup --claude` only for the "Global" option, after checking which scope
    it writes to;
  - tools: `resolve-library-id` → `query-docs`.
- R-7 **Context7 is the default documentation source when installed.** The "official docs first"
  rule becomes:
  1. Context7: resolve the library, then query its docs for the version the project uses;
  2. the official website (WebFetch) when Context7 lacks the library or the version, or the answer
     looks stale;
  3. always cite the source.

  Context7 is an external service, so queries never include secrets or private code.
- R-8 **"Find more MCPs"** under the list, verified directories (official ones first):
  - [Official MCP Registry](https://registry.modelcontextprotocol.io)
  - [Official reference servers](https://github.com/modelcontextprotocol/servers)
  - [Docker MCP Catalog](https://hub.docker.com/mcp)
  - [MCP.Directory](https://mcp.directory)
  - [Smithery](https://smithery.ai)
  - [Glama](https://glama.ai/mcp/servers)
  - [PulseMCP](https://www.pulsemcp.com/servers)

  Anything found there must pass the catalog criteria (SPEC-0011) before it is installed. A server
  the user wants permanently goes into the catalog through a PR.

## Acceptance criteria

- AC-1 `references/mcp.md` with the install flow, secret handling, least privilege and review routine.
- AC-2 Headless test on a Postgres project → proposes the Postgres MCP read-only, installs nothing without consent.
- AC-3 After consent, `.mcp.json` contains no secret values (checked by grep in the test).
- AC-4 Kickoff in a test project shows the MCP list with Context7 marked "(Recommended)" and the
  directories under it; nothing is installed without a selection; a selection lands in `.mcp.json`
  with the literal `${CONTEXT7_API_KEY}`, never its value.
- AC-5 With Context7 installed, a documentation question uses `resolve-library-id` → `query-docs`
  first; without it, the official docs; neither sends secrets or private code.

## Out of scope

- Writing custom MCP servers.
