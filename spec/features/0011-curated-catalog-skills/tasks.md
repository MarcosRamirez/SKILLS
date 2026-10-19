# SPEC-0011 tasks

One branch per task, stacked PRs. Executed through PLAN-0011.

- [x] T-0 Decide the open question with the user: project scope by default, skills in
  `.agents/skills/` with a Claude Code bridge (decided 2026-10-13; R-8, ADR-0005)
- [x] T-1 Criteria (`references/catalog.md`) + schema + validation script + CI step (AC-1, AC-2)
- [ ] T-2 Build the initial lists **with the user**: ask for their skills and MCPs, propose researched
  candidates, approve entry by entry, record rejections (AC-1, AC-1b). Context7 is already
  approved (AC-1c), so it is not asked again
- [ ] T-3 Vetted third-party skills installable with `npx skills`; marketplace listing optional (AC-4)
- [ ] T-4 Skill management flow in `SKILL.md`; headless test (AC-3)
- [ ] T-5 Release (minor), docs, changelogs; last PR carries `Closes-Spec: SPEC-0011`
