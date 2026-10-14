# PLAN-0016: closed questions with clickable answers

Spec: [SPEC-0016](spec.md)
Status: In progress
Recommended overall: low — Claude Haiku 5.5 (a short, well-defined rule)

## Context

`AskUserQuestion` already renders a question with clickable options and a free-text "Other" field.
The skill must require it for every closed question. Read first: SPEC-0003 (approval gate), SPEC-0013 (portability).

## Design

- The rule goes among the always-on rules in `SKILL.md`, because it applies to every interaction, scripts included.
- Detail and examples live in a short reference (`references/questions.md`), or in `references/commands.md`
  if SPEC-0014 lands first: format, good and bad examples, fallback.
- **Example (yes/no):**

```text
Question: PR #30 is green. Merge it?
  [Yes, merge (Recommended)]  merge commit, branch deleted
  [No, not yet]               leave it open for review
  Other: ______               type any other answer
```

- **Bad:** "Do you want me to merge it?" as plain text at the end of a message.
- The question tool's own limits apply: 1–4 questions per call, 2–4 options each.

## Steps

### T-1 Rule and reference — low
- Recommended: low — Claude Haiku 5.5 (wording a settled rule)
- Branch: `feat/0016-t1-clickable-answers-rule`
- Do: add the rule to the always-on rules in `SKILL.md`; write `references/questions.md` with format, good and bad examples, fallback
- Files: ~ SKILL.md, + references/questions.md, ~ skills/senior-mindset/README.md, ~ spec/INVENTORY.md
- Done when: AC-1

### T-2 Tests — medium
- Recommended: medium — Claude Sonnet 5.5 (checking real behaviour in two modes)
- Branch: `test/0016-t2-question-tests`
- Do: interactive session in a test repo ending in "merge it?" → buttons + free-text field; headless run with `--plugin-dir` → numbered fallback, no decision taken
- Files: wording fixes if needed
- Done when: AC-2, AC-3

### T-3 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0016-t3-release`
- Do: minor bump, READMEs, changelogs; PR body with `Closes-Spec: SPEC-0016`
- Files: ~ plugin.json, ~ SKILL.md frontmatter, ~ CHANGELOGs
- Done when: the bot closes spec and plan; `claude plugin update`

## Verification

Interactive check by the user (it is a UI behaviour); headless fallback check; `claude plugin validate --strict`.

## Risks

Over-using buttons for open questions → R-3 says open questions stay as text.

## Out of scope

Plan-mode approval mechanism.
