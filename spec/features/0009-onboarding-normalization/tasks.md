# SPEC-0009 tasks

One branch per task, stacked PRs. Executed through PLAN-0009.

- [x] T-1 `references/onboarding.md`: state detection, pipeline, mapping, ASSESSMENT template (AC-1)
- [x] T-2 `SKILL.md`: first-use-in-project step that runs onboarding before kickoff
- [x] T-3 Headless scenario on a synthetic documentation project (AC-2)
- [ ] T-4 Headless scenario on a synthetic code repository, every inventory entry checked (AC-3, AC-4)
- [ ] T-5 Release (minor), docs, changelogs; last PR carries `Closes-Spec: SPEC-0009`

## Test results (T-3, 2026-10-19)

Scenario `onboarding-docs` (Claude Code 2.1.303, `claude-opus-5-5`, 1.91 USD): a synthetic docs-only
repository with spec-kit specs and constitution, an ADR folder without `Status:` lines, a PRD and
loose notes. Everything was approved in the prompt. PASS 8/8.

- Branches `docs/0002-adopt-senior-mindset`, then stacked `docs/0002-t1-migrate-layout`,
  `docs/0002-t2-constitution` and `docs/0002-t3-agents-md`; `master` untouched.
- `spec/ASSESSMENT.md` and `spec/features/0002-adopt-senior-mindset/` (the spec-kit feature took 0001,
  the older document). The mapping table has one row per source file: the ADR and the three spec-kit
  files moved (`Status:` and `Type:` lines added, tier marked "to confirm"), the PRD, the spec-kit
  constitution and the notes split with their originals in `spec/archive/` (indexed in its README),
  and the README kept with its links updated.
- The spec-kit feature stays `Draft` (no code implements it); the mission comes from the PRD's vision
  with its line cited; the roadmap keeps the unspecified ideas as a backlog.
- `git diff -M --diff-filter=D master <branch>` is empty on every branch.
