# Plans: how a spec gets executed

- **spec** = what and why;
- **tasks** = the list of work;
- **plan** = how to execute it, step by step, written for whoever runs it (a person or an
  agent), with the agent and model each step needs.

## Naming

`docs/plans/NNNN-<slug>.<tier>.md`, with the **same number and slug as its spec**:

```text
docs/specs/0008-existing-project-safety/   ←→   docs/plans/0008-existing-project-safety.high.md
```

- `<tier>` is the plan's overall tier: `high`, `medium` or `low` (see [models.md](models.md)).
  It is repeated inside the file. Individual steps may carry their own tier.
- "Plan 0008", `PLAN-0008` and `SPEC-0008` refer to the same piece of work.
- If the overall tier changes, rename with `git mv` and fix the links.

## When it is written

After the spec is approved, before any implementation, and as part of what the user approves.
For small specs the plan can be short, but it always exists: it is what "run plan X" executes.

## Lifecycle

`Draft` (spec still Draft, plan proposed) → `Ready` (spec approved, plan approved with it) →
`In progress` (execution started) → `Done`.

**`Done` is set by the bot**, never by hand. When the PR carrying `Closes-Spec: SPEC-NNNN` is
merged, `close-specs.sh` marks the spec Implemented and its plan `Done`
([release-automation.md](release-automation.md)). Without the automation, set it in the next PR.

## "Run plan X" / "ejecuta el plan X"

1. Read `docs/plans/X-*.md` and its spec.
2. **Approval gate:** if the spec is still `Draft`, show spec and plan and ask for explicit approval first
   (Hard rules). On approval, set the spec to `Approved` (with `Approved by:`) and the plan to `Ready`.
3. Set the plan to `In progress` on the first work branch.
4. Execute the steps in order: one branch per task, a commit per significant change, PRs (stacked when dependent).
5. The last PR carries `Closes-Spec: SPEC-X`. The user merges, and the bot closes spec and plan.
6. If a step's recommended tier is above the current model, say so before starting
   ("step 2 recommends high; you are on a medium-tier model — continue or switch?").

## Template

```markdown
# PLAN-NNNN: <title>

Spec: [SPEC-NNNN](../specs/NNNN-<slug>/spec.md)
Status: Draft
Recommended overall: <tier> — <agent / model from models.md> (why)

## Context
What exists today, what the spec needs, decisions already taken, what to read first.

## Steps

### T-1 <title> — <tier>
- Recommended: <tier> — <agent / model> (why)
- Branch: `<type>/NNNN-t1-<slug>`
- Do: concrete actions, in order
- Files: created / modified / removed
- Commands: what to run (with expected output when it matters)
- Done when: the ACs this step covers, and how they are checked

### T-2 …

## Verification
How each AC is proven: tests, headless runs, checks, post-merge checks.

## Risks
What can go wrong, how we would notice, how to roll back.

## Out of scope
```
