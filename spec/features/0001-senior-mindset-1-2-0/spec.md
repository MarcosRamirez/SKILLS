# SPEC-0001: senior-mindset 1.2.0 — app versioning, branch per change, test findings

Status: Implemented
Date: 2026-10-12
Approved by: the user, in conversation (plan approved; findings list approved with
"apply the corrections automatically").

## Problem

1. Apps built with senior-mindset get a changelog but no product versioning: no defined
   stages (alpha, beta, rc), no rule for the next number, no release process.
2. The skill does not forbid working directly on the default branch.
3. A headless test of 1.1.0 in an empty folder and on a script showed the skill
   misbehaving (findings F1–F7 below).

## Requirements

- R-1 Apps start at `0.0.1-alpha.1` and progress through alpha → beta → rc → stable with SemVer 2.0.
- R-2 The next version is computed deterministically from commits (git-cliff), not by the AI.
- R-3 A release process the AI runs on request ("release the beta").
- R-4 Never commit on the default branch; one branch per change.
- R-5 Fix test findings:
  - F1 Implemented without approval when it could not ask the user.
  - F2 Wrote `spec.md` only, no `design.md` / `tasks.md`.
  - F3 Kickoff skipped `CHANGELOG.md` and `cliff.toml`.
  - F4 One giant commit with the whole app, directly on `master`.
  - F5 Initial version `0.1.0` (covered by R-1).
  - F6 Skill not loaded for a script → Spanish identifiers.
  - F7 Kickoff interview assumes an app; no guidance when items do not apply.

## Acceptance criteria

- AC-1 `references/versioning.md` exists with scheme, initial version, stages with exit criteria, bump rules, release steps, long-term maintenance and a tested `[bump]` config.
- AC-2 The `[bump]` config, run on a test repo, yields `0.0.1-alpha.1` with no tags, `alpha.2` after `alpha.1`, `beta.2` after `beta.1`, MINOR on breaking in 0.x, and MAJOR on breaking in 1.x.
- AC-3 `SKILL.md` asks for the versioning scheme at kickoff, sets `0.0.1-alpha.1`, and has a Release step.
- AC-4 `SKILL.md` and `git.md` forbid commits on the default branch and define branch naming per feature/task.
- AC-5 F1: `SKILL.md` has a hard approval gate, and states what to do when the user cannot be asked.
- AC-6 F2: `design.md` and `tasks.md` are mandatory, and `tasks.md` drives branches and commits.
- AC-7 F3: kickoff ends with a verified checklist of artifacts before the first feature.
- AC-8 F4: a kickoff commit, then one commit per task, never one commit for the whole feature.
- AC-9 F6: the skill description triggers on any code-writing task, scripts included.
- AC-10 F7: kickoff items that do not apply are skipped, with an "N/A + reason" note in CLAUDE.md.
- AC-11 Version 1.2.0 in `plugin.json` and frontmatter; READMEs, inventory and changelog updated.
- AC-12 After push, `claude plugin update` moves the GitHub install from 1.1.0 to 1.2.0 and the cache contains `references/versioning.md`.

## Out of scope

- Automating releases in CI.
- Changes to save-image.
- Removing `src/hooks/save-image-hook.py` (done separately, with its own OK).
