# PLAN-0032: write-skill

Tier: low. One branch, four commits, one pull request (the user chose a single review unit).

## Design

**Layout.** The skill is instructions plus one validator. No hooks, no network:

```text
skills/write-skill/
  SKILL.md                  the procedure, under the 100-line target
  README.md                 for humans: what it does, install, files
  references/standard.md    frontmatter fields and limits, directories, disclosure
  references/description.md how to write triggers, with good and bad examples
  references/budget.md      token math, warning vs error, anti-patterns, measuring
  references/checklist.md   the pre-publish checklist, one line per rule
  scripts/validate-skill.py the budgets and the structure, stdlib only
```

**Why not reuse a third-party skill creator.** None is installed in this repo and the curated
catalog has no entry for one. Writing it here keeps the licence MIT, the language English and the
rules tied to the checks this repo already runs.

**Two levels of budget.** The standard says 500 lines and ~5000 tokens for `SKILL.md`; this repo
wants less. The validator therefore *errors* at the standard's limits and *warns* at the repo's
targets, so a skill can be valid and still be told it is fat. `--strict` turns warnings into errors
for CI of skills that want the stricter rule.

**What counts.** `SKILL.md` lines are the whole file, frontmatter included. Words and estimated
tokens are the body after the frontmatter; tokens are estimated as `ceil(chars / 4)` and the summary
says "estimated". Links are Markdown links, because that is the only form the checker can resolve
without guessing; paths in inline code are not validated.

**One level, enforced twice.** `references/` may hold `.md` files, not folders, and a file under
`references/` may not link to another reference. A reference the body never links is a warning:
dead weight.

**Validator contract.** `python3 scripts/validate-skill.py <skill-dir> [--soft-lines N]
[--soft-words N] [--max-lines N] [--strict] [--json]`. Finds relative to the skill folder, prints
`path:line: error|warning: message`, then a summary line (`N errors, M warnings` and the measured
lines, words and estimated tokens). Exit 0 clean, 1 with errors (or warnings under `--strict`),
64 on usage.

## Steps

- T-1 This spec, the plan, the tasks and the roadmap row (AC-4 in part). `docs/0032-write-skill`.
- T-2 The skill: `SKILL.md`, `README.md` and the four references. `feat/0032-t2-skill`.
- T-3 `scripts/validate-skill.py`, `tests/ci/test-validate-skill.sh`, its entry in
  `tests/ci/run.sh` and in `tests/ci/README.md` (AC-1, AC-2, R-5). `feat/0032-t3-validator`.
- T-4 Marketplace entry `0.0.1-alpha.1`, root README, inventory, roadmap status and the PR body
  (AC-3, AC-4). `chore/0032-release`.

## Verification

```bash
python3 skills/write-skill/scripts/validate-skill.py skills/write-skill
npx skills-ref validate skills/write-skill
python3 .github/scripts/check-versions.py
python3 .github/scripts/check-docs.py
python3 .github/scripts/check-catalog.py
bash tests/ci/run.sh
claude plugin validate .
```

AC-5 runs after the merge, when the tag exists; it is listed under "Post-merge checks" in the PR
body, not in `tasks.md`.

## Risks

- **Windows and `python3`.** The Store stub answers `python3` without running Python. The suites
  honour `PYTHON`; locally we run them with `PYTHON=python` if needed.
- **Line budgets drift.** A skill that just fits is one edit away from a warning; `--strict` in the
  suite keeps this skill honest.
- **The validator is not the standard.** `skills-ref` remains the reference; ours adds this repo's
  budgets, and the tests pin the difference.
