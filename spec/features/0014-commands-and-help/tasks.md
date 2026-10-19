# SPEC-0014 tasks

One branch per task, stacked PRs. Executed through PLAN-0014.

- [x] T-1 `references/commands.md` + "Commands" section in `SKILL.md` + README (AC-1)
- [x] T-2 help, status and list plans behaviour, any language; headless tests (AC-2, AC-2b, AC-3)
- [x] T-2b Welcome message with the help summary (AC-2c)
- [x] T-3 Slash-command aliases, if supported by the official docs (AC-4)
- [ ] T-4 Release (minor), changelogs; last PR carries `Closes-Spec: SPEC-0014`

## Results

Real runs on claude-opus-5-5, Claude Code 2.1.303, 2026-10-19 (the headless suite, `--only`).

| Scenario | Run | Result | Cost (USD) |
|---|---|---|---|
| `help-languages` | 1 es "¿qué puedes hacer?" | PASS, 10/10 | 0.23 |
| `help-languages` | 2 en "what can you do?" | PASS, 10/10 | 0.22 |
| `help-languages` | 3 fr "qu'est-ce que tu sais faire ?" | PASS, 10/10 | 0.22 |
| `status` | 1 (first) | FAIL 14/15: the check flagged read-only `git branch -a` and `git tag`; the skill behaved. Check fixed | 0.32 |
| `status` | 2 (after the fix) | PASS, 15/15 | 0.33 |

Total 1.32 USD, no SKIPPED. T-2b has no scenario: the welcome belongs to the interactive first-use
setup, which a headless run skips by design (setup.md section 6).

**T-3 decision:** no slash aliases; the skill is already invocable by name, and aliases would need
a Claude Code-only folder. Reasons and doc links in `plan.medium.md` (Design, "Slash aliases").
