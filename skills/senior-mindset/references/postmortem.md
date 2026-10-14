# Postmortem for every bug

A bug that is fixed but not understood comes back. Every fixed bug gets a short, blameless
postmortem and one row in the register `spec/POSTMORTEMS.md`. The goal is not the story of the
bug: it is the guard that stops the next one.

## Method

Five established practices, each doing one job:

- **Blameless postmortem** ([Google SRE, "Postmortem Culture"](https://sre.google/sre-book/postmortem-culture/)):
  records what happened, the impact, the root cause, how it was detected and resolved, and the
  follow-up actions. It looks at the system, not at who made the mistake.
- **5 Whys** (Toyota Production System): ask "why?" until the answer is a cause you can act on,
  not the symptom.
- **CAPA** (corrective and preventive action, ISO 9001): the corrective action fixes this case; the
  preventive action (a test, a check, a rule) stops the kind of bug from happening again.
- **Known error register** (ITIL problem management): one place that lists known problems with their
  cause, so the next session does not rediscover them.
- **Defect classification** (e.g. IBM's Orthogonal Defect Classification): one category per bug, so
  patterns show up when the rows are counted.

## When

- **Every bug that is fixed**, with or without a spec.
- A fix with a spec: the `## Postmortem` section inside the fix spec ([sdd.md](sdd.md)), plus the register row.
- A trivial fix without a spec: only the register row. Its link is the commit.
- Write it in the same branch as the fix, after the root cause is known. The row's prevention
  status is updated when a pending action is done.
- A vulnerability's postmortem stays private until the fix is released, like its spec.

## Read the register

Like `spec/INVENTORY.md`, read `spec/POSTMORTEMS.md` when loading context:

- **before writing a spec**, so known failure modes are designed out;
- **when reviewing a change**, to check it does not repeat a known cause;
- **when preparing a release**, so pending preventive actions are not forgotten.

## Template: `## Postmortem` in a fix spec

Placed after `## Spec` and before `## Plan`.

```markdown
## Postmortem

**Impact.** Who or what was affected, and for how long.
**5 Whys.**
1. Why <symptom>? → because <cause>.
2. Why <cause>? → because <deeper cause>.
3. … (stop at a cause you can act on)
**Why it was not caught.** The missing test, check, review step or rule that would have stopped it.
**Corrective action.** The fix (this spec).
**Preventive actions.**
- [x] <action> (where: test / check / rule / doc)
- [ ] <action> (SPEC-NNNN)
```

Worked example:

```markdown
## Postmortem

**Impact.** Every export since 1.4.0 (6 days) dropped the last row of each page; two customers
reported missing invoices.
**5 Whys.**
1. Why were rows missing? → the cursor skipped the row at each page boundary.
2. Why did it skip? → the query used `id > last_id` on a column sorted by `created_at`.
3. Why was the sort different? → the pagination helper was copied from another endpoint without
   its ordering rule.
4. Why was the rule not visible? → it lives in a comment, not in a test or a type.
**Why it was not caught.** Tests used pages of one row; no test crossed a page boundary.
**Corrective action.** Sort and filter on the same key (this spec).
**Preventive actions.**
- [x] Pagination test with three pages and a duplicate timestamp (where: tests/export.test.ts)
- [ ] Single shared pagination helper in the inventory (SPEC-0031)
```

## Template: the register `spec/POSTMORTEMS.md`

Created at the first bug. Link it from CLAUDE.md next to the inventory.

```markdown
# Postmortems

One row per bug that was fixed, newest last. The register is how this project learns.

**How to use it**
- Read it before writing a spec, when reviewing a change and when preparing a release.
- Add a row when a bug is fixed, with or without a spec. Link the fix spec or the commit.
- Prevention status: `done` (with where), `pending` (with its spec) or `none` (say why).
- When three rows share a category, propose a spec that removes the pattern, not only the cases.
- Blameless: describe the system and the missing guard, never the person.

| Id | Date | What happened | Category | Root cause | Why not caught | Prevention (status) | Link |
|---|---|---|---|---|---|---|---|
| PM-0001 | 2026-01-12 | Export dropped the last row of each page | code defect | Sorted by `created_at`, filtered by `id` | No test crossed a page boundary | Boundary test (done: tests/export.test.ts); shared helper (pending: SPEC-0031) | [SPEC-0030](fixes/0030-export-skips-rows.md) |

## Patterns

Rows per category. At three, propose a spec that removes the pattern.

| Category | Rows |
|---|---|
| spec gap | 0 |
| docs drift | 0 |
| process gap | 0 |
| code defect | 1 |
| tooling | 0 |
| environment | 0 |
```

Keep the example row only as a guide: replace it with the project's first real bug. Ids are
sequential (`PM-NNNN`). Links are relative to `spec/`.

## Categories

One category per bug, chosen by where the cause sits, so that counting rows shows a pattern.

- **spec gap**: the spec was missing, ambiguous or wrong about the behaviour.
- **docs drift**: documentation, ADRs or references no longer match what the system does or decided.
- **process gap**: a step of the workflow was missing or skipped (approval, review, release check).
- **code defect**: the code does not do what the spec says.
- **tooling**: a script, workflow, hook or dependency behaved wrongly or was misconfigured.
- **environment**: the runtime, platform, identity or configuration differed from what was assumed.

The categories are few on purpose. If a bug fits two, pick the one whose fix would have prevented it.

## Pattern rule

When **three rows share one category**, stop fixing instances: propose a spec that removes the
pattern (a check, a template, an automation), and link it from the pending preventive actions of
those rows. Check the Patterns table after adding each row.

## Blameless wording

- Describe the system and the missing guard: "the workflow had no check for X", not "I forgot X".
- Name roles and components, not people. "The approval gate did not hold in headless runs."
- A cause that ends in "was careless" is not a root cause: ask why the system let it through.
- The detection gap is about the test, check or review that was absent.
- Preventive actions change the system (a test, a rule, a check). "Be more careful" is not one.
