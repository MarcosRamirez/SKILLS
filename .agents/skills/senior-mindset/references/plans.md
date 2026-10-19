# Plans: how a spec gets executed

- **spec** = what and why;
- **tasks** = the list of work;
- **plan** = how: the technical design and the execution steps, written for whoever runs it
  (a person or an agent), with the agent and model each step needs.

## Naming

The plan lives **inside its spec folder** as `plan.<tier>.md`:

```text
spec/features/0008-existing-project-safety/
  spec.md
  plan.high.md      ← PLAN-0008
  tasks.md
```

In a single-file spec (a small feature, `spec/features/NNNN-<slug>.md`, or a fix,
`spec/fixes/NNNN-<slug>.md`), the plan is its `## Plan` section, and the tier goes in a `Plan:`
line under the status.

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

1. Read the spec, `spec/features/X-*` or `spec/fixes/X-*` (folder: `spec.md` + `plan.*.md`; or the single file).
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

Spec: [SPEC-NNNN](spec.md)
Status: Draft
Recommended overall: <tier> — <agent / model from models.md> (why)

## Context
What exists today, what the spec needs, decisions already taken, what to read first.

## Design
The technical how: decisions (project-wide ones link to their ADR), components (reuse what
spec/INVENTORY.md lists first), data, API (spec/api/openapi.yaml), security, observability,
edge cases, templates.

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

## Plans for fixes

A fix is a single file, so its plan is the `## Plan` section of `spec/fixes/NNNN-<slug>.md`. Only a
large fix, in a folder, has a `plan.<tier>.md`. The lifecycle and "run plan X" work as for
features. The fix template is in [sdd.md](sdd.md); what changes is the content:

- **`### Design` is the root cause and the fix:** where and why it breaks, the smallest change that
  fixes it, the components touched (reuse what `spec/INVENTORY.md` lists first) and what must not
  move (the unchanged behaviour).
- **Steps follow the fix flow:** reproduce with a failing test → root cause → fix. Branches are
  `fix/NNNN-tN-<slug>`.
- **Tiers:** the root cause of a hard failure is high-tier work (debugging, see
  [models.md](models.md)); reproducing the bug and writing the fix are usually medium.
- **`### Verification`:** the reproducing test fails before the fix and passes after it, and the
  unchanged-behaviour tests stay green.
