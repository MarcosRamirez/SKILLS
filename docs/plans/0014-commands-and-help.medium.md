# PLAN-0014: documented commands, help and status

Spec: [SPEC-0014](../specs/0014-commands-and-help/spec.md)
Status: Draft
Recommended overall: medium — Claude Sonnet 5.5 (documentation plus small read-only behaviours)

## Context

Commands exist today as phrases scattered across `SKILL.md`, `setup.md`, `plans.md` and `versioning.md`.
This plan gathers them into one documented list, adds help, status and list plans, and checks
whether plugins can expose slash aliases.

## Steps

### T-1 commands.md and links — medium
- Recommended: medium — Claude Sonnet 5.5 (collecting and documenting what exists)
- Branch: `feat/0014-t1-commands-reference`
- Do: write the commands table (phrases EN/ES, effect, example, source); add a short "Commands" section to `SKILL.md`; list commands in the skill README
- Files: + references/commands.md, ~ SKILL.md, ~ skills/senior-mindset/README.md, ~ docs/INVENTORY.md
- Done when: AC-1

### T-2 help, status, list plans — medium
- Recommended: medium — Claude Sonnet 5.5 (read-only behaviours, clear spec)
- Branch: `feat/0014-t2-help-status`
- Do: define each behaviour in commands.md (read-only, no kickoff); headless tests with `--plugin-dir`: "¿qué puedes hacer?" in an empty folder, "status" in this repo
- Files: ~ references/commands.md, ~ SKILL.md
- Done when: AC-2, AC-3 (status output matches the spec and plan files)

### T-3 Slash aliases — medium
- Recommended: medium — Claude Sonnet 5.5 (docs check + small manifest change)
- Branch: `feat/0014-t3-slash-aliases`
- Do: check the official plugin docs for shipping commands; if supported, add thin aliases (help, status, plans); validate the plugin
- Files: maybe + skills/senior-mindset/commands/*.md, ~ plugin docs
- Done when: AC-4

### T-4 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0014-t4-release`
- Do: minor bump, READMEs, changelogs; PR body with `Closes-Spec: SPEC-0014`
- Files: ~ plugin.json, ~ SKILL.md frontmatter, ~ CHANGELOGs
- Done when: the bot closes spec and plan; `claude plugin update`

## Verification

Headless runs for help and status; status cross-checked against `grep ^Status` of specs and plans; `claude plugin validate --strict`.

## Risks

Help triggering the kickoff or the approval flow → read-only commands are explicitly exempt.
Status relying on `gh` → degrade gracefully when `gh` is missing or there is no remote.

## Out of scope

New behaviours beyond help, status and list plans.
