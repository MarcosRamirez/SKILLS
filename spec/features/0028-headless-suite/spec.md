# SPEC-0028: a committed headless suite, run before every release

Type: feature
Status: Approved
Date: 2026-10-14
Approved by: the user, 2026-10-14, chose it in the postmortem-patterns question ("Batería de pruebas sin interfaz")

## Problem

The skill's behaviour is prose: approval gates, the kickoff checklist, the branch flow, questions,
postmortems, the impact sweep. Prose can be skipped, and only a headless run of the real skill shows
it. Those runs have been manual and one-off, written per task in scratch folders and never repeated
before a release. Three postmortems share this cause, the "process gap" pattern: PM-0002, PM-0003
and PM-0006. The 1.2.0 approval gate shipped untested and failed in 1.3.0. Two more rows come from
missing trigger tests (PM-0004, PM-0011), and one from test runs that wrote to the user's real home
(PM-0012, "environment").

## Requirements

- R-1 **Committed scenarios** under `tests/headless/`, each a scratch project built by a script.
  Each runs `claude -p` with `--plugin-dir ./skills/senior-mindset` and makes deterministic checks on
  the files, the git history and the stream:
  - approval gate: a "build me X" prompt, with no answer to the questions, produces Draft documents
    on a `docs/` branch and no code (PM-0002, PM-0006);
  - kickoff checklist and branch flow: a new project gets its checklist items, a branch, and no
    commit on master (PM-0003);
  - script fast path: a script request loads the skill and gives English names (PM-0004);
  - trigger prompts: a merge-only request in English and Spanish; the rules apply and nothing is
    merged (PM-0011, SPEC-0027);
  - closed question: the question tool is called with well-formed options, or the numbered fallback
    is used (SPEC-0016);
  - fix flow: the postmortem and the register row (SPEC-0026);
  - impact sweep: superseding an ADR updates the living documents and records the follow-ups (SPEC-0025).
- R-2 **One runner**, `tests/headless/run.sh` (or a Python equivalent):
  - it runs all scenarios or a named one, and prints pass/fail per check with the evidence;
  - it exits non-zero on any failure;
  - it keeps the raw streams in a temp folder that is never committed.
- R-3 **The user's machine is never changed.**
  - Runs write only inside their scratch project, for example by running in `acceptEdits` mode,
    which blocks edits outside the project.
  - The runner hashes the user's `~/.claude/senior-mindset.md` (and the other user-level files the
    skill writes) before and after, and fails if any of them changed (PM-0012).
  - Plan T-1 checks whether an isolated HOME keeps the login working. If it does, the runner uses it.
- R-4 **Run before every release.**
  - The release step in this repository's `CLAUDE.md` runs the suite and pastes the summary into the
    release PR.
  - A failure blocks the release until it is fixed or the user accepts it explicitly.
  - It is not run on every pull request, because each run costs model usage. A manual GitHub Actions
    workflow, using an API key secret, is optional.
- R-5 **Several runs where the model varies.** A trigger or question scenario runs N times (default
  3) and passes only if every run passes. N is shown in the summary.

## Acceptance criteria

- AC-1 `tests/headless/` with the runner and every scenario of R-1. Each check is a deterministic
  assertion, not a model's judgment.
- AC-2 A full run on the current skill: the summary is recorded, and any failure becomes a fix spec
  (or a register row).
- AC-3 A deliberately broken copy of the skill (for example, the approval hard rules removed) makes
  the gate scenario fail.
- AC-4 The user-file hashes are unchanged after a full run, and the runner proves it.
- AC-5 `CLAUDE.md` and the release PR template include the suite run.

## Out of scope

- Judging prose quality with a model.
- Running on every pull request.
