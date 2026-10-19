# SPEC-0031: rules that must always hold live where they are not always read

Type: fix
Status: Draft
Date: 2026-10-19
Approved by: (empty until the user explicitly approves)
Plan: high — Claude Opus 5.5 (the audit is judgment-heavy; moving the rules and the scenarios are mechanical)
Postmortem: the code-defect pattern in [POSTMORTEMS.md](../POSTMORTEMS.md#patterns) (PM-0004, PM-0011, PM-0017)

## Spec

**Problem.** Three rows of the register share one cause. A rule that must hold in every run was
kept somewhere that is not always read:

- PM-0004 and PM-0011: in the skill itself, which loads only when its description matches the
  prompt. The git trigger fix (SPEC-0027) and the headless suite (SPEC-0028) addressed that half.
- PM-0017: in a reference. "No git: propose `git init` and a commit of the current state first"
  lived only in `existing-projects.md`, which the agent reads only when it follows the link. In the
  2.10.0 pre-release suite, a run skipped it and offered to edit in place.

References are meant for detail, templates and examples. Some of them also hold rules whose
breach loses or mixes the user's work, skips an approval, exposes a secret or acts on a remote.

**Current behaviour**
- WHEN a rule that must always hold is written only in a reference THEN the agent follows it only
  in the runs where it opens that reference, and breaks it in the others.
- WHEN a new rule of that kind is added THEN nothing says where it must go, and nothing checks it.

**Expected behaviour**
- WHEN a rule must hold in every run (it protects user work, an approval, a secret, a remote or
  the default branch) THEN `SKILL.md` SHALL state it in one sentence, as a hard rule or in the step
  where it applies, and the reference SHALL keep only the detail.
- WHEN such a rule exists THEN a headless scenario SHALL cover it.
- WHEN someone adds a rule of that kind THEN the repository's instructions SHALL say it goes in
  `SKILL.md` first.

**Unchanged behaviour**
- References SHALL CONTINUE TO hold the detail, templates, edge cases and examples.
- `SKILL.md` SHALL CONTINUE TO stay under 500 lines.
- Rules that are only advice (style, defaults the user can override) SHALL CONTINUE TO live in the
  references.

**Reproduction**
1. List the imperative rules in `skills/senior-mindset/references/` ("never", "always", "do not",
   "before", "only after", "stop"): `git grep -n -i -E '\b(never|always|do not|only after|stop)\b' -- skills/senior-mindset/references`.
2. For each one that protects user work, an approval, a secret, a remote or the default branch,
   check whether `SKILL.md` states it. The no-git rule did not, before PM-0017.

**Root cause.** The skill splits by size: `SKILL.md` holds the flow, references hold the rest. The
split was decided by length, not by whether a rule must hold without being read. No check compares
the two.

**Fix**
1. **Audit.** One table in this spec: rule, reference, what it protects, stated in `SKILL.md`
   (yes / no), covered by a scenario (yes / no).
2. **Move.** Every "no" gets one sentence in `SKILL.md`, as a hard rule when it applies everywhere,
   otherwise in its step. The reference keeps the detail and links back.
3. **Scenarios.** Every must-hold rule without a scenario gets one, or a check in an existing one.
4. **Prevention.** AGENTS.md (this repository) and `postmortem.md` (the skill): a rule that must
   hold in every run goes in `SKILL.md` first; the reference holds its detail.

**Acceptance criteria**
- AC-1 The audit table is in this spec, one row per must-hold rule found in the references.
- AC-2 Every row marked "no" is stated in `SKILL.md`, and `SKILL.md` stays under 500 lines.
- AC-3 Every row has a headless scenario or check that passes.
- AC-4 The prevention rule is in AGENTS.md and in `postmortem.md`.
- AC-5 The postmortem section is filled, and the code-defect pattern in the register points here.

**Out of scope.** Rewriting the references' advice, or changing what any rule says.

## Postmortem

To be filled in T-4, for the pattern rather than a single bug: impact, the 5 Whys from the three
rows, why the split by size was not caught, the corrective action (the move) and the preventive
actions (the rule in AGENTS.md and `postmortem.md`, the scenarios).

## Plan

### Design
- The audit reads only the references' imperative sentences, not whole files, and classifies each:
  must hold (user work, approval, secret, remote, default branch) or advice.
- A moved rule is one sentence in `SKILL.md`; when several belong to one step, they share a line.
- Scenarios reuse the suite's helpers; one scenario may check several rules when one prompt
  exercises them.

### Steps
- T-1 Audit table (AC-1) — high — Claude Opus 5.5. Branch `fix/0031-t1-audit`.
- T-2 Move the "no" rows into `SKILL.md`, and the prevention rule (AC-2, AC-4) — medium — Claude Sonnet 5.5. Branch `fix/0031-t2-move-rules`.
- T-3 Scenarios or checks for the uncovered rows (AC-3) — medium — Claude Sonnet 5.5. Branch `test/0031-t3-scenarios`.
- T-4 Postmortem, register, release with `Closes-Spec: SPEC-0031` (AC-5) — low — Claude Haiku 5.5. Branch `chore/0031-t4-release`.

### Verification
The audit table against the grep of the reproduction; `wc -l SKILL.md` under 500; the new scenarios
and the full headless suite before the release; `check-docs.py`.

## Tasks
- [ ] T-1 Audit table (AC-1)
- [ ] T-2 Move the rules into `SKILL.md`, prevention rule (AC-2, AC-4)
- [ ] T-3 Scenarios or checks for the uncovered rules (AC-3)
- [ ] T-4 Postmortem, register and release with `Closes-Spec: SPEC-0031` (AC-5)
