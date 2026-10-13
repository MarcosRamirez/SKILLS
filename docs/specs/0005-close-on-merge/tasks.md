# SPEC-0005 tasks

Stacked PRs, merged in order by the user. Status becomes Implemented by the bot on merge.

- [ ] T-1 Workflow + scripts + `CLAUDE.md` rules (AC-1, AC-2, AC-3) — test: scripts on a scratch clone — branch `feat/0005-t1-on-merge-workflow`
- [ ] T-2 senior-mindset: `release-automation.md`, `sdd.md`, `versioning.md`, `git.md`, `SKILL.md` (AC-4) — branch `feat/0005-t2-skill-release-automation`
- [ ] T-3 Release 1.5.0, PR body with `Closes-Spec: SPEC-0005` (AC-5) — branch `chore/0005-t3-release-1-5-0`

Post-merge checks (in the release PR body, not tasks): Action green, bot commit, tag, Release, `claude plugin update`.
