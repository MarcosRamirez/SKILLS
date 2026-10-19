# PLAN-0011: curated catalog of skills and MCPs, and skill management

Spec: [SPEC-0011](spec.md)
Status: In progress
Recommended overall: high — Claude Opus 5.5 (inclusion criteria and curation are judgment calls)

## Context

Lists live inside the skill (`catalog/skills.json`, `catalog/mcps.json`), maintained by the user, shipped with every install and update. The spec's open question (how installed skills are declared per project) was decided with the user on 2026-10-13: project scope by default, standard locations first: `.agents/skills/` through `npx skills`, with a `.claude/skills/` copy for Claude Code (R-8, ADR-0005).

## Design

### Entry shape (draft)

```json
{
  "id": "web-design",
  "name": "Web design",
  "purpose": "Layout, typography and accessible UI for web pages",
  "recommended": false,
  "proposeWhen": { "tasks": ["landing page", "ui", "web design"], "stack": ["astro", "next"] },
  "source": { "marketplace": "marcosramirez-skills", "plugin": "web-design", "upstream": "<repo>" },
  "install": "npx skills add MarcosRamirez/SKILLS --skill web-design",
  "permissions": "none",
  "version": "1.2.0",
  "why": "…",
  "added": "2026-10-13"
}
```

- `install` carries no scope flags: the skill adds `--copy` for a project install, or `-g` when the user picks Global (R-8).
- Validation script in Python (stdlib + a minimal schema check) so it runs in CI and locally.
- Proposal logic lives in `references/catalog.md`: match task words and stack signals, propose at most three.

## Steps

### T-0 Decide the open question — high (done 2026-10-13)
- Recommended: high — Claude Opus 5.5 (design decision with the user)
- Branch: `—`
- Do: discuss options with the user; record the decision in the spec (Changelog) and an ADR
- Files: ~ spec/features/0011-*/spec.md, + spec/adr/
- Done when: open question closed

### T-1 Criteria, schema, validation — high
- Recommended: high — Claude Opus 5.5 (defines what 'curated' means)
- Branch: `feat/0011-t1-catalog-criteria`
- Do: references/catalog.md criteria; JSON Schema for both lists; Python validator; CI step in on-merge or a PR check
- Files: + references/catalog.md, + catalog/*.schema.json, + validator script, ~ workflow
- Done when: AC-1, AC-2 (a malformed entry fails locally)

### T-2 Build the initial lists with the user — high
- Recommended: high — Claude Opus 5.5 (each entry is reviewed)
- Branch: `feat/0011-t2-initial-catalog`
- Do:
  1. ask the user for the skills and MCPs they already use or want in the catalog;
  2. research candidates per task type and stack (official docs, maintenance, licence, permissions)
     and propose them in short batches, each with why and how it meets the criteria;
  3. the user approves, rejects or edits each entry; only approved entries are written;
  4. record rejected candidates with the reason, so they are not proposed again
- Files: + catalog/skills.json, + catalog/mcps.json
- Done when: AC-1, AC-1b — every entry in both lists was explicitly approved by the user

### T-3 Third-party skills installable with npx skills — medium
- Recommended: medium — Claude Sonnet 5.5 (install checks after vetting)
- Branch: `feat/0011-t3-third-party-skills`
- Do: check each vetted skill installs with `npx skills add` from a pinned source; optionally list it in marketplace.json for `/plugin` users; validate
- Files: ~ .claude-plugin/marketplace.json
- Done when: AC-4

### T-4 Skill management flow — medium
- Recommended: medium — Claude Sonnet 5.5 (wiring + headless test)
- Branch: `feat/0011-t4-skill-management`
- Do: propose (max three) → install on consent → record → update → propose removal; collision check for new skills
- Files: ~ SKILL.md
- Done when: AC-3

### T-5 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0011-t5-release`
- Do: minor bump, docs, changelogs; PR body with `Closes-Spec: SPEC-0011`
- Files: ~ plugin.json, ~ READMEs, ~ CHANGELOGs
- Done when: bot closes spec and plan; plugin update

## Verification

Validator rejects a malformed entry; headless 'design a landing page' proposes without installing; `npx skills add` of a vetted entry works.

## Risks

Third-party skill changes upstream → pinned versions, periodic review. Catalog bloat → criteria and a cap per category.

## Out of scope

MCP installation flow (PLAN-0012).
