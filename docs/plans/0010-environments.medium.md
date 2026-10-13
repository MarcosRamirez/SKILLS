# PLAN-0010: environments: local, preview, staging, production

Spec: [SPEC-0010](../specs/0010-environments/spec.md)
Status: Draft
Recommended overall: medium — Claude Sonnet 5.5 (well-known practice, mostly reference writing)

## Context

Decided with the user: default local + preview + staging + production; development only for teams. Mapping branch/PR/merge/tag → environment. Same artifact promoted.

## Steps

### T-1 environments.md — medium
- Recommended: medium — Claude Sonnet 5.5 (reference from a settled design)
- Branch: `feat/0010-t1-environments-reference`
- Do: table, mapping, 12-factor config, secrets and data per environment, migrations, parity, platform notes (check Cloudflare and Vercel docs)
- Files: + references/environments.md
- Done when: AC-1

### T-2 Kickoff question + ADR — medium
- Recommended: medium — Claude Sonnet 5.5 (wiring)
- Branch: `feat/0010-t2-environments-kickoff`
- Do: add the environments question with the default recommended; ADR template
- Files: ~ SKILL.md
- Done when: AC-2

### T-3 Deploy automation decision — high
- Recommended: high — Claude Opus 5.5 (scope decision for the automations catalog)
- Branch: `docs/0010-t3-deploy-automation`
- Do: evaluate a deploy-per-environment automation; add it to automations.md or record the deferral
- Files: ~ references/automations.md (maybe + templates/)
- Done when: AC-3

### T-4 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0010-t4-release`
- Do: minor bump, docs, changelogs; PR body with `Closes-Spec: SPEC-0010`
- Files: ~ plugin.json, ~ READMEs, ~ CHANGELOGs
- Done when: bot closes spec and plan; plugin update

## Verification

Read-through against the spec; headless kickoff test shows the environments question with the default.

## Risks

Platform-specific details go stale → link official docs instead of copying them.

## Out of scope

Full deploy pipelines for every platform.
