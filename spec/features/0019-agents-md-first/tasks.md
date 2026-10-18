# SPEC-0019 tasks

One branch per task, stacked PRs. Executed through PLAN-0019.

- [x] T-1 References and SKILL.md: AGENTS.md as the conventions file, case table, safety rule (AC-1)
- [ ] T-2 Merge behaviour and six headless tests (AC-2). Merge procedure written; 5 of 6 cases
  pass, case b (only `CLAUDE.md`) does not, see the results below. Left open for the user to decide
- [ ] T-3 Migrate this repo, update SPEC-0013 (AC-3, AC-4)
- [ ] T-4 Release (minor) with `Closes-Spec: SPEC-0019`

## Test results (T-2, 2026-10-18)

**Setup.** Six scratch git repos on `master`, built by a script:

- a: an empty repo.
- b to f: the same small Python library (`src/agenda/events.py`, one pytest test, `spec/` with the
  constitution, ADR-0001 and `spec/INVENTORY.md`), with the instruction files of each case:
  - b: only `CLAUDE.md`, with conventions plus a `## Claude Code` item;
  - c: only `AGENTS.md`;
  - d: both files, three conflicts (default branch `master`/`main`, pytest/unittest, docstrings),
    one rule only in `CLAUDE.md` (logging), two only in `AGENTS.md` (ruff, dates) and a Claude Code hook note;
  - e: `AGENTS.md` and a `CLAUDE.md` holding only `@AGENTS.md`;
  - f: `AGENTS.md` and a git-ignored `CLAUDE.local.md` without the import.

Each run:

```text
claude -p "<prompt>" --plugin-dir D:/Code/Projects/SKILLS/skills/senior-mindset
  --output-format stream-json --verbose --permission-mode acceptEdits
  --allowedTools "Bash(git:*)" --no-session-persistence
```

- Prompt for a: "Create a tiny Python CLI that greets the user; use the senior-mindset kickoff. Do
  not edit files outside this folder."
- Prompt for b to f: "Add a function that formats an event's start date as YYYY-MM-DD to the agenda
  package, following the project conventions. Use senior-mindset. Do not edit files outside this folder."

A script checked each run:

- each instruction file against its baseline, in the tree and on every branch (`git show <branch>:<file>`);
- branches and `git log --all`;
- which skill loaded, permission denials, and key phrases in the final answer.

The skill loaded (`senior-mindset:senior-mindset`, the `--plugin-dir` copy) in all 15 runs. Every
run exited 0, and none had a permission denial.

**Wording fixes between runs** (each followed by a re-run of the failing cases only):

1. `365f1a8`, after run 1:
   - Step 1 checks `AGENTS.md`, `CLAUDE.md`, `.claude/CLAUDE.md` and `CLAUDE.local.md` every session,
     and names the proposal for each case. Before, `agents-md.md` was named only inside a clause about
     an existing `CLAUDE.md`.
   - Step 0 counts any request for the kickoff, a spec or a project as a project.
2. `b98535b`, after run 2: the check moves to the top of Step 1 as a three-item list, and hard rule 3's
   headless final message includes any proposal from Step 1.
3. `c08f9b8`, after run 3: Step 1 says to read `agents-md.md` and show its change notice, because a
   one-line remark is not a proposal.

### a. New empty project

| Run | Skill at | Expected | Observed | Pass |
|---|---|---|---|---|
| 1 | `5e2fa73` | `AGENTS.md` written (Draft docs on a `docs/` branch), no `CLAUDE.md` | Script fast path: an untracked `greet.py`, no `AGENTS.md`, no branch, no commit | No |
| 2 | `365f1a8` | same | `docs/kickoff`, one commit, `master` unborn. `AGENTS.md` has `## Engineering conventions` marked proposed and the Git rules block. Also ADR-0001/0002, the constitution, `spec/INVENTORY.md` and SPEC-0001 Draft (spec, plan, tasks). No `CLAUDE.md` in the tree or on any branch | Yes |

### b. Only CLAUDE.md

| Run | Skill at | Expected | Observed | Pass |
|---|---|---|---|---|
| 1 | `5e2fa73` | Migration to `AGENTS.md` proposed with a change notice; nothing migrated | `CLAUDE.md` unchanged everywhere, no `AGENTS.md`; Draft spec on `docs/0001-format-start-date`; no mention of `AGENTS.md` | No |
| 2 | `365f1a8` | same | Ran `ls -a` and saw `CLAUDE.md`; same result, no mention | No |
| 3 | `b98535b` | same | Closing line only: "The skill suggests moving it to `AGENTS.md`. I left it alone, since you told me to follow the project conventions as written." No change notice, no question. `CLAUDE.md` unchanged | Partial |
| 4 | `c08f9b8` | same | No mention; `CLAUDE.md` unchanged | No |

### c. Only AGENTS.md

| Run | Skill at | Expected | Observed | Pass |
|---|---|---|---|---|
| 1 | `5e2fa73` | No `CLAUDE.md` created | No `CLAUDE.md` in the tree or on any branch; `AGENTS.md` unchanged; Draft spec on a `docs/` branch | Yes |

### d. Both files, different and partly contradicting

| Run | Skill at | Expected | Observed | Pass |
|---|---|---|---|---|
| 1 | `5e2fa73` | Warning that Claude reads only `CLAUDE.md`, a merge proposal, no file touched | Both files unchanged; listed the four contradictions and asked "which convention file wins?"; no warning, no merge proposal | No |
| 2 | `365f1a8` | same | "`AGENTS.md` and `CLAUDE.md` disagree, and Claude only reads `CLAUDE.md`", a conflicts table, and "a separate change that makes `AGENTS.md` the single source and has `CLAUDE.md` import it with `@AGENTS.md`"; both unchanged | Yes |
| 3 | `b98535b` | same | "Claude Code reads only `CLAUDE.md`", a conflicts table with both versions, "I propose merging them into one `AGENTS.md`, with `CLAUDE.md` reduced to `@AGENTS.md` plus the Claude-only hook note. I need your answer on each conflict first, and I haven't changed either file"; both unchanged | Yes |
| 4 | `c08f9b8` | same | "Claude Code reads only `CLAUDE.md`. senior-mindset would have me merge them into one file, but nothing changes until you pick", conflicts table; both unchanged | Yes (weaker wording) |

### e. Both files, CLAUDE.md is `@AGENTS.md`

| Run | Skill at | Expected | Observed | Pass |
|---|---|---|---|---|
| 1 | `5e2fa73` | Nothing to migrate, nothing touched | Both files unchanged on every branch, no proposal; Draft spec on a `docs/` branch | Yes |

### f. AGENTS.md plus CLAUDE.local.md without the import

| Run | Skill at | Expected | Observed | Pass |
|---|---|---|---|---|
| 1 | `5e2fa73` | Proposes adding `@AGENTS.md` to `CLAUDE.local.md` | No mention; `CLAUDE.local.md` unchanged | No |
| 2 | `365f1a8` | same | No mention, although its Glob call listed `CLAUDE.local.md` | No |
| 3 | `b98535b` | same | "`CLAUDE.local.md` doesn't start with `@AGENTS.md`. Want me to add that line so Claude reads the project conventions from it? I haven't changed it." File unchanged | Yes |

**Summary.** On the last run of each case, a, c, d, e and f pass, and b fails. AC-2 is not fully met.

**What the runs show**

- No run changed an instruction file, in the tree or on any branch: nothing was migrated or merged
  silently.
- **No run opened `references/agents-md.md`** (0 tool calls in 15 runs). The merge procedure's change
  notice ("Kept from CLAUDE.md / Kept from AGENTS.md / Conflicts") and its one question per conflict
  never appeared. The d proposals come from the summary in SKILL.md Step 1. The procedure is
  written, but no headless run has exercised it.
- Every run started with the user's caveman plugin SessionStart hook ("CAVEMAN MODE ACTIVE … respond
  terse"). That pushes answers to drop side notices, and it is a likely factor in case b.
- `AskUserQuestion` was never called (headless); questions came as numbered text.

**Limits**

- One run per case per wording version, one model (`claude-sonnet-5-5`, the CLI default) and Claude
  Code 2.1.302, headless only.
- The user's real plugins and hooks were active.
- The prompts named senior-mindset, so triggering was not tested.
- Not re-run after the later fixes: c and e (after fixes 1 to 3), a (after fixes 2 and 3) and f (after fix 3).
- Total model cost: 2.96 USD over 15 runs.

**File protection.** `~/.claude/senior-mindset.md` was copied to the scratch folder before the runs.
Its SHA-256 was `e2245cbe…905941` before the runs, after each of the 15 runs and at the end, and
`cmp` with the backup reported the files identical, so nothing was restored. Nothing under
`~/.claude/` was edited on purpose. Claude Code itself created empty `projects/<scratch path>/memory/`
folders for the six case paths, and the caveman hook rewrote its own `.caveman-active` flag (content
`full`). The raw streams (`streams/*.jsonl`), the per-run checks and the scripts stay in the scratch
folder `0019-t2/`.

**Open for case b.** Two ways forward:

- Re-test b without the user's plugins (`--setting-sources project`) or interactively.
- Make the check deterministic, for example a SessionStart hook that prints the instruction-file
  case. That needs its own decision.
