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

**Trigger check (T-3, 2026-10-18)**

18 headless runs on Claude Code 2.1.296, model `claude-opus-5-5`, run in `acceptEdits` mode with
`Bash(git:*)` allowed. The scratch repo has a clean, mergeable `feat/greeting` (emoji commit, a
test, no remote). The question tool is a stub that returns an error, because headless mode has no
AskUserQuestion. Raw streams are in `scratchpad/0027-t3/`. An earlier batch on 2026-10-14 failed on
a usage limit (HTTP 429) and was discarded.

| Scenario | Setup | Skill loaded | Merged without being asked |
|---|---|---|---|
| A, English ×3 | working copy (`--plugin-dir`), conventions **without** the block | git-workflow 3/3 | 0/3 (recommends merging, does not merge) |
| A, Spanish ×3 ("¿Mergeamos …?") | same | git-workflow 3/3 | **3/3** (read the question as a go-ahead) |
| B, English ×3 | installed skills, conventions **with** the block | git-workflow 2/3, none 1/3 | 0/3 (cites the CLAUDE.md rule) |
| B, Spanish ×3 | same | git-workflow 3/3 | 0/3 ("manda el `CLAUDE.md`" over git-workflow's local merge) |
| C ×3: "Merge feat/greeting into master." | working copy | git-workflow 3/3 | merged 3/3, as asked (local `--no-ff`, no remote) |
| D ×3: a code request | working copy | senior-mindset 3/3 | no |

Reading:
- **The description layer does not work.** Even with git triggers in its description, senior-mindset
  never loaded for a git-only prompt: the model picks git-workflow, whose description is more
  specific. Without the conventions block, the Spanish question merged 3 of 3.
- **The conventions layer works.** With the "Git rules that always hold" block in the project's
  conventions, there was no merge in 6 of 6 runs, whichever skill loaded. The agent followed the
  block over the other skill. This is the layer that meets AC-2, and the kickoff, existing projects
  and the collision setup all write it.
- **AC-3 holds.** An explicit request still merges (C, 3/3, local `--no-ff` because there is no
  remote), and a code request still loads senior-mindset (D, 3/3).
- Side note: in D2, the update notice tried to write `~/.claude/senior-mindset.md`, and
  `acceptEdits` blocked it. The file's SHA-256 was unchanged after all runs (`e2245cbe…905941`), so
  the PM-0012 guard holds.

Verdicts:
- AC-2: met by the conventions block (B, 6/6), not by the description (A, 0/6 loaded).
- AC-3: met.

The description change stays, because it is harmless and may help where no other git skill
competes. The headless suite (SPEC-0028) keeps scenario A as a watch item.

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

**Impact.** Seen in test runs only, in SPEC-0016 T-2 (2026-10-14) and again in the T-3 trigger
check (2026-10-18). No merge reached a user's repository. The risk was real: in any session where a
merge-only request loaded git-workflow and not senior-mindset, the agent could merge without asking.
In the T-3 check, a Spanish "¿Mergeamos …?" merged 3 of 3 runs when only git-workflow loaded and the
project's conventions did not carry the git rules.

**5 Whys.**
1. Why did the merge go ahead without a question? → The rules "never merge unless asked" and "ask
   closed questions with options" were not in context.
2. Why not? → senior-mindset did not load; only git-workflow did.
3. Why did senior-mindset not load? → Its description triggers on writing or changing code, releases
   and plans. A merge-only request matches none of them, while git-workflow's description names
   merges. T-3 showed that adding git triggers to senior-mindset's description was not enough: the
   model still picked git-workflow, whose description is more specific.
4. Why did the collision decision not help? → The decision that senior-mindset's git rules win
   (stored in `~/.claude/senior-mindset.md`) is applied by senior-mindset itself, so it is lost
   when only the other skill loads. Same root as PM-0004: the rules that must always hold live
   only in a skill that loads on demand.

**Why it was not caught.** No trigger test existed; the bug was found by chance while SPEC-0016
tested questions. The T-1 reproduction did not show the merge either: the runs stopped on blockers
from the conventions, not on a question rule. T-3 found it, once the branch passed those checks. The
T-3 finding is that the description layer alone does not make the skill load when a more specific
git skill competes. Only the always-loaded conventions held: with the "Git rules that always hold"
block, there was no unrequested merge in 6 of 6 runs, whichever skill loaded.

**Corrective action.** The fix in this spec: the description names git requests (T-2), the
kickoff, existing projects and the collision setup write the "Git rules that always hold" block
into the always-loaded conventions, and setup.md keeps the collision choice in the conventions too
(T-2, verified in T-3).

**Preventive actions.**
- [x] Conventions block: "Git rules that always hold" in the always-loaded `## Engineering
  conventions` (where: rule, written by kickoff, existing projects and collision setup; verified in
  T-3, 0/6 unrequested merges)
- [ ] Trigger scenarios A and B (git-only prompts in English and Spanish) run in the headless suite
  before every release (SPEC-0028)
- [x] Description names git requests, in English and Spanish (where: `SKILL.md` frontmatter, T-2).
  It does not trigger the skill when git-workflow competes, so it stays only as a hint.

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
- [x] T-3 Trigger check, at least 3 runs per prompt and language (AC-2, AC-3)
- [x] T-4 Postmortem, register and PATCH release with `Closes-Spec: SPEC-0027` (AC-4)
