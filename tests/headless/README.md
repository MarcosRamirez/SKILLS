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
  Nothing is written inside the repository's working tree.
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

## Writing a scenario

A scenario is a bash file in `scenarios/` that sets `SCENARIO_DESCRIPTION`, `SCENARIO_PROMPT`,
`SCENARIO_RUNS`, optionally `SCENARIO_ALLOWED_TOOLS` and `SCENARIO_QUESTION_TOOL` (`error`,
`no-answer` or `none`), and defines `scenario_setup DIR` and `scenario_checks DIR STREAM`. Each
assertion goes through `check "<name>" <command>`: the command prints its evidence and returns
0 or 1. Reusable assertions live in `lib.sh` (`assert_no_app_sources`, `assert_branch_files_only`,
`assert_file_contains`, `assert_skill_invoked`, `assert_no_command`, `assert_result_matches`).
Every run also checks that the copy under test was loaded and that the user files are unchanged.
