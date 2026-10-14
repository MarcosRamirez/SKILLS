# PLAN-0026: a postmortem for every bug, and a register of lessons

Spec: [SPEC-0026](spec.md)
Status: Ready
Recommended overall: medium — Claude Sonnet 5.5 (method and templates are settled; the backfill needs judgment)

## Context

The fix template comes from SPEC-0022. This plan extends it with a postmortem and adds the register.
The backfill of past bugs reads the git history, the fix commits and the specs, so it is the step
that needs the most judgment.

## Design

- **Postmortem section** (inside the fix spec, after `## Spec`):

  ```markdown
  ## Postmortem
  **Impact.** …
  **5 Whys.** 1. Why … → because … 2. Why … → because … (stop at a cause you can act on)
  **Why it was not caught.** …
  **Corrective action.** … (the fix, this spec)
  **Preventive actions.**
  - [x] … (where: test / check / rule)
  - [ ] … (SPEC-NNNN)
  ```
- **Register** `spec/POSTMORTEMS.md`:
  - a short header explaining how to use it (read before specs, reviews and releases; three in a
    category → a pattern spec);
  - a table `| Id | Date | What happened | Category | Root cause | Why not caught | Prevention (status) | Link |`;
  - below the table, a short "Patterns" list that counts rows per category.
- **Categories:** spec gap · docs drift · process gap · code defect · tooling · environment. They
  are few on purpose, so patterns show.
- **Skill wiring:** the fix flow in `SKILL.md` gains "postmortem + register row" as its last step.
  Step 1 (load context) and the release step read the register, like `spec/INVENTORY.md`.

## Steps

### T-1 Method and templates — medium
- Recommended: medium — Claude Sonnet 5.5 (writing from a settled design)
- Branch: `feat/0026-t1-postmortem-method`
- Do: `references/postmortem.md` (method with the five sources, templates, categories, pattern rule); the
  `## Postmortem` section in the fix template of `references/sdd.md`; the rule in `SKILL.md` (fix flow, Step 1
  and the release step read the register); `references/project-layout.md` lists `spec/POSTMORTEMS.md`;
  skill README; INVENTORY
- Files: + references/postmortem.md, ~ references/sdd.md, ~ references/project-layout.md, ~ SKILL.md, ~ README.md, ~ spec/INVENTORY.md
- Done when: AC-1, AC-4

### T-2 This repository's register and the backfill — high
- Recommended: high — Claude Opus 5.5 (root causes from history need judgment)
- Branch: `docs/0026-t2-postmortem-register`
- Do: create `spec/POSTMORTEMS.md`. Write one row per bug of R-5, from the fix commits, the specs and the PRs.
  Add a `## Postmortem` section to the fix specs that already exist (SPEC-0023). List the preventive
  actions that are still pending, each with a proposed spec, but do not write those specs here.
- Files: + spec/POSTMORTEMS.md, ~ spec/fixes/0023-*.md, ~ CLAUDE.md (structure), ~ spec/INVENTORY.md
- Done when: AC-2

### T-3 Headless test — medium
- Recommended: medium — Claude Sonnet 5.5 (scripted run and checks)
- Branch: `test/0026-t3-postmortem-test`
- Do: in a scratch project with a small bug, run the fix flow headless with `--plugin-dir`; check the
  postmortem section and the register row
- Done when: AC-3

### T-4 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0026-t4-release`
- Do: minor bump, changelogs; PR body with `Closes-Spec: SPEC-0026`
- Done when: the bot closes the spec, the plan and the roadmap row

## Verification

The headless test (AC-3); every row of the register has a link that resolves; `claude plugin validate --strict`.

## Risks

- Postmortems that only paraphrase the fix → the template asks why it was not caught and for a
  preventive action with a status.
- Blame creeping in → the method and the template say "the system, not the person".

## Out of scope

Incident response and issue tracking.
