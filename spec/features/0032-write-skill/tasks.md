# SPEC-0032 tasks

One branch per task in the plan, run as one pull request (the user's choice).

- [x] T-1 Spec, plan, tasks and the roadmap row (AC-4 in part)
- [x] T-2 The skill: `SKILL.md`, `README.md` and the four references (AC-1, R-3)
- [x] T-3 `scripts/validate-skill.py`, its CI suite and the wiring in `tests/ci/` (AC-2, R-4, R-5)
- [x] T-4 Marketplace entry, root README, inventory and roadmap status (AC-3, AC-4)
- [x] T-5 One pull request with `Closes-Spec: SPEC-0032` and the results of the checks in its body

## Results

Local run on Windows, Python 3.14.5, Git Bash, 2026-10-28:

- `python skills/write-skill/scripts/validate-skill.py skills/write-skill --strict`:
  `88 lines, 69 in the body, 632 words, ~1023 estimated tokens, 4 references`, `0 errors, 0 warnings`.
- `npx skills-ref validate skills/write-skill`: `Valid skill`.
- `check-versions.py`, `check-docs.py`, `check-catalog.py`: clean.
- `bash tests/ci/run.sh`: all six suites pass (`test-validate-skill.sh` 26 passed, 0 failed).
- `claude plugin validate . --strict`: validation passed.
