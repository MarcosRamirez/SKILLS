# SPEC-0018: ask where the code goes

Status: Approved
Date: 2026-10-13
Approved by: the user, 2026-10-13, "src/ recomendada" (choosing the option approved this feature)
Plan: low — Claude Haiku 5.5 (one kickoff question and wording in the references)

## Spec

**Problem.** 2.0.0 put the code of every new project in `app/`. Most frameworks expect a `src/`
layout with manifests at the root, and monorepos need one folder per deployable. Where the code
goes is the user's call.

**Requirements**
- R-1 The kickoff asks where the code goes, with the question tool:
  - `src/` (Recommended for a single app): manifests and configs at the root, code in `src/`, tests in `tests/`;
  - `app/`: the whole project inside `app/`, so the root keeps only `spec/`, `CLAUDE.md` and repo files;
  - `apps/<name>/`: one folder per deployable, with a workspace tool;
  - or any other folder the user types in the free-text field (e.g. `backend/`, `packages/core/`),
    validated before use: a relative path inside the repo, no `..`, not absolute, not `spec/`,
    `.github/` or `.git/`, only letters, digits, `-`, `_`, `.` and `/`. If invalid, explain why and ask again.
- R-2 The answer is recorded in CLAUDE.md (`Code: <folder>`); layout, CI (`working-directory`) and paths follow it.
- R-3 Existing projects are not asked: their current code folder is recorded.

**Acceptance criteria**
- AC-1 `SKILL.md` kickoff has the question, and the kickoff checklist refers to it.
- AC-2 `project-layout.md` describes the four options; no reference presents `app/` as the only choice.
- AC-3 Merging the release closes this single-file feature through the bot, the first real close of a single-file feature.

**Out of scope.** Moving code in existing projects.

## Plan

### Design
- Question 12 of the kickoff interview, with options `src/` (Recommended) · `app/` · `apps/<name>/`, plus the free-text field for any other folder.
- Hexagonal layers, when there is a domain, live in the language's source folder: `src/domain/…`
  with the `src/` option, `app/src/domain/…` with `app/`.
- CI runs from the code folder when it is not the root (`working-directory: app` or a matrix over `apps/*`).

### Steps
- T-1 Kickoff question, checklist item, `project-layout.md`, `sdd.md` example path, skill README tree — low — Claude Haiku 5.5. Branch `feat/0018-code-folder-choice`.
- T-2 Release 2.1.0 (minor: a new kickoff question), changelogs, PR body with `Closes-Spec: SPEC-0018` — low.

### Verification
`grep` shows no `app/` presented as the only option; `claude plugin validate --strict`; after merge, the bot marks this file Implemented and its roadmap row.

## Tasks
- [x] T-1 Kickoff question + references + README (AC-1, AC-2)
- [x] T-2 Release 2.1.0 with `Closes-Spec: SPEC-0018` (AC-3)
