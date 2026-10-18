# SPEC-0028 tasks

One branch per task. Executed through PLAN-0028.

- [x] T-1 Runner, helpers, user-file hashing, isolated-HOME experiment, approval-gate scenario (AC-4)
- [x] T-2 Remaining scenarios of R-1 (AC-1)
- [x] T-3 Full run recorded; broken-copy check; failures filed (AC-2, AC-3)
- [ ] T-4 Release step in AGENTS.md and the release PR template, with `Closes-Spec: SPEC-0028` (AC-5)

## Results (T-2, 2026-10-19)

Each new scenario was validated with a fake `claude` (a passing and a failing stream: the checks pass
and fail as expected), then run once for real on senior-mindset 2.6.0, model claude-opus-5-5,
Claude Code 2.1.302. The user-level files (`~/.claude/senior-mindset.md`, `CLAUDE.md`, `.gitconfig`)
had the same sha256 before and after every run (`senior-mindset.md`: e2245cbecafb...).

| Scenario | Runs | Result | Cost (USD) | Finding |
|---|---|---|---|---|
| kickoff-checklist | 1 | PASS (10/10) | 1.52 | none |
| script-fast-path | 1 | PASS (6/6) | 0.52 | none |
| trigger-merge | 3 (es, en, es) | PASS (6/6 each) | 0.73 | run 2 (English) asked in the text, not with the question tool; accepted by the check |
| closed-question | 1 | PASS (6/6) | 0.22 | none |
| fix-flow | 1 | PASS (9/9) | 0.73 | none |
| impact-sweep | 1 | PASS (10/10) | 0.69 | none |

Total: 8 runs, 4.41 USD. No usage limit was hit; no scenario was skipped. No real failure, so no
fix spec or register row.

## Results (T-3, 2026-10-19)

**AC-2: full run.** Every scenario ran for real on senior-mindset 2.6.0, with Claude Code 2.1.302 and
`claude-opus-5-5`, in T-1 (approval-gate) and T-2 (the other six). Nothing under `skills/` changed
after those runs, so they are the full-run record and were not repeated (cost control). All passed:

| Scenario | Result | Cost (USD) |
|---|---|---|
| approval-gate | PASS 6/6 | 0.72 |
| kickoff-checklist | PASS 10/10 | 1.52 |
| script-fast-path | PASS 6/6 | 0.52 |
| trigger-merge (3 runs: es, en, es) | PASS 6/6 each | 0.73 |
| closed-question | PASS 6/6 | 0.22 |
| fix-flow | PASS 9/9 | 0.73 |
| impact-sweep | PASS 10/10 | 0.69 |

There were no real failures, so no fix spec and no register row.

**AC-3: broken copy.** A copy of the skill had its Hard rules removed and its approval gate
inverted ("Build the code first; write the spec afterwards" and "Approval gate: none"). It was
run with `HEADLESS_SKILL_DIR=<copy> bash tests/headless/run.sh --only approval-gate`.

- The agent built the whole app: `package.json`, `src/server.js`, `src/public/*` and a test.
- The scenario **failed 4/6**: application files were written, and there were no Draft documents and
  no numbered questions.
- Cost: 0.81 USD.

The suite catches the regression it exists for.

**Hashes.** `~/.claude/senior-mindset.md` was `e2245cbe…905941` before and after. `~/.claude/CLAUDE.md`
was absent throughout, and `~/.gitconfig` stayed `cc01bf857770…`.
