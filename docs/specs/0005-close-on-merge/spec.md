# SPEC-0005: specs become Implemented on merge, releases tag themselves

Status: Approved
Date: 2026-10-13
Approved by: the user, 2026-10-13, approving the plan in conversation.

## Problem

Every release needed a follow-up PR only to mark its spec Implemented (#11, #15), plus a
manual tag on the merge commit. The spec cannot be marked Implemented inside the PR (that
claims something that has not happened yet), and marking it afterwards by hand costs a PR.

## Requirements

- R-1 When a PR whose body contains `Closes-Spec: SPEC-NNNN` is merged, that spec becomes
  Implemented automatically, with the date and the PR number.
- R-2 When a merge bumps a skill version, the tag `<name>-vX.Y.Z` and its GitHub Release are created automatically.
- R-3 The automation treats the PR body as untrusted input and is idempotent.
- R-4 senior-mindset offers the same automation to the apps it builds.

## Acceptance criteria

- AC-1 `.github/workflows/on-merge.yml` runs on push to `master`, finds the merged PR, closes the specs it names, and tags new skill versions.
- AC-2 Scripts validate ids (`^SPEC-[0-9]{4}$`) and SemVer, read the PR body from an env var, skip specs already Implemented and tags that exist, and fail with a clear message on a missing spec or a non-Approved status.
- AC-3 `CLAUDE.md` documents `Closes-Spec:`, the bot exception and the manual fallback.
- AC-4 senior-mindset: `references/release-automation.md` with an app template; `sdd.md`, `versioning.md`, `git.md` and `SKILL.md` updated.
- AC-5 Merging the 1.5.0 release PR (`Closes-Spec: SPEC-0005`) makes the bot mark this spec Implemented and create `senior-mindset-v1.5.0` plus its Release, with no closing PR.

## Out of scope

- Branch protection setup.
- Running `claude plugin validate` in CI.
