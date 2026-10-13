# SPEC-0016 design

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
