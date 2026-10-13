# PLAN-0022: spec types: features and fixes

Spec: [SPEC-0022](spec.md)
Status: Done
Done: 2026-10-13, PR #44
Recommended overall: medium — Claude Sonnet 5.5 (template and wording, plus a small change to the bot script)

## Context

The SDD layout comes from SPEC-0017; the bot from SPEC-0005. The fix template follows Kiro's bugfix
specs (kiro.dev/docs/specs/bugfix-specs): re-read it before writing the template. The first fix spec
is already waiting: SPEC-0023, in `spec/fixes/`.

## Design

- **Layout:** `spec/fixes/` next to `spec/features/`, same naming (`NNNN-slug.md`, or a folder with
  `spec.md`, `plan.<tier>.md` and `tasks.md`) and one shared SPEC-NNNN sequence.
- **Header:** `Type: feature|fix` under the title, in both templates.
- **Fix template sections:** Current behaviour · Expected behaviour · Unchanged behaviour ·
  Reproduction · Root cause · Fix · Acceptance criteria (the three fixed ones plus any others), then
  the Plan and Tasks sections as in single-file features.
- **close-specs.sh:** `SPEC_DIRS` defaults to `spec/features spec/fixes`; when `FEATURES_DIR` is set it
  is the only directory, so existing callers keep working. Look in every directory and keep exactly
  one match; validate before writing, as today.
- **Workflow:** in this repository's `on-merge.yml`, the id extraction becomes
  `grep -oE '(features|fixes)/[0-9]{4}-'`. The template workflow already commits with a generic message.

## Steps

### T-1 References and SKILL.md — medium
- Recommended: medium — Claude Sonnet 5.5 (templates and wording)
- Branch: `feat/0022-t1-fix-specs`
- Do:
  - `project-layout.md`: tree and naming for `spec/fixes/`;
  - `sdd.md`: both types, the fix template and when a fix needs a spec;
  - `plans.md`: plans for fixes;
  - `git.md`: `fix/NNNN-slug` branches;
  - Step 3 of `SKILL.md`: choose the type;
  - README trees (skill and root) and the CLAUDE.md structure.
- Files: ~ references/project-layout.md, ~ references/sdd.md, ~ references/plans.md, ~ references/git.md, ~ SKILL.md, ~ READMEs, ~ CLAUDE.md
- Done when: AC-1

### T-2 Bot, workflow and tests — medium
- Recommended: medium — Claude Sonnet 5.5 (small script change with tests)
- Branch: `feat/0022-t2-close-fixes`
- Do: `SPEC_DIRS` in close-specs.sh; id extraction in the repo workflow; `release-automation.md`;
  tests in a scratch repository
- Files: ~ templates/release-automation/close-specs.sh, ~ .github/workflows/on-merge.yml, ~ references/release-automation.md
- Done when: AC-2, AC-3

### T-3 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0022-t3-release`
- Do: minor bump, changelogs; PR body with `Closes-Spec: SPEC-0022`
- Done when: AC-4; the bot closes the spec, the plan and the roadmap row

## Verification

The close-specs tests (AC-2); `grep` the workflow extraction against sample paths (AC-3);
`claude plugin validate --strict`.

## Risks

- A number used in both folders → close-specs.sh refuses it and changes nothing.
- Existing projects only have `spec/features/` → a missing `spec/fixes/` is not an error.

## Out of scope

A third folder for refactors or upgrades.
