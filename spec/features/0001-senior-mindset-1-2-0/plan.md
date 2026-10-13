# SPEC-0001 design

## Overview

All changes are Markdown inside `skills/senior-mindset/` plus a version bump. There is no runtime, so the
"tests" are: a git-cliff run on a scratch repo (AC-2), plugin validation, link checks,
and the GitHub update check (AC-12).

## Decisions

- **Reuse git-cliff for versioning.** It is already the changelog tool (ADR-0002), and a
  scratch-repo test showed it increments pre-releases (`alpha.1 → alpha.2`). No new tool.
- **0.x bump policy:** `features_always_bump_minor = false`, `breaking_always_bump_major = false`.
  In 0.x a feature bumps PATCH and a breaking change bumps MINOR; from 1.0.0, standard SemVer.
- **Stage changes are the user's call.** git-cliff never leaves a stage by itself; the AI
  proposes, and the user approves `--tag v0.1.0-beta.1` or similar.
- **Approval gate (F1):** no implementation without explicit approval. Without a way to ask
  (headless, no AskUserQuestion), stop after writing the Draft spec and Proposed ADRs and
  list the open questions.
- **Kickoff N/A (F7):** each interview item may be answered "N/A + reason", recorded in CLAUDE.md.

## Components

- New: `references/versioning.md`.
- Changed: `SKILL.md` (description, Steps 0b, 2, 3, 4, 5, new Step 7), `references/git.md`,
  `references/changelog.md` (release section → link), `references/observability.md`
  (`version` field), `references/project-layout.md`, `references/stack.md`, `references/sdd.md`.
- Docs: skill `README.md`, root `README.md`, `docs/INVENTORY.md`, `CHANGELOG.md`.

## Risks

- A longer `SKILL.md` costs context on every load → keep additions short and put detail in references.
- A broader trigger (F6) loads the skill more often → Step 0 sends scripts down a cheap path.
