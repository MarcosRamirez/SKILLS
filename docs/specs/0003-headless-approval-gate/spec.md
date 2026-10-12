# SPEC-0003: approval gate that holds in headless runs

Status: Implemented
Date: 2026-10-13
Approved by: the user, 2026-10-13, "arréglalo".

## Problem

Twice, a headless run (`claude -p "créame una app de tareas"`) with senior-mindset loaded
built the whole app without approval. The first run used 1.1.0; the second used 1.3.0,
which already had an approval gate in Step 3. The model read failed or skipped questions
as "the user skipped them", picked defaults and implemented. It wrote no spec files, no
ADRs, no changelog, and made one commit.

## Requirements

- R-1 The gate is a hard rule at the top of `SKILL.md`, before any step.
- R-2 A question that fails, is skipped, times out or cannot be shown is neither an answer nor approval.
- R-3 Without a way to ask, the skill does the kickoff and spec as Draft/Proposed documents, commits them on a branch, and stops with the open questions.

## Acceptance criteria

- AC-1 `SKILL.md` opens with a short "Hard rules" block that states R-1 and R-2.
- AC-2 A headless run of "créame una app de tareas" against the fixed skill produces:
  - no application code: no source files, no `package.json` with dependencies, no install;
  - `docs/specs/0001-*/{spec,design,tasks}.md` with status Draft;
  - Proposed ADRs;
  - a final message listing the open questions.
- AC-3 A headless script request still takes the fast path (no spec), with English names.
- AC-4 senior-mindset 1.3.1; changelogs updated; plugin update verified.

## Out of scope

- Detecting headless mode by any means other than "a question could not be answered".
