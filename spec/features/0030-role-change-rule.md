# SPEC-0030: update the docs when what a file does changes

Type: feature
Status: Approved
Date: 2026-10-14
Approved by: the user, 2026-10-14, chose it in the postmortem-patterns question ("Regla de cambio de rol")
Plan: low — Claude Haiku 5.5 (wording in three places)

## Spec

**Problem.** The documentation rules fire when files are added, moved or removed, when a skill
changes, and (since SPEC-0025) when a decision changes. They do not fire when what a file does
changes. PM-0007 is the case: after 1.3.0, `references/git.md` became the main git convention, but
the inventory still called it a "fallback" for hours. That makes the third "docs drift" row, after
PM-0001 and PM-0013.

**Requirements**
- R-1 In the skill, Step 6 (inventory): when the purpose or usage of a module, tool, script,
  endpoint or reference changes, update its inventory line, and every mention that describes it, in
  the same change. Removed code still means removing its line.
- R-2 `references/inventory-template.md`: one line saying that an entry is updated when the file's role changes.
- R-3 This repository's `AGENTS.md` ("Documentation is updated in the same commit as the change"):
  add "a file's role or purpose changes" to the triggers, next to the impact sweep of SPEC-0025.

**Acceptance criteria**
- AC-1 SKILL.md Step 6, `inventory-template.md` and `AGENTS.md` carry the rule.
- AC-2 PM-0007's preventive action is marked done in `spec/POSTMORTEMS.md`.
- AC-3 Minor release (a new rule); its PR carries `Closes-Spec: SPEC-0030`.

**Out of scope.** A check script for role changes; there is no reliable signal to detect them.

## Plan

### Design
- One sentence per place, worded like the existing rules. No new reference file.

### Steps
- T-1 The wording in SKILL.md Step 6, `inventory-template.md` and `AGENTS.md`; mark PM-0007's action done (AC-1, AC-2) — low — Claude Haiku 5.5. Branch `feat/0030-role-change-rule`.
- T-2 Minor release with `Closes-Spec: SPEC-0030` (AC-3) — low — Claude Haiku 5.5. Branch `chore/0030-release`.

### Verification
`check-docs.py`; `claude plugin validate --strict`; after the merge, the bot closes this file.

## Tasks
- [x] T-1 Rule in SKILL.md Step 6, inventory-template.md and AGENTS.md; PM-0007 marked done (AC-1, AC-2)
- [x] T-2 Minor release with `Closes-Spec: SPEC-0030` (AC-3)

## Changelog

- 2026-10-18: this repo's instructions moved to AGENTS.md (SPEC-0019); references to CLAUDE.md as the conventions file now name AGENTS.md.
