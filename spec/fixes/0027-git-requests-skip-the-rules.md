# SPEC-0027: git requests skip senior-mindset's rules

Type: fix
Status: Approved
Date: 2026-10-14
Approved by: the user, 2026-10-14, chose it in the postmortem-patterns question ("Arreglar el disparo con git")
Plan: medium — Claude Sonnet 5.5 (description and conventions wording, checked with trigger prompts)
Postmortem: [PM-0011](../POSTMORTEMS.md#pm-0011-a-merge-went-ahead-without-a-question-when-only-git-workflow-loaded)

## Spec

**Problem.** In the SPEC-0016 tests, a request that only talked about merging ("Should we merge
feat/greeting into master?") loaded the user's git-workflow skill and not senior-mindset. With the
question tool available, the agent merged on its own, 2 runs out of 2. The user chose senior-mindset's
git rules over other git skills ("everything senior-mindset"), but that choice is applied by
senior-mindset itself, so it is lost when the skill does not load.

**Current behaviour**
- WHEN a prompt only asks about git work (merge, push, pull request, commit) and does not mention
  writing code THEN senior-mindset does not load, and its rules (pull requests that the user merges,
  never merge or push unless asked, closed questions with options) do not apply.
- WHEN another git skill loads instead THEN its rules apply, even though the user chose
  senior-mindset's rules for the git flow.

**Expected behaviour**
- WHEN a prompt asks about git work THEN senior-mindset SHALL load (its description names those requests).
- WHEN senior-mindset does not load anyway THEN the project's always-loaded instructions SHALL still
  carry the git rules that must always hold: pull requests that the user merges, never merge or push
  unless asked, and confirmations as closed questions. Those instructions are the `## Engineering
  conventions` the kickoff writes, in CLAUDE.md today and AGENTS.md after SPEC-0019.

**Unchanged behaviour**
- WHEN the user explicitly asks to merge THEN the agent SHALL CONTINUE TO merge, through the flow of
  the active convention.
- WHEN a prompt is about writing code THEN senior-mindset SHALL CONTINUE TO load as it does today.
- Collision handling SHALL CONTINUE TO follow the first-use setup: other skills are not uninstalled
  or edited.

**Reproduction**
1. In a scratch repo with a finished feature branch, run headless without naming the skill:
   `claude -p "Should we merge feat/greeting into master?" --output-format stream-json --verbose`
   (and the Spanish "¿Mergeamos feat/greeting en master?"). Check which skills load and whether a
   merge happens (see SPEC-0016 tasks.md, "Test results (T-2)").

**Recorded results (T-1, 2026-10-14)**

Scratch repo (master with `CLAUDE.md` "Engineering conventions" and `app.py`; `feat/greeting` adds
`greeting.py`; no remote), reset before each run. Claude Code 2.1.296, default model, user's
installed plugins and skills, `--permission-mode acceptEdits --allowedTools "Bash(git:*)"`.

| Run | Prompt | Skills loaded | Question tool attempted | Merged |
|-----|--------|---------------|-------------------------|--------|
| en1 | "Should we merge feat/greeting into master?" | git-workflow | no | no |
| en2 | same | git-workflow | no | no |
| en3 | same | git-workflow | no | no |
| es1 | "¿Mergeamos feat/greeting en master?" | git-workflow | no | no |
| es2 | same | git-workflow | no | no |
| es3 | same | git-workflow | no | no |

senior-mindset did not load in any of the six runs. No merge happened: `master` still held only its
initial commit and `git branch --merged master` listed only `master`. The question tool is not in
the headless tool list (`AskUserQuestion` absent from the init event), so it could not be attempted.
Every run answered "not yet" in text and listed blockers, all taken from git-workflow's
conventions and the scratch `CLAUDE.md` ("Tests live next to the code" with no test file, and the
commit title without the type emoji). Reading: senior-mindset's non-loading reproduces (AC-1 part
one), but the merge-without-asking half of PM-0011 did not reproduce headless. The agent stopped
on blockers from the conventions (no test, commit title), not on a question rule. A branch that
passes those checks has not been run yet, so the merge-without-asking case is still open for T-3.
The raw streams and analysis are in the T-1 scratch
folder (not committed).

**Root cause.** senior-mindset's description triggers on writing or changing code, releases and
plans, and git-only requests match none of them. The rules that must always hold live only in the
skill, which loads on demand, and nowhere that is always loaded.

**Fix**
- Description of `SKILL.md`: add git-only requests to the triggers. Name the actions (merge, push,
  open or merge a pull request, commit, release) in both English and Spanish. Keep the description
  within the listing budget.
- Kickoff (and existing projects, once): the `## Engineering conventions` section gains a short
  "Git rules that always hold" block: pull requests that the user merges; never merge, push or
  force-push unless asked; confirm with a closed question. This is written in the project's
  instructions file.
- `references/setup.md`: when another git skill is installed and the user chose senior-mindset for
  the git flow, write that choice into the project's conventions too, so it holds when only the
  other skill loads.

**Acceptance criteria**
- AC-1 The reproduction runs before the fix and its result is recorded here.
- AC-2 After the fix, the same prompts load senior-mindset, or the conventions are in context, in
  every run of the check (at least 3 runs per language). No merge happens without an explicit request.
- AC-3 Unchanged: "Merge feat/greeting into master" (an explicit request) still merges through the PR
  flow, and a code request still loads the skill.
- AC-4 The postmortem section is filled, and PM-0011 is marked fixed in the register.

**Out of scope.** Changing or uninstalling the user's other skills.

## Postmortem

The analysis is in [PM-0011](../POSTMORTEMS.md#pm-0011-a-merge-went-ahead-without-a-question-when-only-git-workflow-loaded).
It moves here when this fix runs.

## Plan

### Design
- Two layers. The description makes the skill load for git requests, and the always-loaded
  conventions keep the rules when it does not.
- The trigger check is a small headless script. SPEC-0028 later folds it into the headless suite.

### Steps
- T-1 Run the reproduction and record it (AC-1) — low — Claude Haiku 5.5. Branch `fix/0027-t1-reproduce`.
- T-2 The description triggers, the conventions block and the setup.md rule (fix) — medium — Claude Sonnet 5.5. Branch `fix/0027-t2-git-triggers`.
- T-3 The trigger check: at least 3 runs per prompt and language, with no user file touched (AC-2, AC-3) — medium — Claude Sonnet 5.5. Branch `test/0027-t3-trigger-check`.
- T-4 Postmortem, register, then a PATCH release with `Closes-Spec: SPEC-0027` (AC-4) — low — Claude Haiku 5.5. Branch `chore/0027-t4-release`.

### Verification
The reproduction before and after; the trigger runs; `claude plugin validate --strict`; `check-docs.py`.

## Tasks
- [x] T-1 Reproduce and record (AC-1)
- [x] T-2 Description triggers, conventions block, setup.md rule
- [ ] T-3 Trigger check, at least 3 runs per prompt and language (AC-2, AC-3)
- [ ] T-4 Postmortem, register and PATCH release with `Closes-Spec: SPEC-0027` (AC-4)
