# PLAN-0012: propose, install and manage MCPs from the curated catalog

Spec: [SPEC-0012](spec.md)
Status: Draft
Recommended overall: medium — Claude Sonnet 5.5 (flow is clear once the catalog exists; security details need care)

## Context

Depends on PLAN-0011 (`catalog/mcps.json`). Official docs first for `claude mcp add` and `.mcp.json`.

## Design

- Official docs first: verify `claude mcp add` flags and the `.mcp.json` format before writing the reference.
- Secrets: `${ENV_VAR}` references in `.mcp.json`; values in the user's environment or secret store.
- Scope: `--scope project` always explicit (Claude Code's default is `local`: only this user, not
  shared); `--scope user` only when the user picks Global (ADR-0004).
- Review routine: at release time or on request, list MCPs not used in the last N sessions and propose removal.

## Steps

### T-1 mcp.md from official docs — medium
- Recommended: medium — Claude Sonnet 5.5 (reference writing with verification)
- Branch: `feat/0012-t1-mcp-reference`
- Do: verify current `claude mcp` docs; write install flow, `${ENV}` secrets, least privilege, review routine
- Files: + references/mcp.md
- Done when: AC-1

### T-2 MCP flow + headless tests — high
- Recommended: high — Claude Opus 5.5 (security behaviour must be proven)
- Branch: `feat/0012-t2-mcp-flow`
- Do: wire proposal/consent/install/record into SKILL.md; test on a Postgres project; grep `.mcp.json` for secrets
- Files: ~ SKILL.md
- Done when: AC-2, AC-3

### T-3 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0012-t3-release`
- Do: minor bump, docs, changelogs; PR body with `Closes-Spec: SPEC-0012`
- Files: ~ plugin.json, ~ READMEs, ~ CHANGELOGs
- Done when: bot closes spec and plan; plugin update

## Verification

Headless Postgres test proposes read-only; after consent `.mcp.json` has no secret values.

## Risks

Secrets leaking into `.mcp.json` → grep check in the test and a rule in mcp.md.

## Out of scope

Custom MCP servers.
