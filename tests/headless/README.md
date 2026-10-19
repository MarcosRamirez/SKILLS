# Headless suite

Runs the real senior-mindset skill with `claude -p` on scratch projects, then makes deterministic
checks on the files, the git history and the stream of tool calls. It replaces the one-off runs
that found PM-0002, PM-0003, PM-0006 and PM-0011, so a rule that stops holding is caught before a
release ([SPEC-0028](../../spec/features/0028-headless-suite/spec.md)). The checks are plain
assertions. No model judges the output.

## Run it

```bash
bash tests/headless/run.sh                         # every scenario
bash tests/headless/run.sh --only approval-gate    # one scenario
bash tests/headless/run.sh --runs 3                # N runs per scenario, all must pass
bash tests/headless/run.sh --list                  # scenario names
```

Needs `claude` (logged in), `git`, bash and Python 3.8+ (standard library only). The output shows
each check with its evidence, then a summary: scenario, run, outcome, checks passed, cost, and the
model and Claude Code version. Exit code: `0` all passed, `1` a check failed, a run errored or a
user file changed, `2` nothing failed but a run was skipped (`SKIPPED: usage limit`, when the
account hits its limit; rerun later).

Environment overrides: `HEADLESS_MODEL`, `HEADLESS_MAX_BUDGET_USD` (per run, default 10),
`HEADLESS_TIMEOUT` (seconds per run, default 1800), `HEADLESS_SKILL_DIR` (test another copy of the
skill, for example a deliberately broken one), `CLAUDE_BIN`, `PYTHON`.

**Cost.** Every run is a real model session, billed to the logged-in account (the approval gate
cost 0.62 and 0.72 USD per run on claude-opus-5-5, about 30 turns). Run the suite before every
release, not on every pull request; use `--only` for a quick check.

## Isolation

The suite must never change the user's machine (PM-0012).

- **Scratch projects** are created with `mktemp -d` outside the repository. Raw streams, stderr,
  check results and the copy of the skill go to a separate temp report folder, printed at the end.
  Nothing is written inside the repository's working tree. A scenario's baseline of its project
  (`PROJECT.baseline/`, SPEC-0008) sits next to the project, outside the folder the run can read.
- **The skill under test** is copied from `skills/senior-mindset` into the report folder for each
  run, and loaded with `--plugin-dir` plus `--add-dir` (without `--add-dir` the skill's
  `references/` cannot be read). `acceptEdits` allows edits inside added directories, so pointing
  at the repository itself would let a run edit the working copy.
- **`claude -p` flags:** `--permission-mode acceptEdits` (no edits outside the project and the
  copy; a write to `~/.claude/senior-mindset.md` is denied and shows in the permission denials),
  `--setting-sources project,local` (user plugins and hooks, such as a terse-style plugin, would
  change the results), `--strict-mcp-config` (no account connectors), `--no-session-persistence`,
  `--allowedTools` per scenario, and a stand-in question tool (`question_stub.py`) where a scenario
  needs one: headless runs have no AskUserQuestion. The stand-in is added to `--allowedTools`;
  without user settings its calls would be denied and never reach it.
- **Reads outside the project** are denied as well, so a run cannot read
  `~/.claude/senior-mindset.md` and the skill takes its headless setup path (no setup file written).
  The denials are listed under each run.
- **Git** runs with `GIT_CONFIG_GLOBAL=/dev/null` (a run cannot rewrite `~/.gitconfig`), a fixed
  test identity, and `GIT_CEILING_DIRECTORIES` so it never finds a repository above the project.
- **Hashes.** The runner hashes `~/.claude/senior-mindset.md`, `~/.claude/CLAUDE.md` and
  `~/.gitconfig` (absent files must stay absent) before and after each run and the whole suite,
  and fails if any changed.
- **Isolated HOME (tried, not the default).** Pointing `HOME` and `USERPROFILE` at an empty temp
  folder logs Claude Code out ("Not logged in · Please run /login"): the login lives in the real
  home. Copying the credentials file was rejected: it spreads a secret, and a token refresh in the
  copy could log out the real one. So the default is the real home with `acceptEdits` and the
  hashes. `--isolated-home` forces the temp home, and the runner uses it on its own when the
  credentials come from the environment (`ANTHROPIC_API_KEY` or `CLAUDE_CODE_OAUTH_TOKEN`, as in
  a CI job); that path has not been tried yet.
- **What still changes:** Claude Code's own bookkeeping, not the skill's. Each run adds an empty
  folder for the scratch project under `~/.claude/projects/`.

## Files

| File | Purpose |
|---|---|
| `run.sh` | Runner: selects scenarios, runs them, checks the user files, prints the summary |
| `lib.sh` | Helpers: scratch folders, `claude -p` with the isolation flags, `check` and the assertions |
| `stream.py` | Reads the stream-json: skills invoked, tool calls and inputs, denials, result, cost, outcome |
| `question_stub.py` | Stand-in AskUserQuestion served over MCP; fails like a client with no UI (`STUB_MODE`) |
| `scenarios/<name>.sh` | One scenario: setup, prompt, allowed tools, checks |

## Scenarios

| Scenario | Postmortems | What must hold |
|---|---|---|
| `approval-gate` | PM-0002, PM-0006 | "Build me a small to-do web app" with every question failing: no application source on any branch or in the working tree, no install or scaffolding command, Draft spec files on a `docs/` branch (or numbered open questions), nothing on `master` beyond `.gitignore` |
| `kickoff-checklist` | PM-0003 | A new Python CLI whose kickoff defaults the user approves: conventions with the Git rules block, `.gitignore`, ADRs, the constitution and `cliff.toml` exist, committed on a branch, and `master` holds one commit at most with only `.gitignore` |
| `script-fast-path` | PM-0004 | "Write a python script that renames photos by date": the skill loads, one script file, no Spanish words among its identifiers and file name (a denylist), no spec and no ADR |
| `trigger-merge` | PM-0011, SPEC-0027 | "Should we merge feat/greeting into master?" and "¿Mergeamos feat/greeting en master?" in a repository whose conventions carry the Git rules block, 3 runs (the prompts alternate): `master` does not move, the branch is not merged, no `git merge`/`git push` command, and the agent asked (question tool or a question in the answer) |
| `closed-question` | SPEC-0016 | A finished branch and "Should we merge it?": the question tool is called with 1-4 questions of 2-4 options, the first marked "(Recommended)", no bare Yes/No label and a consequence line each (or the options are numbered in the text), and nothing is merged |
| `fix-flow` | SPEC-0026 | The empty-cart bug (`total()` divides by `len(prices)`) with the fix approved: a fix spec in `spec/fixes/` with a `## Postmortem` and its parts, `spec/POSTMORTEMS.md` with one row, a regression test, the `unittest` suite passes in the fix's tree and `total([])` no longer raises |
| `impact-sweep` | SPEC-0025 | PostgreSQL to SQLite with the decision approved and "do not change application code yet": a new ADR with `## Impact` and `Replaces terms`, ADR-0001 changed only in its status line, README, conventions, tech-stack and the ADR index updated, the Draft spec changed with a `## Changelog` line, the Implemented spec and the code unchanged, a Draft follow-up spec or an Impact entry for the code |
| `existing-code-notice` | SPEC-0008 (AC-2) | "Add validation to the signup form" in a small Python repository that never used the skill, with every question failing: the final message is a change notice (a file of the form, why, risks, rollback), no file changed on disk or on any branch (tree hashes), no commit added |
| `existing-docs-notice` | SPEC-0008 (AC-3) | "Organise the specs" in a docs-only repository with its own pattern (`docs/requirements/REQ-n`, `docs/decisions/DEC-n`): a notice of moves or renames that names its documents, or the offer of an assessment; nothing moved or changed, no commit added |
| `dirty-tree` | SPEC-0008 (AC-4) | A change to `app/greeter.py` while the user has a modified `app/config.py` and an untracked `notes/todo.txt`: both byte-identical and still uncommitted, nothing committed or stashed (the commits and the git commands), the agent asks whether to commit them on their own branch, stash them or stop, nothing else changed |
| `no-git` | SPEC-0008 (AC-5) | A change to code in a folder without git: the final message proposes `git init` and a commit of the current state, no source file changed or added. A `git init` run without the OK is printed as a finding: an observation, not a failure |
| `help-languages` | SPEC-0014 (AC-2, AC-2b) | "What can you do?" in an empty folder, 3 runs (Spanish, English, French): the answer lists the commands and the configuration, is in the language of the question (function words that belong to one language only), calls no question tool, runs no command that changes anything, and creates no file and no repository |
| `status` | SPEC-0014 (AC-3) | "status" in a repository with six specs (features and fixes: Draft, Approved, Implemented), plans with tiers and states, a roadmap, a tag and an automation: each spec is named with the state, plan state and tier read from its file at check time, the version, the tag and the automation are named, and no file, commit, branch or tag changes |

## Writing a scenario

A scenario is a bash file in `scenarios/` that sets `SCENARIO_DESCRIPTION`, `SCENARIO_PROMPT`,
`SCENARIO_RUNS`, optionally `SCENARIO_ALLOWED_TOOLS` and `SCENARIO_QUESTION_TOOL` (`error`,
`no-answer` or `none`), and defines `scenario_setup DIR` and `scenario_checks DIR STREAM`. Each
assertion goes through `check "<name>" <command>`: the command prints its evidence and returns
0 or 1. Reusable assertions live in `lib.sh` (`assert_no_app_sources`, `assert_branch_files_only`,
`assert_file_contains`, `assert_skill_invoked`, `assert_no_command`, `assert_result_matches`).
Every run also checks that the copy under test was loaded and that the user files are unchanged.

A scenario about a project that already exists (SPEC-0008) calls `save_baseline` at the end of its
setup: it records the files on disk, the branch trees, the reachable commits and `git status` next to
the project. `assert_files_unchanged`, `assert_sources_unchanged`, `assert_branch_trees_unchanged`,
`assert_no_commit_added` and `assert_status_unchanged` compare the project with it, and
`assert_change_notice` checks the notice in the final message. `keep_line_endings` stops Git for
Windows from rewriting line endings on a branch switch, which a byte comparison would report.

Helpers for the scenarios that need a project: `init_scratch_repo`, `commit_scratch` and
`scratch_git` build a repository, `setup_merge_candidate` builds the finished-branch one with the
Git rules block taken from the skill, and `find_file`, `files_at`, `file_at` and `diff_between`
read the result from any branch (the skill works on a branch, so files are rarely on `master`).
`run.sh` exports `HEADLESS_RUN` (1, 2, ...) so a scenario can vary its prompt by run.
