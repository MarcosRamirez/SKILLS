# PLAN-0017: SDD layout under spec/

Spec: [SPEC-0017](spec.md)
Status: Done
Done: 2026-10-13, PR #34
Recommended overall: high — Claude Opus 5.5 (structural change plus a migration that must keep history and links)

## Context

Adopted from a photo of a spec-kit style layout: constitution, features with spec/plan/tasks,
single-file small features, root `spec/`, separate code. ADRs and INVENTORY stay. Breaking for
projects on 1.x layout → 2.0.0.

## Design

- **Tree:**

  ```text
  spec/
    constitution/  mission.md · tech-stack.md · roadmap.md
    features/      NNNN-slug/{spec.md, plan.<tier>.md, tasks.md} | NNNN-slug.md
    adr/ · api/ · INVENTORY.md
  app/             code (new projects)
  ```
- **Plan structure:** Context · Design (formerly design.md) · Steps · Verification · Risks · Out of scope.
- **Roadmap row:** `| SPEC-NNNN | title | tier | status | depends on |`; the bot sets column 4 to Implemented.
- **tech-stack.md:** a readable summary with a link per ADR; regenerated whenever an ADR is added
  or superseded. Never edited by hand.
- **Mission:** asked at kickoff (what, for whom, why now, what it is not), approved by the user.
- **close-specs.sh:** locate one feature (folder or file, exactly one), at most one plan; validate
  everything; then write spec, plan and roadmap.
- **Legacy detection:** `docs/specs` or `docs/plans` present → migration proposal (change notice), branch, `git mv`.

## Steps

### T-1 Skill: references, SKILL.md, close-specs.sh — high
- Recommended: high — Claude Opus 5.5 (layout contract and automation)
- Branch: `feat/0017-t1-layout`
- Do: rewrite project-layout and sdd; update plans, release-automation, adr and the path references; rewrite close-specs.sh; update workflows; tests
- Files: ~ references/*, ~ SKILL.md, ~ README, ~ close-specs.sh, ~ on-merge.yml (both)
- Done when: AC-1 (partial), AC-3

### T-2 Constitution and legacy detection — medium
- Recommended: medium — Claude Sonnet 5.5 (settled design)
- Branch: `feat/0017-t2-constitution`
- Do: references/constitution.md; kickoff creates the constitution; roadmap updated on new features; legacy-layout detection in Step 1; code-folder rule
- Files: + references/constitution.md, ~ SKILL.md
- Done when: AC-1, AC-2

### T-3 Migrate this repository — high
- Recommended: high — Claude Opus 5.5 (history-preserving moves and link fixing)
- Branch: `chore/0017-t3-migrate-repo`
- Do: git mv specs and plans; merge design.md into plans; adr and INVENTORY to spec/; constitution for this repo (mission approved by the user); fix CLAUDE.md, READMEs and links
- Files: docs/** → spec/**
- Done when: AC-4

### T-4 Release 2.0.0 — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0017-t4-release-2-0-0`
- Do: major bump, changelogs; PR body with `Closes-Spec: SPEC-0017`
- Files: ~ plugin.json, ~ SKILL.md frontmatter, ~ CHANGELOGs
- Done when: AC-5

## Verification

close-specs tests in a scratch repo (AC-3); `git log --follow` on a moved spec; relative link check over spec/, READMEs and CLAUDE.md; post-merge bot run.

## Risks

- Broken links after moves → scripted link check before each commit.
- The workflow still pointing at old paths at merge time → the template default changes in T-1, and the repo moves in T-3 before the release PR.

## Out of scope

Migrating other projects (SPEC-0009).
