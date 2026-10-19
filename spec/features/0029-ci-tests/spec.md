# SPEC-0029: committed tests for the release scripts, run in CI

Type: feature
Status: Implemented
Implemented: 2026-10-19, PR #84
Date: 2026-10-14
Approved by: the user, 2026-10-14, chose it in the postmortem-patterns question ("Pruebas de CI commiteadas")

## Problem

The scripts that close specs and tag releases have good tests, but the tests live in the scratchpad
and were run once, on Windows:

- `close-specs.sh` and the on-merge id extraction: 131 checks, PR #43;
- `tag-skill-releases.sh`: 119 checks, PR #47.

Nothing reruns them when the scripts change, and nothing runs them on Linux, where the scripts
actually run. The "environment" pattern of the register points here (PM-0005, PM-0008, PM-0012):
behaviour was assumed instead of tried in an environment like the real one. The first on-merge run
failed because the runner had no git identity (PM-0008). PM-0009 and PM-0010 were caught by these
very tests, which are not kept anywhere.

## Requirements

- R-1 **Commit the suites** under `tests/ci/`:
  - `close-specs` (all cases of PR #43, including spec/fixes/ and the id extraction);
  - `tag-skill-releases` (all cases of PR #47, including the version-only refusal);
  - `check-docs` (the planted failures of SPEC-0024 T-3 and the adr/ folder rule).

  Each suite builds its own scratch repos in a temp folder and never touches the working tree.
- R-2 **Run them in CI** on every pull request, in `.github/workflows/checks.yml` (SPEC-0024),
  on ubuntu-latest:
  - with a runner-like git config: no global identity unless a test sets one (PM-0008), and `core.autocrlf` off;
  - with no network access needed: `gh` calls are faked, as in PR #47.
- R-3 **The same command runs locally**: `bash tests/ci/run.sh`. It is documented in `AGENTS.md` and
  in the INVENTORY.
- R-4 **When a script changes, its suite changes in the same PR.** This is stated in `AGENTS.md`.
- R-5 **Testing reference in the skill** (`references/testing.md`): before relying on how a platform
  behaves (GitHub, a CI runner, a CLI), try it on a throwaway repository or in CI with a runner-like
  configuration (from the "environment" pattern).

## Acceptance criteria

- AC-1 `tests/ci/` with the three suites and `run.sh`. Every case of PR #43 and PR #47 is present.
- AC-2 `checks.yml` runs them on a pull request, and the run is green on ubuntu-latest.
- AC-3 Reverting the SPEC-0023 tag guard, or the SPEC-0022 `SPEC_DIRS` change, in a scratch branch
  makes the matching suite fail in CI.
- AC-4 `AGENTS.md` documents the local command and the "suite changes with its script" rule.
  `references/testing.md` has the throwaway-environment line.

## Out of scope

- Headless model runs (SPEC-0028).

## Changelog

- 2026-10-18: this repo's instructions moved to AGENTS.md (SPEC-0019); references to CLAUDE.md as the conventions file now name AGENTS.md.
