# SPEC-0008: work safely on existing projects (code or documentation)

Status: Implemented
Implemented: 2026-10-19, PR #89
Date: 2026-10-13
Approved by: the user, 2026-10-13, "implementa todas las fases, una a una, con subagentes"

## Problem

senior-mindset assumes a fresh project. On an existing one, with code or only documentation,
it could restructure, overwrite or mix changes without warning, and the user would find out in
the diff.

## Requirements

- R-1 An existing project is a repo with code **or** documentation (specs, ADRs, notes).
- R-2 Before modifying anything existing, the AI shows a **change notice** and waits for an
  explicit OK: what changes and why, files created/modified/moved/deleted, risks, how to roll back.
- R-3 The work happens on a new branch and is delivered by PR. Small changes get a small notice.
- R-4 Existing conventions (naming, structure, libraries, configs) win over skill defaults;
  deviations are noted, not imposed.
- R-5 No drive-by refactors: improvements seen on the way are proposed separately.
- R-6 Edge cases are handled explicitly (see design).

## Acceptance criteria

- AC-1 Hard rule in `SKILL.md` and `references/existing-projects.md` with the notice template and the edge-case table.
- AC-2 Headless test, code repo + "add validation to the form" → notice listing files, no edits.
- AC-3 Headless test, docs-only repo with its own pattern + "organise the specs" → notice, no edits.
- AC-4 Headless test, uncommitted user changes → asks, does not touch or mix them.
- AC-5 Headless test, folder without git → proposes `git init` + initial commit before changing anything.
- AC-6 Existing CLAUDE.md / AGENTS.md / .cursorrules are read and merged, never overwritten.

## Out of scope

- Normalising a project to the standard layout (SPEC-0009).
