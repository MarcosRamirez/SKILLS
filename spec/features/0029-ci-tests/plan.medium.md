# PLAN-0029: committed tests for the release scripts, run in CI

Spec: [SPEC-0029](spec.md)
Status: Ready
Recommended overall: medium — Claude Sonnet 5.5 (port existing suites, make them portable, wire CI)

## Context

The suites exist in the scratchpad, which is session-specific and is not kept:
- `scratchpad/0022-t2/test-close-specs.sh`;
- `scratchpad/0022-t2/ids-fallback-test.sh`;
- `scratchpad/0023-t3/run-tests.sh` with `fakebin/` (the fake `gh`).

Port them before that folder disappears. They were written for Git for Windows, and CI runs them
on Linux.

## Design

- `tests/ci/run.sh` runs `tests/ci/test-close-specs.sh`, `tests/ci/test-tag-skill-releases.sh` and
  `tests/ci/test-check-docs.sh`, and exits non-zero if any fails.
- Fixtures are built in `mktemp -d`. The scripts under test are copied from the working tree, so
  each suite tests the code in the PR.
- Portability: no Windows-only paths, `printf` instead of `echo -e`, GNU and BSD-safe `sed` (or Python
  for edits), and no reliance on `core.autocrlf`.
- CI: a second job in `checks.yml`, `scripts`, on ubuntu-latest. It sets
  `git config --global init.defaultBranch master` and no identity, and the tests set per-repo
  identities where needed.

## Steps

### T-1 Port the suites — medium
- Recommended: medium — Claude Sonnet 5.5 (porting with care)
- Branch: `test/0029-t1-port-suites`
- Do: copy the scratchpad suites into `tests/ci/`, make them portable and self-contained, add the check-docs suite; run locally
- Done when: AC-1

### T-2 CI job and documentation — medium
- Recommended: medium — Claude Sonnet 5.5 (CI wiring)
- Branch: `test/0029-t2-ci-job`
- Do: the `scripts` job in `checks.yml`; the AC-3 revert check on a scratch branch (not merged); `AGENTS.md` and INVENTORY; the throwaway-environment line in `references/testing.md` (a skill change, so a PATCH release follows)
- Done when: AC-2, AC-3, AC-4

### T-3 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0029-t3-release`
- Do: PATCH bump for the `testing.md` line, changelogs; PR body with `Closes-Spec: SPEC-0029`
- Done when: the bot closes the spec

## Verification

A green CI run on the PR; the revert check fails as expected; `bash tests/ci/run.sh` passes locally.

## Risks

- The scratchpad suites are lost before the port → T-1 goes first; if a suite is missing,
  rebuild it from the cases listed in the PR bodies (#43, #47).
- Flaky CI on Windows-isms → the port removes them; CI is the judge.

## Out of scope

Headless model runs (SPEC-0028).
