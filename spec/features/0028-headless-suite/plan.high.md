# PLAN-0028: a committed headless suite, run before every release

Spec: [SPEC-0028](spec.md)
Status: Done
Done: 2026-10-19, PR #79
Recommended overall: high — Claude Opus 5.5 (test design, isolation of the user's machine, deterministic checks of model behaviour)

## Context

Each step so far wrote one-off headless runs in the scratchpad: SPEC-0003, 0016 T-2, 0026 T-3,
0025 T-3 and 0027 T-3. They are the starting point; reuse their setups and checks. The register
(`spec/POSTMORTEMS.md`) lists the gaps each scenario closes.

## Design

- **Layout:** `tests/headless/run.sh`, `tests/headless/lib.sh` (shared helpers: build a scratch repo,
  run claude, parse the stream with Python, assert, hash the user files), and
  `tests/headless/scenarios/<name>.sh`, one per R-1 item.
- **Checks:** files and their contents (grep), the git log and branches, and stream-json events
  (tool_use names and inputs, permission_denials). Never "ask a model if it looks right".
- **Isolation:** run in `acceptEdits` with `--allowedTools` limited to what each scenario needs.
  Hash user-level files before and after. T-1 tries `HOME`/`USERPROFILE` pointed at a temp folder
  with the credentials kept working, and documents the result.
- **Skill references readable:** pass `--add-dir <skills/senior-mindset>` to every run. Without it,
  headless runs are denied reads outside the project, so the skill's `references/` are never opened
  (seen in SPEC-0019 T-2).
- **User plugins:** run with `--setting-sources project,local` by default, so user-level hooks
  (e.g. a terse-style plugin) do not change the results. One scenario may run with the user's real
  setup, as a separate check (SPEC-0019 T-2, case b).
- **Cost control:** the default is 1 run per scenario, and N=3 for trigger and question scenarios.
  `--only <name>` runs one scenario. The summary shows the model and the Claude Code version.

## Steps

### T-1 Runner, helpers and isolation — high
- Recommended: high — Claude Opus 5.5 (isolation decisions)
- Branch: `test/0028-t1-runner`
- Do: run.sh, lib.sh, user-file hashing, the isolated-HOME experiment; one scenario (the approval gate) end to end
- Done when: AC-4 for that scenario

### T-2 Scenarios — medium
- Recommended: medium — Claude Sonnet 5.5 (port the existing one-off runs)
- Branch: `test/0028-t2-scenarios`
- Do: the remaining R-1 scenarios, reusing the scratchpad setups of earlier steps
- Done when: AC-1

### T-3 Full run and the broken-copy check — high
- Recommended: high — Claude Opus 5.5 (judging failures)
- Branch: `test/0028-t3-full-run`
- Do: run everything on the current skill and record it (AC-2); run the gate scenario on a broken copy (AC-3); file a fix spec or a register row for each real failure
- Done when: AC-2, AC-3

### T-4 Release step integration — low
- Recommended: low — Claude Haiku 5.5 (wording)
- Branch: `docs/0028-t4-release-step`
- Do: AGENTS.md release step and the release PR body template run the suite; INVENTORY lines. The PR body carries `Closes-Spec: SPEC-0028`. No skill version moves if nothing under `skills/` changed.
- Done when: AC-5; the bot closes the spec

## Verification

The full run summary, the broken-copy failure, and the hash proof.

## Risks

- Model variance makes checks flaky → N runs, and checks on outcomes (no merge, no code) rather
  than on exact wording.
- Cost → it runs before releases only, with `--only` for quick checks.
- Login breaks with an isolated HOME → fall back to `acceptEdits` plus hash checks.

## Out of scope

Model-judged checks; running on every pull request.
