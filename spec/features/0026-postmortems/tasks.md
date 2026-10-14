# SPEC-0026 tasks

One branch per task. Executed through PLAN-0026.

- [x] T-1 `references/postmortem.md`, the `## Postmortem` section of the fix template, the rule in `SKILL.md` (AC-1, AC-4)
- [x] T-2 `spec/POSTMORTEMS.md` with the postmortems of the bugs already found (AC-2)
- [x] T-3 Headless test of the fix flow with postmortem and register row (AC-3)
- [x] T-4 Minor release with `Closes-Spec: SPEC-0026`

## Test results (T-3, 2026-10-14)

Scratch project: a git repo (`master`) with a `CLAUDE.md` that has `## Engineering conventions`,
the `spec/` layout, and `shop/cart.py` whose `total()` divides by `len(prices)` (fails for an
empty cart), with two passing tests. Run once, working copy of the skill, no wording fix needed:

```text
claude -p "Bug: total() in shop/cart.py raises ZeroDivisionError for an empty cart. I approve
  the fix: use the senior-mindset fix flow, write the fix spec, fix it, and do everything the
  skill requires after a fix. Do not ask questions; do not edit anything outside this project."
  --plugin-dir D:/Code/Projects/SKILLS/skills/senior-mindset --output-format stream-json
  --verbose --permission-mode acceptEdits --allowedTools "Bash"
```

`acceptEdits` lets it write files; `--allowedTools "Bash"` was added so git and python run
without a prompt (headless cannot answer one). The skill loaded
(`senior-mindset:senior-mindset`), the run exited 0 and the agent asked nothing.

What it produced, on branch `fix/0001-empty-cart-total` (3 commits, none on `master`):

- `spec/fixes/0001-empty-cart-total.md`: `Approved by` quotes the user's approval; sections
  `## Spec` (current / expected / unchanged behaviour, reproduction, root cause, AC),
  `## Postmortem`, `## Plan`, `## Tasks`. The postmortem has all the required fields: **Impact.**,
  **5 Whys.** (three whys, stopping at an actionable cause), **Why it was not caught.**,
  **Corrective action.**, **Preventive actions.** (`- [x] Regression test for the empty cart and a
  single-item boundary test (where: tests/test_cart.py)`).
- `spec/POSTMORTEMS.md`, created from the template with one row and the Patterns table
  (`code defect` = 1):

  ```text
  | PM-0001 | 2026-10-14 | `total()` raised `ZeroDivisionError` for an empty cart | code defect | Average computed as `sum / len` with no guard for an empty list | No boundary test; both tests used two-item carts | Empty-cart and single-item tests (done: tests/test_cart.py) | [SPEC-0001](fixes/0001-empty-cart-total.md) |
  ```

- Test first: the transcript shows `Ran 4 tests ... FAILED (errors=1)` (`test_empty_cart` with
  `ZeroDivisionError`) before the guard clause and `Ran 4 tests ... OK` after it; a
  single-item test was added for unchanged behaviour. `python -m unittest discover -s tests`
  passes in the final tree.

AC-3: met. Limits: one run, one model, one small bug, so it shows the flow works but not how
often it does. The run named a Haiku model in the fix spec's `Plan:` line; that is the
tiers feature, not this one.

File protection: `~/.claude/senior-mindset.md` was copied to the scratch folder before the run.
Its SHA-256 was `e2245cbe...905941` before and after the run; the backup was restored over it
anyway and `cmp` reported the two identical. Nothing else under `~/.claude/` was touched on
purpose. The raw output (`run1.jsonl`) stays in the scratch folder.
