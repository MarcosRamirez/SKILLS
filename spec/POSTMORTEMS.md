# Postmortems

One row per bug, newest last. The register is how this project learns.

**How to use it**

- Read it before writing a spec, when reviewing a change and when preparing a release.
- Add a row when a bug is fixed, with or without a spec. Link the fix spec or the commit.
- Prevention status: `done` (with where), `pending` (with its spec) or `none` (say why).
- When three rows share a category, propose a spec that removes the pattern, not only the cases.
- Blameless: describe the system and the missing guard, never the person.
- A bug found but not fixed yet gets its row too, marked `fix pending` or `fix in progress` with
  its spec. The row is completed when the fix lands.
- Method, templates and categories: [postmortem.md](../skills/senior-mindset/references/postmortem.md).
  A fix spec holds its own `## Postmortem`. Bugs without a fix spec have theirs
  [below](#postmortems-without-a-fix-spec); trivial fixes get only the row.

| Id | Date | What happened | Category | Root cause | Why not caught | Prevention (status) | Link |
|---|---|---|---|---|---|---|---|
| PM-0001 | 2026-10-12 | save-image's `SKILL.md` said `version: "1.0"` while its new `plugin.json` said `1.0.0` | docs drift | The version lives in two files, and nothing compares them | No check compares the two fields; found by reading, while preparing senior-mindset 1.1.0 | Rule "keep `metadata.version` identical" (done: CLAUDE.md, Versioning); one version per skill, in `SKILL.md`, and `check-versions.py` on every PR keeps the marketplace entry equal (done: SPEC-0021 T-1, per ADR-0006) | [dd86ac5](https://github.com/MarcosRamirez/SKILLS/commit/dd86ac5) |
| PM-0002 | 2026-10-12 | A headless run of 1.1.0 could not ask the user, so it picked every default and built a whole app. It wrote only `spec.md` and marked it Implemented | process gap | "No code before an approved spec" was one sentence. It did not define approval or say what to do when the user cannot be asked | The skill had never run without a user before 1.1.0 shipped; no headless test | Approval gate with a Draft stop (done: `SKILL.md` Step 3, `sdd.md`; it did not hold, see PM-0006); repeatable headless tests (done: SPEC-0028, `tests/headless/`) | [SPEC-0001](features/0001-senior-mindset-1-2-0/spec.md) F1, F2; [dfbd476](https://github.com/MarcosRamirez/SKILLS/commit/dfbd476) |
| PM-0003 | 2026-10-12 | The same run skipped `CHANGELOG.md` and `cliff.toml`, which 1.1.0 listed for kickoff, and committed the whole app at once on `master` | process gap | Kickoff had no exit check. Its artifacts were a list to read, not a checklist to verify and commit before the first feature | Nothing checked the kickoff artifacts or the shape of the history | Verified kickoff checklist on its own branch (done: `SKILL.md` kickoff); one branch per change (done: `SKILL.md`, `git.md`); the suite checks both (done: SPEC-0028, `tests/headless/`) | [SPEC-0001](features/0001-senior-mindset-1-2-0/spec.md) F3, F4, F7; [11238c6](https://github.com/MarcosRamirez/SKILLS/commit/11238c6), [639e8be](https://github.com/MarcosRamirez/SKILLS/commit/639e8be) |
| PM-0004 | 2026-10-12 | Asked for "a python script that renames photos by date", the skill did not load: file name, functions and flags came out in Spanish | code defect | The always-on rules load only when the skill's description matches the prompt, and the description named only project-sized requests | No trigger test: no set of prompts that must load the skill | Description covers any code change, scripts included (done: `SKILL.md` frontmatter); trigger prompts (done: SPEC-0028, `tests/headless/`). Recurred for merges: PM-0011 | [SPEC-0001](features/0001-senior-mindset-1-2-0/spec.md) F6; [cde6c4f](https://github.com/MarcosRamirez/SKILLS/commit/cde6c4f) |
| PM-0005 | 2026-10-13 | Merging the bottom PR of the SPEC-0002 stack with `--delete-branch` closed #3, #5 and #7 instead of retargeting them; SPEC-0002 had to land again as one PR | environment | The stacked-PR procedure said GitHub retargets a PR when its base branch is deleted. That platform behaviour was written down without being tried | The flow ran for the first time on real PRs, not on a throwaway stack | Retarget, merge without deleting, delete last (done: `git.md`, CLAUDE.md; stacks #16 to #19 and #31 to #34 merged cleanly); see the environment pattern | [PR #8](https://github.com/MarcosRamirez/SKILLS/pull/8), [5f0d95e](https://github.com/MarcosRamirez/SKILLS/commit/5f0d95e) |
| PM-0006 | 2026-10-13 | A headless "créame una app de tareas" with 1.3.0, which had the 1.2.0 gate, built the whole app: the failed question was read as "skipped" and defaults were picked | process gap | The gate sat in the middle of Step 3 and did not say that a failed or skipped question is not an answer | The 1.2.0 gate shipped without re-running the headless test that found PM-0002; no release step asked for it | Hard rules at the top of `SKILL.md`, verified headless (done: `SKILL.md`, SPEC-0003 T-2); gate kept for trivial fixes and clickable questions (done: df4c658, SPEC-0016 AC-3); suite before every release (done: SPEC-0028, `tests/headless/`) | [SPEC-0003](features/0003-headless-approval-gate/spec.md); [de1ce4e](https://github.com/MarcosRamirez/SKILLS/commit/de1ce4e) |
| PM-0007 | 2026-10-13 | After 1.3.0 the inventory still called `git.md` a "fallback git convention when no git skill is installed", though it now defined the pull-request flow | docs drift | CLAUDE.md asks for an inventory update only when files are added, moved or removed, not when what a file does changes | Neither the rule nor a check covers a change of role | Line fixed (done); the rule also covers a change in what a file does (done: SPEC-0030) | [d6e2f49](https://github.com/MarcosRamirez/SKILLS/commit/d6e2f49) |
| PM-0008 | 2026-10-13 | The first real on-merge run (merge of #19) failed in the tag step for lack of a git identity. SPEC-0005 stayed open and 1.5.0 was tagged by hand | environment | The identity was set only in a later step. Local tests passed because the machine had a global identity | Tests ran with a configured git, not a runner-like one (`GIT_CONFIG_GLOBAL=/dev/null`) | Identity set right after checkout (done: `on-merge.yml`, app template); workflow tests with a runner-like config (done: SPEC-0029, `tests/ci/` in CI) | [PR #20](https://github.com/MarcosRamirez/SKILLS/pull/20), [e985f41](https://github.com/MarcosRamirez/SKILLS/commit/e985f41); [SPEC-0005](features/0005-close-on-merge/spec.md) |
| PM-0009 | 2026-10-13 | The on-merge step that commits closed specs would abort before committing when no changed path matched its id grep (a fix-only PR, or only a roadmap row); its fallback id was dead code | tooling | Under `set -euo pipefail` a grep with no match fails the assignment, and no test had ever run this inline step's no-match path | Inline workflow steps had no tests. SPEC-0022 caught both cases (R-5, a probe in its T-2 suite) before a real run hit them | Both cases fixed (done: abba42e, cac50d9); the line checked under pipefail (done: PR #43, scratch only); committed workflow tests (done: SPEC-0029, `tests/ci/` in CI) | [PR #43](https://github.com/MarcosRamirez/SKILLS/pull/43), [abba42e](https://github.com/MarcosRamirez/SKILLS/commit/abba42e), [cac50d9](https://github.com/MarcosRamirez/SKILLS/commit/cac50d9) |
| PM-0010 | 2026-10-13 | Nothing stopped a version moving with nothing implemented: git-cliff proposes a PATCH for a docs-only commit, and the tag script tagged a version-only bump. No such version was released | spec gap | The rule was implicit. The release step trusted the version calculator, and the tag script only checked that the tag did not exist yet | No test ran a docs-only range or a version-only bump | Rule, release check and tag guard (done: `versioning.md`, `SKILL.md`, CLAUDE.md, `tag-skill-releases.sh`); their tests in CI (done: SPEC-0029, `tests/ci/` in CI) | [SPEC-0023](fixes/0023-bump-only-on-implementation.md) |
| PM-0011 | 2026-10-14 | In the SPEC-0016 tests, "should we merge?" loaded only the git-workflow skill. With the question tool available, the agent merged on its own in two of two Spanish runs | code defect | Same cause as PM-0004: the git rules load only with the skill, and its description does not cover git-only requests (merge, push, pull request) | No trigger test; found by chance while testing questions | fixed; conventions block (done, SPEC-0027); trigger scenarios in the headless suite (done: SPEC-0028, `tests/headless/`) | [SPEC-0027](fixes/0027-git-requests-skip-the-rules.md); [SPEC-0016 T-2 results](features/0016-clickable-answers/tasks.md#test-results-t-2-2026-10-14), [PR #50](https://github.com/MarcosRamirez/SKILLS/pull/50) |
| PM-0012 | 2026-10-14 | The same headless runs rewrote the user's real `~/.claude/senior-mindset.md` through the skill's update notice (`senior-mindset version` 1.3.0 to 2.2.1) | environment | Headless test runs use the user's real home, so the skill's user-level setup file is shared with them | The test procedure has no isolation step and no check that the home is unchanged afterwards | fixed: headless runs use `acceptEdits` and a user-file hash check (done: SPEC-0028, `tests/headless/`; an isolated home loses the login) | [PR #50](https://github.com/MarcosRamirez/SKILLS/pull/50) |
| PM-0013 | 2026-10-14 | PR #40 accepted ADR-0005 and ADR-0006 but updated none of the living documents. CLAUDE.md still cites the superseded ADR-0001 and ADR-0003, and the READMEs install Claude-first and globally | docs drift | Accepting an ADR does not require checking the documents that describe the decision; the documentation rule covers skill changes, not decisions | No check flags a link to a superseded ADR. PR #40 deferred CLAUDE.md to plan 0021 without marking it in the document | `check-docs.py` on every PR (done: SPEC-0024 T-3); impact sweep for every decision (done: SPEC-0025, senior-mindset 2.5.0) | [SPEC-0024](fixes/0024-docs-out-of-step-with-adrs.md) |
| PM-0014 | 2026-10-19 | In the 2.9.0 pre-release suite, `kickoff-checklist` failed: the agent ran `git init` through Claude Code's PowerShell tool, which the scenario does not allow (only `Bash(git:*)`), so no repository and no kickoff branch were made | environment | Claude Code 2.1.303 on Windows offers a PowerShell tool next to Bash; the suite granted shell commands only through Bash and never pinned the tool | The suite ran green on 2.1.296, before the agent started using PowerShell; nothing checked which shell tool a run used | `run_claude` passes `--disallowedTools PowerShell` so commands go through Bash (done: SPEC-0021 T-6, `tests/headless/lib.sh`) | [SPEC-0021 tasks](features/0021-standard-install/tasks.md) |
| PM-0015 | 2026-10-19 | After SPEC-0021 T-1 removed `skills/*/.claude-plugin/`, the root README's structure block still listed `.claude-plugin/ — Claude Code plugin manifest` under each skill; found and fixed in T-5 | docs drift | The T-1 sweep searched for `plugin.json`, the file name, but the README named only the folder, `.claude-plugin/` | `check-docs.py` checks links, not paths written as text in a structure block | Sweep every replaced term: file and folder names (rule exists: impact sweep in AGENTS.md); a check for dead paths in living documents (proposed, no spec yet) | [SPEC-0021 tasks](features/0021-standard-install/tasks.md) |
| PM-0016 | 2026-10-19 | The inventory gate in `onboarding.md` (SPEC-0009 T-1) reported every endpoint as missing when run from Git Bash: MSYS turned the route `/orders` into a Windows path before `git grep` saw it | environment | Git Bash rewrites arguments that look like absolute POSIX paths; the gate passes route strings as arguments | T-1 tested the gate with identifiers and paths only, not with a route; T-4 found it | `MSYS_NO_PATHCONV=1` on the gate's `git grep`, and the same in the `onboarding-code` scenario (done: SPEC-0009 T-4) | [SPEC-0009 tasks](features/0009-onboarding-normalization/tasks.md) |
| PM-0017 | 2026-10-19 | In the 2.10.0 pre-release suite, `no-git` failed: for a change in a folder without git, the agent offered `git init` as one option among others, including editing in place, and never proposed a commit of the current state | code defect | The no-git rule (git init plus a snapshot commit before the change) lived only in `existing-projects.md`, which loads on demand; hard rule 4 did not mention it | The scenario passed on 2.9.0: the miss is intermittent, and the new onboarding step adds more to weigh in an existing folder | One sentence in hard rule 4: git init and a snapshot commit first, never edit in place without it (done: SPEC-0009 T-5) | [SPEC-0009 tasks](features/0009-onboarding-normalization/tasks.md) |

## Patterns

Rows per category. At three, propose a spec that removes the pattern.

| Category | Rows |
|---|---|
| spec gap | 1 (PM-0010) |
| docs drift | 4 (PM-0001, PM-0007, PM-0013, PM-0015) |
| process gap | 3 (PM-0002, PM-0003, PM-0006) |
| code defect | 3 (PM-0004, PM-0011, PM-0017) |
| tooling | 1 (PM-0009) |
| environment | 5 (PM-0005, PM-0008, PM-0012, PM-0014, PM-0016) |

**process gap: three rows.** The skill's workflow steps (approval, the kickoff checklist) were prose
that a run could skip, and only a headless run of the real skill showed it. Those runs are manual
and are not repeated before a release, so the 1.2.0 gate shipped untested and failed in 1.3.0.
Spec: **[SPEC-0028](features/0028-headless-suite/spec.md)** (headless suite).

**docs drift: three rows.** One fact is written in several places: a version in two files, a
file's role in the inventory, a decision in an ADR and in the living documents. A change reaches
only some of them, and the documentation rule lists its triggers too narrowly (files added, moved
or removed; skill changes, not decisions). Already against the pattern: SPEC-0024 (`check-docs.py`),
SPEC-0025 (impact sweep for decisions) and SPEC-0021 (a check keeps the versions equal). Not covered
yet: a change in what a file does. Spec: **[SPEC-0030](features/0030-role-change-rule.md)** (role-change rule).

**environment: three rows.** Behaviour that depends on the environment was assumed instead of tried
in one like the real one: GitHub's handling of stacked PRs, a runner without a git identity, test
runs that share the user's real home. Proposed: "test in an environment like the real one" becomes
part of the **headless suite** (isolated home) and of the **CI tests** (runner-like git config),
plus a line in the skill's testing reference: a procedure that relies on platform behaviour is
first tried on a throwaway repository.

**code defect: three rows.** PM-0004, PM-0011 and PM-0017 share one cause: a rule that must always
hold lives somewhere that is not always read, either the skill itself (loaded only when its
description matches) or a reference (loaded only when the agent follows the link). The **git
trigger fix** and the trigger prompts of the **headless suite** target the first half. Proposed
for the second half: an audit of the references for rules that must hold without being read
(each one moves to a hard rule or a step of `SKILL.md`, in one sentence), with a headless scenario
for each. Not specified yet: it waits for the user's go-ahead.

### Specs against the patterns

Approved by the user on 2026-10-14 and written: git trigger fix [SPEC-0027](fixes/0027-git-requests-skip-the-rules.md), headless suite [SPEC-0028](features/0028-headless-suite/spec.md), CI tests [SPEC-0029](features/0029-ci-tests/spec.md), role-change rule [SPEC-0030](features/0030-role-change-rule.md).

- **headless suite**: scripted `claude -p --plugin-dir` scenarios with checks, run in an isolated
  home, committed, and run before every release. Scenarios: the approval gate with a failing
  question, the kickoff checklist and the branch history, the script fast path in English, trigger
  prompts (a script, a merge) and the merge question. Rows: PM-0002, PM-0003, PM-0004, PM-0006,
  PM-0011, PM-0012.
- **CI tests**: commit the scratch suites of PR #43 (on-merge, `close-specs.sh`) and PR #47
  (`tag-skill-releases.sh`), and run them on every pull request next to the `checks.yml` of
  SPEC-0024, with a runner-like git config. Rows: PM-0008, PM-0009, PM-0010.
- **git trigger fix** (a fix spec): senior-mindset loads for git-only requests (merge, push, pull
  request), checked with trigger prompts. Compare it with keeping the git hard rules in the
  always-loaded project instructions (SPEC-0019). Row: PM-0011.
- **role-change rule**: the documentation rule also fires when what a file does changes, not only
  when files are added, moved or removed. It could ride on SPEC-0025 R-5, which edits the same rule.
  Row: PM-0007.

## Postmortems without a fix spec

Bugs fixed before SPEC-0022 had no fix spec, and one bug is not fixed yet, so its postmortem
live here, in the template of [postmortem.md](../skills/senior-mindset/references/postmortem.md).
PM-0001 and PM-0007 were trivial fixes and have only their row. PM-0010 has its postmortem in
[SPEC-0023](fixes/0023-bump-only-on-implementation.md#postmortem). PM-0013 has its postmortem in
[SPEC-0024](fixes/0024-docs-out-of-step-with-adrs.md#postmortem). PM-0011 has its postmortem in
[SPEC-0027](fixes/0027-git-requests-skip-the-rules.md#postmortem). When a fix spec is
written for a bug below, its `## Postmortem` takes over and this section links to it.

PM-0002 and PM-0006 are the same symptom twice (SPEC-0003 counts both runs). They are separate rows
because the causes and fixes differ: first there was no gate, then there was a gate that did not
hold. As two rows, the recurrence shows in the Patterns count.

### PM-0002: approval skipped in a headless run (1.1.0)

**Impact.** The test run built a whole app nobody approved, with only `spec.md`, marked
Implemented. Any non-interactive run of 1.0.0 or 1.1.0 could do the same, until 1.2.0 on the same day.

**5 Whys.**

1. Why was the app built without approval? → The run could not ask the user and picked a default
   for every decision.
2. Why did it pick defaults instead of stopping? → The skill said "no code before an approved spec"
   but did not define approval or say what to do when the user cannot be asked.
3. Why did that gap lead to code? → With no defined place to stop, finishing the task was the only
   path the instructions left.

**Why it was not caught.** The skill had never run without a user before 1.1.0 shipped. There was
no headless test.

**Corrective action.** [dfbd476](https://github.com/MarcosRamirez/SKILLS/commit/dfbd476) (1.2.0):
an approval gate recorded in the spec, all three spec files required, and a stop with a Draft spec,
Proposed ADRs and open questions when the user cannot be asked.

**Preventive actions.**

- [x] Approval gate (where: rule, `SKILL.md` Step 3, `references/sdd.md`). It did not hold in headless runs: PM-0006.
- [x] Repeatable headless tests (done: SPEC-0028)

### PM-0003: kickoff checklist skipped (1.1.0)

**Impact.** The test project had no `CHANGELOG.md` or `cliff.toml`, and the whole app sat in one
commit on `master`. Projects started with 1.0.0 or 1.1.0 could have the same gaps.

**5 Whys.**

1. Why were `CHANGELOG.md` and `cliff.toml` missing? → Kickoff moved on to the feature without
   creating them.
2. Why could it move on? → The kickoff items were a list in prose, with no point where the run had
   to confirm them.
3. Why was everything one commit on `master`? → Nothing tied commits to the kickoff and to each
   task, and nothing forbade committing on the default branch.

**Why it was not caught.** Nothing checked the kickoff artifacts or the shape of the history. The
first headless run was the first check.

**Corrective action.** [11238c6](https://github.com/MarcosRamirez/SKILLS/commit/11238c6): a
kickoff checklist that must be complete and committed on its own branch before the spec, with
"N/A + reason" for items that do not apply. [639e8be](https://github.com/MarcosRamirez/SKILLS/commit/639e8be):
one branch per change. Both in 1.2.0.

**Preventive actions.**

- [x] Verified kickoff checklist and kickoff commit (where: rule, `SKILL.md` kickoff)
- [x] One branch per change, never on the default branch (where: rule, `SKILL.md`, `references/git.md`)
- [x] The suite checks the kickoff artifacts and the branch history (done: SPEC-0028)

### PM-0004: the skill did not load for a script

**Impact.** Every script request to 1.0.0 or 1.1.0 ran without the always-on rules: names, flags
and comments followed the user's language, not English.

**5 Whys.**

1. Why were the identifiers in Spanish? → The always-on rules were not in context.
2. Why not? → The skill did not load.
3. Why? → Its description named apps, projects, features, APIs and workers. A script request
   matched none of them.
4. Why can rules meant for every change depend on that? → They live only inside a skill that loads
   when its description matches the prompt, and nothing tests which prompts load it.

**Why it was not caught.** No trigger test: there is no set of prompts that must load the skill.

**Corrective action.** [cde6c4f](https://github.com/MarcosRamirez/SKILLS/commit/cde6c4f) (1.2.0):
the description covers any code change, scripts included, and the script fast path spells out that
names, flags and comments stay in English.

**Preventive actions.**

- [x] Description covers scripts, fixes and releases (where: `SKILL.md` frontmatter)
- [x] Trigger prompts that must load the skill (done: SPEC-0028). The same cause recurred for merges: PM-0011.

### PM-0005: stacked PRs closed when their base branch was deleted

**Impact.** Within three minutes, #3, #5 and #7 were closed, and a closed PR cannot be reopened
while its base is gone. #4 and #6 merged into intermediate branches instead of `master`. SPEC-0002
landed again as one PR ([#8](https://github.com/MarcosRamirez/SKILLS/pull/8)), without its
per-task review units.

**5 Whys.**

1. Why were the PRs closed? → Their base branch was deleted when the PR below was merged with
   `--delete-branch`, and GitHub closes a PR whose base branch is deleted that way.
2. Why was the base deleted at merge time? → `references/git.md` and the SPEC-0002 design said
   GitHub retargets the next PR to the default branch when its base is deleted after merge.
3. Why did they say so? → The platform behaviour was written down as expected, not tried on a
   throwaway stack.

**Why it was not caught.** The stacked flow ran for the first time on real PRs.

**Corrective action.** [5f0d95e](https://github.com/MarcosRamirez/SKILLS/commit/5f0d95e) (1.3.0):
retarget the next PR first, merge without `--delete-branch`, delete the branch last.

**Preventive actions.**

- [x] Safe merge order (where: rule, `references/git.md`, CLAUDE.md "Git"). Each stacked PR body
  states its merge order; the stacks #16 to #19 and #31 to #34 merged in order with none closed.
- [x] A procedure that relies on platform behaviour is first tried on a throwaway repository
  (done: SPEC-0029 R-5, the line in `references/testing.md`, 2.7.0)

### PM-0006: the approval gate failed in headless runs (1.3.0)

**Impact.** The test run built the whole app without approval, with no spec files, no ADRs, no
changelog and one commit. Any non-interactive run of 1.2.0 or 1.3.0 could do the same, until 1.3.1.

**5 Whys.**

1. Why was the app built without approval? → The failed `AskUserQuestion` was read as "the user
   skipped the questions", and defaults were picked.
2. Why was that reading possible? → The gate did not say that a failed or skipped question is not
   an answer.
3. Why did the gate not hold anyway? → It sat in Step 3, in the middle of a long `SKILL.md`, after
   the kickoff steps, where the pull to finish the task is strongest.
4. Why was it not seen before release? → The 1.2.0 gate shipped without re-running the headless
   test that had found PM-0002: SPEC-0001 T-3 lists no test, and no release step asks for one.

**Why it was not caught.** No headless run checked the 1.2.0 gate before it shipped, and no release
step requires one.

**Corrective action.** [de1ce4e](https://github.com/MarcosRamirez/SKILLS/commit/de1ce4e) (1.3.1,
[SPEC-0003](features/0003-headless-approval-gate/spec.md)): a "Hard rules" block at the top of
`SKILL.md`. It names the failed-question case and stops with Draft documents on a branch.

**Preventive actions.**

- [x] Hard rules first, naming the case (where: rule, `SKILL.md` "Hard rules")
- [x] Headless verification as part of the fix (where: test, SPEC-0003 T-2, run by hand)
- [x] The gate kept when later features added exceptions: trivial fixes
  ([df4c658](https://github.com/MarcosRamirez/SKILLS/commit/df4c658), SPEC-0022) and clickable
  questions (SPEC-0016 R-6; its AC-3 headless test passed)
- [x] The suite runs before every release, so a gate that stops holding is caught (done: SPEC-0028)

### PM-0008: on-merge without a git identity; 1.5.0 tagged by hand

**Impact.** One failed run, on the merge of [#19](https://github.com/MarcosRamirez/SKILLS/pull/19).
The tag `senior-mindset-v1.5.0` and its Release were made by hand with the documented fallback.
SPEC-0005 closed one release later (#21). Apps that copied the 1.5.0 template had the same step
order until 1.6.0.

**5 Whys.**

1. Why did the tag step fail? → `git tag -a` needs an identity, and the runner had none.
2. Why none? → The workflow set it only inside the later "Mark closed specs" step.
3. Why did the local tests pass? → They ran on a machine with a global git identity.
4. Why did the tests use that identity? → The test procedure did not reset git to what a fresh
   runner has.

**Why it was not caught.** No runner-like test before the first real run. The commit that fixed it
shows that `GIT_CONFIG_GLOBAL=/dev/null` reproduces the failure locally.

**Corrective action.** [e985f41](https://github.com/MarcosRamirez/SKILLS/commit/e985f41)
([PR #20](https://github.com/MarcosRamirez/SKILLS/pull/20)): the identity is set right after
checkout, in this repository's workflow and in the app template (1.6.0).

**Preventive actions.**

- [x] Identity step before any git write (where: `.github/workflows/on-merge.yml`, `skills/senior-mindset/templates/release-automation/on-merge.yml`)
- [x] Manual fallback documented (where: CLAUDE.md "Releasing a skill")
- [x] Workflow tests in CI with a runner-like git config (done: SPEC-0029)

### PM-0009: on-merge aborting when no spec path changed

**Impact.** None in real runs: every on-merge run since has been green. From
[d7b6ed3](https://github.com/MarcosRamirez/SKILLS/commit/d7b6ed3) (2026-10-13) to the fix the same
day, a merge whose changed list held no matching path would have left its spec open behind a red run.

**5 Whys.**

1. Why would the step abort? → `ids=` is a pipeline under `set -euo pipefail`. When no path
   matched, grep exited 1, the assignment failed, and `set -e` stopped the step before `git commit`.
2. Why did the fallback (`ids="specs"`) not help? → It sat on the next line and expected an empty
   result, not a failure, so it could never run.
3. Why did no test show it? → The logic is inline in the workflow file. The scratch tests covered
   `close-specs.sh`, and no run had a list without a matching path.

**Why it was not caught.** Inline workflow steps had no tests. SPEC-0022 found the fix-only case
while it was designed (R-5), and the probe in its T-2 suite showed the roadmap-only case, both
before a real run hit them.

**Corrective action.** [abba42e](https://github.com/MarcosRamirez/SKILLS/commit/abba42e) matches
`fixes/` paths too. [cac50d9](https://github.com/MarcosRamirez/SKILLS/commit/cac50d9) makes "no
match" non-fatal (`|| true` inside the substitution), without dropping `pipefail` for the step.

**Preventive actions.**

- [x] The `ids=` line evaluated under `set -euo pipefail` with sample lists (where: test, [PR #43](https://github.com/MarcosRamirez/SKILLS/pull/43), scratch only)
- [x] The on-merge tests committed and run in CI (done: SPEC-0029)

### PM-0012: headless test runs rewrote the user's setup file

**Impact.** The real `~/.claude/senior-mindset.md` recorded 2.2.1, the version under test, so it no
longer matched the installed version, and the real update notice up to that version could be skipped.
The first update past 2.2.1 (2.3.0 is out) shows the notice again and records the real version. No
other harm seen.

**5 Whys.**

1. Why was the file rewritten? → Step 0a records the running version once it shows the update
   notice, and the test runs loaded the 2.2.1 copy under test.
2. Why did a test run reach the user's file? → `--plugin-dir` swaps the skill, but the run still
   uses the user's real home, where that file lives.
3. Why was the home not isolated? → The headless procedure (SPEC-0003 T-2, SPEC-0016 T-2) runs in
   a scratch folder, but has no step that isolates the user-level configuration.

**Why it was not caught.** No check that a test run leaves the home unchanged. The PR that recorded
the tests reported it ([PR #50](https://github.com/MarcosRamirez/SKILLS/pull/50)).

**Corrective action.** Pending: part of the headless suite.

**Preventive actions.**

- [x] Headless runs that cannot change the real home, with a check that it is unchanged afterwards (done: SPEC-0028: `acceptEdits` plus a hash check; an isolated home loses the login)
