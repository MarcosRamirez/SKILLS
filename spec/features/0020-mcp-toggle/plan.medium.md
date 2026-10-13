# PLAN-0020: enable and disable MCPs as the work needs them

Spec: [SPEC-0020](spec.md)
Status: Draft
Recommended overall: medium — Claude Sonnet 5.5 (agent configs and rules, well documented)

## Context

Depends on SPEC-0012 (MCPs installed through the skill) and fits SPEC-0013 (other agents). Sources:
code.claude.com/docs/en/mcp (tool search, `/mcp`, `disabledMcpjsonServers`, `alwaysLoad`,
`ENABLE_TOOL_SEARCH`) and opencode.ai/docs/mcp-servers (`enabled`, `tools` globs). Re-check both before
implementing: these settings change between versions.

## Design

- **Plan field:** each step may carry `MCPs: postgres, github` (default: none). The skill reads it
  before starting the step.
- **Decision per server:** needed by the step → on; not needed and (write access or loaded upfront)
  → propose off; not needed, read-only and deferred → leave as is.
- **Where the change is made:**
  - OpenCode → `opencode.json`;
  - Claude Code → a proposal for `/mcp`, or `disabledMcpjsonServers` in `.claude/settings.local.json` for project servers (next session).
- **Tool search check (Claude Code):** `ENABLE_TOOL_SEARCH` unset or `true`/`auto` on a first-party host
  means deferral is on. A non-first-party `ANTHROPIC_BASE_URL` turns it off unless the variable is set explicitly.

## Steps

### T-1 Reference and plan field — medium
- Recommended: medium — Claude Sonnet 5.5 (documentation from verified sources)
- Branch: `feat/0020-t1-mcp-toggle-reference`
- Do: re-verify both agents' docs; write references/mcp-toggle.md; add the `MCPs:` field to the plan template (plans.md)
- Files: + references/mcp-toggle.md, ~ references/plans.md
- Done when: AC-1

### T-2 Behaviour in SKILL.md and the active-MCPs command — medium
- Recommended: medium — Claude Sonnet 5.5 (wiring)
- Branch: `feat/0020-t2-toggle-behaviour`
- Do: per-step enable/disable proposal; write-access safety rule; "which MCPs are active" command (with SPEC-0014)
- Files: ~ SKILL.md, ~ references/commands.md (if SPEC-0014 is in)
- Done when: R-1…R-6

### T-3 Headless tests — high
- Recommended: high — Claude Opus 5.5 (two agents, real configs)
- Branch: `test/0020-t3-toggle-tests`
- Do: OpenCode test (AC-2) and Claude Code tests with tool search off and on (AC-3); check AC-4
- Files: wording fixes
- Done when: AC-2…AC-4

### T-4 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0020-t4-release`
- Do: minor bump, docs, changelogs; PR body with `Closes-Spec: SPEC-0020`
- Done when: the bot closes spec, plan and roadmap row

## Verification

The tests above; `claude plugin validate --strict`.

## Risks

- Agent settings change names between versions → re-verify in T-1 and cite the docs in the reference.
- Disabling a server the user relies on elsewhere → only project-scope edits; user-level servers are proposed, never edited.

## Out of scope

Choosing and installing MCPs (SPEC-0012).
