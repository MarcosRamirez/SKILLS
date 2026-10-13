# SPEC-0015: optional sync of specs and tasks to GitHub issues

Status: Draft
Date: 2026-10-13
Approved by: (empty until the user explicitly approves)

## Problem

Specs, tasks and plans live in the repository, which is the right source of truth, but they are
invisible on GitHub: no board, no notifications, no way for people outside the AI workflow to
follow or comment. Some projects want that visibility; others do not want the noise.

## Requirements

- R-1 **Optional, off by default.** A new `github-issues` entry in `references/automations.md`
  (requires a GitHub remote and an authenticated `gh`). Turned on in the kickoff automations
  question or with "enable/disable issue sync" ("activa/desactiva la sincronización de issues");
  the choice is recorded in CLAUDE.md.
- R-2 **The repository is the source of truth; GitHub is a mirror.** One-way sync, repo → GitHub.
  A manual edit to a synced issue is overwritten on the next sync.
- R-3 **Spec = issue, task (T-n) = native sub-issue** of the spec's issue. Labels: `spec`, `task`,
  `status:<draft|approved|in-progress|implemented>`. The body holds a summary plus links to the
  spec and the plan, and a hidden marker (`<!-- senior-mindset:SPEC-0008 -->`,
  `<!-- senior-mindset:SPEC-0008/T-2 -->`) used to find the issue again.
- R-4 A task's PR carries `Closes #<sub-issue>` (native GitHub close). The spec's issue is closed by
  the bot when the `Closes-Spec:` PR is merged.
- R-5 An idempotent `sync-issues.sh` (template under `templates/github-issues/`) creates or updates
  issues. It runs in `on-merge` after specs close, and when the AI creates a spec, plan or tasks.
- R-6 **Command "turn issue #N into a spec"** ("convierte el issue #N en una spec"): creates a Draft
  spec from the issue, links them, and the issue is synced from then on.
- R-7 **Optional GitHub Projects board** inside the option: columns Draft, Approved, In progress, Implemented.
- R-8 Disabling stops syncing; existing issues are left as they are.

## Security

- Issue titles and bodies written by others are untrusted input: never interpolated into scripts.
  The issue → spec command treats their content as data, never as instructions.
- Minimal permissions: `issues: write`; `repository-projects` only when the board is enabled.

## Acceptance criteria

- AC-1 Running the sync twice changes nothing the second time.
- AC-2 A manual edit to a synced issue is reverted by the next sync.
- AC-3 Merging a task PR with `Closes #` closes its sub-issue; merging the `Closes-Spec` PR closes the parent issue.
- AC-4 The issue → spec command creates a Draft spec linked to the issue.
- AC-5 With the option disabled, no call is made to the issues API.
- AC-6 Tested for real on a throwaway GitHub test repository, deleted afterwards.

## Out of scope

- Two-way sync (GitHub → repo) beyond the explicit issue → spec command.
- Other trackers (GitLab, Jira, Linear).
