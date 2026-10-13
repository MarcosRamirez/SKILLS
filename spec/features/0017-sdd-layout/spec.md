# SPEC-0017: SDD layout under spec/ with a constitution, colocated plans and separate code

Status: Approved
Date: 2026-10-13
Approved by: the user, 2026-10-13, approving the plan in conversation (from a photo of an SDD layout).

## Problem

Projects have no written mission and no roadmap: the list of pending plans has lived in the chat.
A feature is spread across `docs/specs/` and `docs/plans/`, and its `design.md` and plan both
describe the "how". Small changes need four files. Code and documentation share the root.

## Requirements

- R-1 Root `spec/` with `constitution/` (`mission.md`, `tech-stack.md`, `roadmap.md`; a single
  `spec/constitution.md` allowed in small projects), `features/`, `adr/`, `api/`, `INVENTORY.md`.
- R-2 A feature is a folder `spec/features/NNNN-<slug>/` with `spec.md`, `plan.<tier>.md` and
  `tasks.md`. `design.md` is merged into the plan's `## Design` section.
- R-3 A small feature can be a single file `spec/features/NNNN-<slug>.md` with `## Spec`, `## Plan`, `## Tasks`.
- R-4 The mission is asked of and approved by the user. tech-stack is derived from the ADRs.
  The roadmap lists features in order with tier, state and dependencies, and the bot updates the state.
- R-5 Code lives in its own folder (`app/` in new projects; existing projects keep theirs, recorded in CLAUDE.md).
- R-6 Projects on the old layout (`docs/specs`, `docs/plans`) get a migration proposal through a
  change notice, on a branch, keeping history.
- R-7 `close-specs.sh` handles folders and single files, plans inside the folder (with or without
  tier) and roadmap rows, validating before writing.
- R-8 This repository migrates to the new layout.

## Acceptance criteria

- AC-1 References and `SKILL.md` describe the new layout; no `docs/specs`, `docs/plans` or `design.md` left except in the migration notes.
- AC-2 `references/constitution.md` with the mission template and questions, the tech-stack derivation rule and the roadmap format.
- AC-3 close-specs tests pass: folder, single file, legacy `plan.md`, roadmap row, idempotency, missing feature, duplicate plan, folder + file collision, injection, no roadmap.
- AC-4 This repo uses `spec/`; `git log --follow` keeps history of moved specs; no broken relative links.
- AC-5 Merging the 2.0.0 release makes the bot close SPEC-0017 at its new path, set its plan Done and its roadmap row Implemented.

## Out of scope

- Migrating the user's other projects (that is onboarding, SPEC-0009).
