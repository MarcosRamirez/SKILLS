# SPEC-0022: spec types: features and fixes

Type: feature
Status: Implemented
Implemented: 2026-10-13, PR #44
Date: 2026-10-13
Approved by: the user, 2026-10-13, "implementa todas las fases, una a una, con subagentes"

## Problem

The SDD layout has one place for specs, `spec/features/`. A bug is not a feature: what matters is
the behaviour that is wrong, the behaviour that must stay as it is, the root cause and a test that
reproduces it. Today a fix either gets no spec at all or is forced into the feature template.

How other spec-driven tools handle it (checked 2026-10-13):

- [Kiro](https://kiro.dev/docs/specs/bugfix-specs/) has a **bugfix** spec type: `bugfix.md` records
  the current, expected and unchanged behaviour ("WHEN … THEN the system SHALL CONTINUE TO …" as a
  regression guard), then a design with the root cause and tests that reproduce the bug, prove the
  fix and prevent regressions.
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) keeps every kind of change in one `changes/` folder.
- spec-kit only has features.

The user chose two types with two folders: features and fixes.

## Requirements

- R-1 **Two spec types, one numbering.** The SPEC-NNNN sequence is shared, so the roadmap,
  `Closes-Spec:` and the bot keep working unchanged:
  - `spec/features/`: new or changed behaviour. Refactors and upgrades also go here, with
    acceptance criteria stating that behaviour does not change;
  - `spec/fixes/`: behaviour that is wrong.

  Every spec header carries `Type: feature` or `Type: fix`.
- R-2 **Fix template.** One file by default, `spec/fixes/NNNN-slug.md`, with Spec / Plan / Tasks
  sections; a folder only when the fix is large. The Spec section has:
  - current behaviour: "WHEN … THEN the system …";
  - expected behaviour: "WHEN … THEN the system SHALL …";
  - unchanged behaviour: "WHEN … THEN the system SHALL CONTINUE TO …", the regression guard;
  - reproduction: steps, or the failing test;
  - root cause, filled in after the analysis;
  - the fix.

  Its acceptance criteria always include:
  - a test that reproduces the bug fails before the fix;
  - the same test passes after the fix;
  - the unchanged-behaviour tests stay green.
- R-3 **When a fix needs a spec.** It needs one when:
  - the root cause is unknown;
  - several modules are involved;
  - behaviour changes beyond the bug itself;
  - there is data loss or a security impact.

  A trivial fix gets no spec: a regression test and a `fix:` commit are enough. For a vulnerability,
  the details stay private until the fix is released.
- R-4 **Fix flow.** First reproduce the bug with a failing test, then find the root cause, then fix
  it. Branch `fix/NNNN-slug`, commit `🐛 fix(<scope>): …`, PATCH bump when it is released.
- R-5 **The bot closes both folders:**
  - `close-specs.sh` looks in `SPEC_DIRS` (default `spec/features spec/fixes`; `FEATURES_DIR` still
    works as before) and requires exactly one match across them;
  - this repository's `on-merge.yml` extracts the ids from `(features|fixes)/`;
  - fixes get roadmap rows like features.

## Acceptance criteria

- AC-1 `references/project-layout.md` and `references/sdd.md` describe both types with their
  templates, and Step 3 of `SKILL.md` chooses the type.
- AC-2 `close-specs.sh` passes these tests in a scratch repository:
  - it closes a single-file fix;
  - it closes a fix in a folder;
  - the existing feature cases still pass;
  - the same number in both folders fails without changing anything.
- AC-3 The workflow extracts the ids of specs in `spec/fixes/`.
- AC-4 Minor release; its PR carries `Closes-Spec: SPEC-0022`.

## Out of scope

- A third folder for refactors, performance or upgrades: they are features (R-1).
- Moving existing specs.
