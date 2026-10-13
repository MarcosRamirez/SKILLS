# SPEC-0012: propose, install and manage MCPs from the curated catalog

Status: Draft
Date: 2026-10-13
Approved by: (empty until the user explicitly approves)

## Problem

MCPs (GitHub, databases, browsers, docs) make agents far more capable, but choosing, installing
and keeping them safe is manual and easy to get wrong (secrets in config, over-broad access).

## Requirements

- R-1 Proposals come from `catalog/mcps.json` (SPEC-0011), matched to the project's stack and tasks.
- R-2 Install only with consent, **in the project by default**: `claude mcp add --scope project` →
  `.mcp.json` committed **without secrets** (environment variables), recorded in INVENTORY. The flag
  is always explicit, because Claude Code's default scope is `local` (only this user, not shared).
  Global (`--scope user`) only when the user asks for it (SPEC-0011 R-8).
- R-3 Least privilege by default (e.g. read-only database role, scoped tokens).
- R-4 Management: list, update, and propose removing unused MCPs.

## Acceptance criteria

- AC-1 `references/mcp.md` with the install flow, secret handling, least privilege and review routine.
- AC-2 Headless test on a Postgres project → proposes the Postgres MCP read-only, installs nothing without consent.
- AC-3 After consent, `.mcp.json` contains no secret values (checked by grep in the test).

## Out of scope

- Writing custom MCP servers.
