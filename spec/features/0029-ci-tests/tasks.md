# SPEC-0029 tasks

One branch per task. Executed through PLAN-0029.

- [x] T-1 Port the scratchpad suites into `tests/ci/`, portable and self-contained, plus a check-docs suite (AC-1)
- [x] T-2 `scripts` job in `checks.yml`, the revert check, AGENTS.md, INVENTORY, the `testing.md` line (AC-2, AC-3, AC-4)
- [ ] T-3 PATCH release with `Closes-Spec: SPEC-0029`

## Results (T-2)

- Green run on the PR (#81): <https://github.com/MarcosRamirez/SKILLS/actions/runs/39201724921> (`docs` 4s, `scripts` 12s).
- Revert check (AC-3): the SPEC-0023 guard in `tag-skill-releases.sh` disabled on a throwaway branch,
  draft PR #82 (closed, branch deleted, never merged). The `scripts` job failed:
  <https://github.com/MarcosRamirez/SKILLS/actions/runs/39201835240>. `test-tag-skill-releases.sh` failed 36
  checks (exit status 0 instead of 1, no `refusing to tag save-image-v1.0.2` error or `::error::` annotation,
  an unexpected `would tag`); `test-close-specs.sh` and `test-check-docs.sh` still passed.
- Portability fixes: none needed; the suites passed on ubuntu-latest at the first run.
