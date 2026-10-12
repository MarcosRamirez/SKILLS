# SPEC-0003 design

- **Position matters.** A rule in the middle of a long SKILL.md loses against the momentum
  of "finish the task". The gate moves to the top as "Hard rules", short and absolute,
  and Step 3 refers back to it.
- **Name the exact failure.** The model rationalized "questions skipped → choose defaults".
  The rule names this case and forbids it: no answer means no decision, and no decision
  means no code.
- **Give a productive stop.** Without approval, the skill still produces value it is allowed
  to produce: Proposed ADRs, a Draft spec with all three files, and the kickoff checklist
  minus code. It commits them on a branch and ends with numbered questions. Stopping with a
  deliverable beats stopping empty, which is what tempted the model to keep going.
- **Test loop:** disable the installed plugin, run `claude -p --plugin-dir skills/senior-mindset`
  in an empty scratch folder, inspect the files, re-enable the plugin. Iterate until AC-2 passes.
