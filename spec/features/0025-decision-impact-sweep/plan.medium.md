# PLAN-0025: propagate every decision to what it touches

Spec: [SPEC-0025](spec.md)
Status: Ready
Recommended overall: medium — Claude Sonnet 5.5 (a procedure and a template; one judgment-heavy headless test)

## Context

SPEC-0024 fixes the drift in this repository and ships `check-docs.py`. This spec turns the lesson
into behaviour for every project: decisions carry their impact, and the sweep keeps documents in step.
It relates to SPEC-0008 (change notice for migrations) and SPEC-0026 (a bug caused by drift gets a
postmortem in the "docs drift" category).

## Design

- **ADR template** (`references/adr.md`), with a new section after Consequences:

  ```markdown
  ## Impact
  Replaces terms: `old` → `new`, …
  | Document | Action |
  |---|---|
  | README.md (install) | updated in this PR |
  | spec/features/0012-…/spec.md | updated in this PR (Changelog line) |
  | skill behaviour | follow-up: SPEC-NNNN |
  Existing projects/data: none | migration proposed via change notice (SPEC-0008)
  ```
- **Sweep commands** (documented, portable): `git grep -n "<ADR id>\|<file name>\|<old term>"`
  over the living documents and the specs; review each hit; the Impact table is the record.
- **Living documents** are the same set as in SPEC-0024. Specs are reviewed by the sweep, but not
  by the check.
- **Automation template:** `templates/docs-check/check-docs.py` (copied from this repository's
  `.github/scripts/`, with no repository-specific paths) plus a workflow snippet. The automations
  question lists it as recommended when the project has docs.

## Steps

### T-1 ADR template, sweep and rule — medium
- Recommended: medium — Claude Sonnet 5.5 (procedure writing)
- Branch: `feat/0025-t1-impact-sweep`
- Do: the `## Impact` section and the sweep procedure in `references/adr.md`; the rule in `SKILL.md` (ADR
  rules and Step 3, when a spec changes a convention); the `CLAUDE.md` sweep rule in this repository (R-5)
- Files: ~ references/adr.md, ~ SKILL.md, ~ README.md, ~ CLAUDE.md
- Done when: AC-1, AC-2, AC-5

### T-2 docs-check automation — medium
- Recommended: medium — Claude Sonnet 5.5 (template from an existing script)
- Branch: `feat/0025-t2-docs-check-automation`
- Do: `templates/docs-check/` (script and CI step) generalised from SPEC-0024's script; a `docs-check` entry in
  `references/automations.md`; test it in a scratch project
- Files: + templates/docs-check/, ~ references/automations.md, ~ spec/INVENTORY.md
- Done when: AC-4

### T-3 Headless sweep test — high
- Recommended: high — Claude Opus 5.5 (judging whether the agent swept correctly)
- Branch: `test/0025-t3-sweep-test`
- Do: the AC-3 scenario with `--plugin-dir`; check the diff covers the README, the conventions, the Impact
  section and the Draft follow-ups; fix the wording if needed
- Done when: AC-3

### T-4 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0025-t4-release`
- Do: minor bump, changelogs; PR body with `Closes-Spec: SPEC-0025`
- Done when: the bot closes the spec, the plan and the roadmap row

## Verification

The headless test, the automation in a scratch project, and `claude plugin validate --strict`.

## Risks

- The sweep becomes busywork on trivial ADRs → the Impact table may say "none" with a one-line reason.
- Replaced terms that are still valid elsewhere (`.claude/skills` as the Claude Code bridge) → the
  sweep reviews each hit; the check only enforces links.

## Out of scope

Automatic migrations; rewriting history.
