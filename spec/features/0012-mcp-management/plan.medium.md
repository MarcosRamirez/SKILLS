# PLAN-0012: propose, install and manage MCPs from the curated catalog

Spec: [SPEC-0012](spec.md)
Status: In progress
Recommended overall: medium — Claude Sonnet 5.5 (flow is clear once the catalog exists; security details need care)

## Context

Depends on PLAN-0011 (`catalog/mcps.json`). Official docs first for `claude mcp add` and `.mcp.json`.

## Design

- Official docs first: verify `claude mcp add` flags and the `.mcp.json` format before writing the reference.
- Secrets: `${ENV_VAR}` references in `.mcp.json`; values in the user's environment or secret store.
- Scope: project by default, global only when the user picks it (ADR-0005). In Claude Code,
  `--scope project` always explicit (its default is `local`: only this user, not shared);
  `--scope user` only for Global.
- Review routine: at release time or on request, list MCPs not used in the last N sessions and propose removal.
- MCP question at kickoff: multi-select from `catalog/mcps.json`, recommended first; per pick, this
  project (default) or global; servers already available are shown as installed.
- Docs lookup: Context7 (`resolve-library-id` → `query-docs`) → official site → cite; nothing
  private is sent to Context7.

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

### T-2b MCP question, Context7 and directories — medium
- Recommended: medium — Claude Sonnet 5.5 (settled design, verified sources)
- Branch: `feat/0012-t2b-mcp-question-context7`
- Do: re-verify the Context7 install, header and tool names (github.com/upstash/context7) and what
  happens when the key is unset; MCP multi-select question at kickoff with the per-pick scope
  choice; one-time question for projects set up before this version; Context7 as the first
  recommended entry; docs order in SKILL.md (Context7 → official site → cite); directories under
  the question, links re-verified
- Files: ~ SKILL.md, ~ references/mcp.md, ~ catalog/mcps.json
- Done when: AC-4, AC-5

### T-3 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0012-t3-release`
- Do: minor bump, docs, changelogs; PR body with `Closes-Spec: SPEC-0012`
- Files: ~ plugin.json, ~ READMEs, ~ CHANGELOGs
- Done when: bot closes spec and plan; plugin update

## Verification

Headless Postgres test proposes read-only; after consent `.mcp.json` has no secret values.
Kickoff test shows Context7 as recommended and the directories; a docs question goes through
Context7 when it is installed, the official site otherwise.

## Risks

- Secrets leaking into `.mcp.json` → grep check in the test and a rule in mcp.md. Running
  `claude mcp add` with `${CONTEXT7_API_KEY}` in double quotes lets the shell write the real key →
  single quotes, or write `.mcp.json` directly.
- An unset `${CONTEXT7_API_KEY}` stays as literal text in the header → check how Context7 reacts in
  T-2b (no header if it rejects it).
- Directory links going dead (mcp.so already fails DNS) → re-verified in T-2b and at each release.
- Private code sent to Context7 → R-7 rule and AC-5.

## Out of scope

Custom MCP servers.

## Changelog

- 2026-10-14: aligned with ADR-0005/0006 (SPEC-0024)
