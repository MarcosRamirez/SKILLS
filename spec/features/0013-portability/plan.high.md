# PLAN-0013: portable to other agents and open models

Spec: [SPEC-0013](spec.md)
Status: Draft
Recommended overall: high — Claude Opus 5.5 (cross-agent research and redesign of wording)

## Context

Agent Skills is an open format; each agent loads skills/rules differently. Ollama is installed locally for real tests. Likely a major release.

## Design

- Research first: official docs of each agent on skills/rules support and file locations.
- Likely a major release (2.0.0) if installation or usage changes for existing users.
- Ollama is installed on the user's machine; pick a medium-tier model from `references/models.md` for the test.

## Steps

### T-1 Research — high
- Recommended: high — Claude Opus 5.5 (reading and comparing official docs)
- Branch: `docs/0013-t1-agent-research`
- Do: for OpenCode, Codex, Gemini CLI, Cursor: skills/rules support, file locations, install method; write findings in the spec
- Files: ~ spec/features/0013-*/design.md
- Done when: findings recorded with sources

### T-2 Portable wording — high
- Recommended: high — Claude Opus 5.5 (rewording without changing behaviour)
- Branch: `feat/0013-t2-portable-wording`
- Do: equivalence table; replace Claude-only tool names with portable wording + mapping
- Files: ~ SKILL.md, ~ references/*
- Done when: AC-1

### T-3 AGENTS.md handling — medium
- Recommended: medium — Claude Sonnet 5.5 (settled design)
- Branch: `feat/0013-t3-agents-md`
- Do: generate or merge AGENTS.md in kickoff and existing projects; never overwrite
- Files: ~ SKILL.md, ~ references/project-layout.md
- Done when: AC-2

### T-4 Install docs per agent — medium
- Recommended: medium — Claude Sonnet 5.5 (docs from research)
- Branch: `docs/0013-t4-install-docs`
- Do: README sections per agent, verified against official docs
- Files: ~ README.md, ~ skills/senior-mindset/README.md
- Done when: AC-3

### T-5 Real test: OpenCode + Ollama — high
- Recommended: high — Claude Opus 5.5 (debugging cross-agent behaviour)
- Branch: `test/0013-t5-opencode-ollama`
- Do: run a small task in a test project with OpenCode and a medium-tier local model; fix findings
- Files: wording fixes
- Done when: AC-4

### T-6 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0013-t6-release`
- Do: major (or minor) bump, docs, changelogs; PR body with `Closes-Spec: SPEC-0013`
- Files: ~ plugin.json, ~ READMEs, ~ CHANGELOGs
- Done when: bot closes spec and plan; plugin update

## Verification

The OpenCode + Ollama run completes the task following the skill's rules (spec first, branch, no code without approval).

## Risks

Small local models ignore long instructions → tier table guidance and shorter Hard rules; agents without skill support → AGENTS.md fallback.

## Out of scope

Agent-specific features beyond what the skill needs.
