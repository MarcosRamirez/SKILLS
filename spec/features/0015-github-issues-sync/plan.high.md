# PLAN-0015: optional sync of specs and tasks to GitHub issues

Spec: [SPEC-0015](spec.md)
Status: Draft
Recommended overall: high — Claude Opus 5.5 (GitHub API integration with untrusted input)

## Context

Specs, tasks and plans stay in the repository; GitHub issues become an optional one-way mirror.
Builds on the automations catalog (`references/automations.md`), the `on-merge` workflow and
`close-specs.sh`. Read first: SPEC-0005 (on-merge), SPEC-0007 (plans), `references/release-automation.md`.

## Design

- **One-way mirror** keeps a single source of truth: specs, tasks and plans in the repo. The
  sync recomputes each issue from the files and overwrites title, body and labels.
- **Finding issues:** search by the hidden marker in the body (`gh issue list --search` or the API),
  never by title, which humans may edit.
- **Sub-issues:** check the official docs first (REST/GraphQL sub-issues API, `gh` support) and
  pin the approach in this design before writing the script.
- **State mapping:**

| Spec / plan state | Issue state | Label |
|---|---|---|
| Draft | open | `status:draft` |
| Approved / Ready | open | `status:approved` |
| In progress | open | `status:in-progress` |
| Implemented / Done | closed (by the bot) | `status:implemented` |

- **Where it runs:** `on-merge` (after `close-specs.sh`), and on demand by the AI after it writes
  a spec, plan or tasks. Disabled → the step exits before any API call.
- **Issue → spec:** reads the issue through `gh` into variables, writes a Draft spec whose Problem
  section quotes the issue, adds the marker to the issue, and links both ways.
- **Board:** created with `gh project` only when the user picks it; items added by the sync.

## Steps

### T-1 API research — high
- Recommended: high — Claude Opus 5.5 (choosing an API approach that holds up)
- Branch: `docs/0015-t1-api-research`
- Do: read the official docs for sub-issues (REST/GraphQL) and `gh project`; decide the calls; record them in design.md
- Files: ~ spec/features/0015-github-issues-sync/design.md
- Done when: every call the script needs is named, with its doc link

### T-2 sync-issues.sh — high
- Recommended: high — Claude Opus 5.5 (idempotency and untrusted input)
- Branch: `feat/0015-t2-sync-script`
- Do: write the template script (find by marker, create or update, labels, sub-issues); `DRY_RUN=1` mode; local tests against fixtures
- Files: + skills/senior-mindset/templates/github-issues/sync-issues.sh
- Done when: AC-1, AC-2 (simulated), AC-5 (disabled = no API call)

### T-3 on-merge and close-specs integration — medium
- Recommended: medium — Claude Sonnet 5.5 (wiring into existing automation)
- Branch: `feat/0015-t3-on-merge-integration`
- Do: run the sync after specs close when the option is enabled; close the parent issue on `Closes-Spec`
- Files: ~ templates/release-automation/on-merge.yml, ~ close-specs.sh, ~ repo workflow if enabled here
- Done when: AC-3 (simulated)

### T-4 Commands and catalog entry — medium
- Recommended: medium — Claude Sonnet 5.5 (settled design)
- Branch: `feat/0015-t4-commands`
- Do: `github-issues` entry in automations.md; enable/disable commands; issue → spec command; `Closes #` in task PR bodies (git.md)
- Files: ~ references/automations.md, ~ references/git.md, ~ SKILL.md, + references/github-issues.md
- Done when: AC-4, R-1

### T-5 Optional board — medium
- Recommended: medium — Claude Sonnet 5.5 (small, documented API)
- Branch: `feat/0015-t5-board`
- Do: create the board with `gh project` when chosen; the sync adds items and sets the status column
- Files: ~ sync-issues.sh, ~ references/github-issues.md
- Done when: R-7

### T-6 Real test on GitHub — high
- Recommended: high — Claude Opus 5.5 (debugging live API behaviour)
- Branch: `test/0015-t6-live-test`
- Do: create a throwaway repo; enable the option; run specs, tasks and PRs through it; check AC-1…AC-5; delete the repo
- Files: none in this repo (findings fixed in the scripts)
- Done when: AC-6

### T-7 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0015-t7-release`
- Do: minor bump, READMEs, inventory, changelogs; PR body with `Closes-Spec: SPEC-0015`
- Files: ~ plugin.json, ~ READMEs, ~ CHANGELOGs
- Done when: the bot closes spec and plan; `claude plugin update`

## Verification

Dry-run tests for idempotency and disabled mode; live test on a throwaway repo for closes and the board; `claude plugin validate --strict`.

## Risks

- API rate limits on large backlogs → batch and skip unchanged issues.
- Humans editing mirrored issues → documented as overwritten; comments are kept.
- Untrusted issue content → env vars only; marker regex validated.

## Out of scope

Two-way sync; other trackers.
