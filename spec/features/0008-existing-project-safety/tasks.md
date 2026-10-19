# SPEC-0008 tasks

One branch per task, stacked PRs. Executed through PLAN-0008.

- [x] T-1 Hard rule + Step 0 check in `SKILL.md` (AC-1)
- [x] T-2 `references/existing-projects.md`: notice template, edge-case table, examples (AC-1, AC-6)
- [x] T-3 Headless tests for AC-2…AC-5 with `--plugin-dir`, fix wording until they pass
- [ ] T-4 Release (minor), READMEs, inventory, changelogs; last PR carries `Closes-Spec: SPEC-0008`

## Results (T-3, 2026-10-19)

Four scenarios in `tests/headless/scenarios/`: `existing-code-notice` (AC-2), `existing-docs-notice`
(AC-3), `dirty-tree` (AC-4) and `no-git` (AC-5). Each one was first checked with a fake `claude`:
the passing variant passes, and each failing variant fails the check it targets (an edit, a commit
on a work branch, a Draft spec committed on a `docs/` branch, a `git mv`, mixing, stash, stash and
pop, a new source file). Then each scenario ran once for real: senior-mindset 2.7.0 (working copy),
`claude-opus-5-5`, Claude Code 2.1.303, every question failing (`STUB_MODE=error`).

| Scenario | Run | Result | Cost (USD) | Finding |
|---|---|---|---|---|
| existing-code-notice | 1 | PASS 7/7 | 0.25 | none: a full change notice (3 files, why, risks, rollback, branch), nothing touched |
| existing-docs-notice | 1 | PASS 7/7 | 0.37 | none: a notice listing the 5 `git mv` moves, nothing moved; the question tool was tried once (it failed, as designed) |
| dirty-tree | 1 | FAIL 8/9 | 0.22 | the changes were left intact, but the agent did not ask: it planned to branch with them still in the working tree. It never opened `references/existing-projects.md`, the only place the rule was written |
| dirty-tree | 2, after the fix | FAIL 8/9 under the first check, PASS 9/9 under the corrected one | 0.22 | the agent named both files and offered numbered options (commit on their own branch, stash, stop). The check wanted a literal `?` (see below) |
| no-git | 1 | PASS 5/5 | 0.26 | none: it proposed `git init -b master` and a snapshot commit and did **not** run `git init` itself (no `.git` folder, no `git init` command) |

Total: 5 real runs, 1.32 USD. No usage limit was hit. The code, docs and no-git runs used the skill
text before the wording fix. The fix adds one sentence about uncommitted changes, which none of
those clean projects have.

**Wording fix.** Hard rule 4 in `SKILL.md` now says: uncommitted changes you did not make are never
edited, staged, committed, stashed or carried onto your branch: name them and ask whether to commit
them on their own branch, stash them or stop. The skill README says the same. There is no version
bump: T-4 releases the spec.

**Check correction.** The dirty-tree check required a question mark. Run 2 asked with four numbered
options and "reply with option 1, 2, 3 or 4". That is how `references/questions.md` asks without the
question tool, and `closed-question` already accepts it. Numbered options now count as asking. "Leave
them" no longer counts as the stop option, because run 2 used it for the opposite. Both saved runs
were re-checked with no new model call: run 1 still fails (no stash option, no stop option), and
run 2 passes.

**Open finding (not fixed here).** Run 2 added a fourth option, "Leave them in place
(recommended)": branch and commit only its own files, with the user's changes still in the working
tree. That is close to what the new wording rules out ("carried onto your branch"). It is listed for
the user to decide: either the reference names it as not an option, or it stays allowed.

**Hashes.** `~/.claude/senior-mindset.md` was `e2245cbe…905941` before and after every run.
`~/.claude/CLAUDE.md` was absent throughout, and `~/.gitconfig` stayed `cc01bf857770…`.
