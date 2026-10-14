# SPEC-0026: a postmortem for every bug, and a register of lessons

Type: feature
Status: Approved
Date: 2026-10-14
Approved by: the user, 2026-10-14, approved the plan that defines this spec

## Problem

Bugs get fixed, and the fix spec records the root cause. But nothing asks why the bug was not
caught earlier or what stops the same kind of bug from coming back. Nothing collects the lessons
either. This repository has already had about eight bugs, some of the same kind: an approval gate
skipped twice, workflow steps aborting, decisions not reaching the docs. Each was fixed, but there
is no place to see the pattern. The user wants a postmortem for every bug, the past ones included,
and a register like `spec/INVENTORY.md` but for bugs.

Standard practices this spec combines:

- **Blameless postmortem** ([Google SRE, "Postmortem Culture"](https://sre.google/sre-book/postmortem-culture/)):
  it records what happened, the impact, the root cause, how it was detected, how it was resolved
  and the actions that follow. It looks at the system, not at who made the mistake.
- **5 Whys** (Toyota Production System): ask "why?" until the answer is a cause you can act on,
  not the symptom.
- **CAPA** (corrective and preventive action, from quality management such as ISO 9001): every bug
  gets a corrective action, which fixes this case, and a preventive action, such as a test, a
  check or a rule, which stops it from happening again.
- **Known Error Database** (ITIL problem management): a register of known problems with their cause.
- **Defect classification** (e.g. IBM's Orthogonal Defect Classification): one category per bug, so
  that patterns show up.

## Requirements

- R-1 **Every fix spec has a `## Postmortem` section**, blameless, with:
  - the impact (who or what was affected, for how long);
  - the 5 Whys chain, from the symptom to an actionable root cause;
  - why it was not caught earlier (the detection gap);
  - the corrective action (the fix);
  - the preventive actions, each one done (with where) or pending (with its spec).
- R-2 **A register, `spec/POSTMORTEMS.md`**, with one row per bug:
  - id and date;
  - what happened;
  - category: spec gap · docs drift · process gap · code defect · tooling · environment;
  - root cause;
  - why it was not caught;
  - prevention and its status;
  - a link to the fix spec or the commit.

  A trivial fix without a spec still gets a row.
- R-3 **The register is read like the inventory**:
  - before writing a spec, so known failure modes are designed out;
  - when reviewing a change;
  - when preparing a release, so pending preventive actions are not forgotten.

  When one category reaches three rows, propose a spec that removes the pattern, not only the instances.
- R-4 **In the skill, for every project:**
  - `references/postmortem.md` with the method and the templates;
  - the `## Postmortem` section in the fix template (`references/sdd.md`);
  - the rule in the fix flow of `SKILL.md`: reproduce → root cause → fix → postmortem and register row;
  - the register template, created at the first bug.
- R-5 **In this repository**, the register starts with the postmortems of the bugs already found:
  - implementing without explicit approval, and later the gate failing in headless runs (SPEC-0003; commits dfbd476, de1ce4e);
  - the kickoff checklist skipped before features (11238c6);
  - the skill not loading for scripts (cde6c4f);
  - stacked PRs closed when their base branch was deleted (5f0d95e);
  - the first on-merge run failing without a git identity, so 1.5.0 was tagged by hand (e985f41);
  - on-merge aborting when no spec path changed (cac50d9);
  - versions that could move without anything implemented (SPEC-0023);
  - the skill not triggering on merge-only requests, found in the SPEC-0016 tests: a merge went
    ahead without a question when only git-workflow loaded;
  - docs out of step with the ADRs (SPEC-0024), completed when that fix runs.

## Acceptance criteria

- AC-1 `references/postmortem.md`, the `## Postmortem` section of the fix template, and the register template exist.
- AC-2 `spec/POSTMORTEMS.md` in this repository holds the postmortems of R-5, each with its
  category, root cause, detection gap and preventive actions with their status.
- AC-3 Headless test: a fix in a test project produces its `## Postmortem` section and its row in the register.
- AC-4 `SKILL.md` asks to read the register before writing a spec and when preparing a release.

## Out of scope

- Production incident response (on-call, paging, status pages).
- Tracking bugs in an issue tracker (SPEC-0015).
