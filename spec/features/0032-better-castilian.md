# SPEC-0032: better-castilian, writing rules for Castilian Spanish

Type: feature
Status: Draft
Date: 2026-11-15
Requested by: Marcos, 2026-11-15 (Huly SKILL-93). Spec approval still pending (needs Marcos in the pane, or his Huly comment citing this file's commit SHA).
Plan: low — Claude Sonnet 5.5 (one small skill, one script, its tests)

## Spec

**Problem.** Agents that write Castilian Spanish drift into habits the author does not want:
the tilde as "approximately" (`≈`, `~`) and the long dash (`—`). There is no shared, checkable
place where such rules live, and it must be able to grow.

**Requirements**
- R-1 A skill `better-castilian`, loaded when writing or reviewing any Castilian text (messages,
  reports, comments, posts, documentation).
- R-2 Rule 1: never `≈` or `~` for "approximately". Rule 2: use `±` for approximate amounts
  (`±30 min`). Rule 3: never the em dash `—`, nor the en dash `–` as a substitute; use comma,
  period, colon, parentheses or rewrite.
- R-3 A short bad/good list with generic examples.
- R-4 A checker in `scripts/` that reports `≈`, `~`, `—` and `–` with line and column, with no
  false positives in code blocks, inline code, URLs or paths such as `~/dir`.
- R-5 The skill grows by approved rules only. Proposals go in a "Proposed, not approved" section
  of the delivery, never into the skill.
- R-6 Public repository: no private data, no internal names, generic examples.

**Acceptance criteria**
- AC-1 The skill validates (`validate_skill.py` of the agents' `create-skill`) and
  `claude plugin validate .` passes.
- AC-2 The checker lists the three characters with line numbers in a file that has them,
  prints nothing and exits 0 on a clean file, and reports nothing on `~/path`, URLs and code.
- AC-3 In `SKILL.md`, `≈` and `—` appear only in the "bad" examples.
- AC-4 The checker has a suite in `tests/ci/` that runs in CI.

**Out of scope.** Rewriting existing texts of other skills or agents. Rules not approved by Marcos.

## Plan

### Design
- `skills/better-castilian/SKILL.md` (rules, bad/good table, how to run the checker), `README.md`,
  `scripts/check_writing.py` (Python 3 stdlib, no dependencies).
- Checker: strips fenced blocks (``` and ~~~), inline code spans, URLs and `~/`, `~user` paths,
  then reports each remaining character. Exit 0 clean, 1 findings, 2 usage. Reads a file or `-` (stdin).
- Version `0.0.1-alpha.1` (new skill), marketplace entry, README, INVENTORY, roadmap.

### Steps
- T-1 Skill, README, checker, tests, docs (AC-1 to AC-4) — low — Claude Sonnet 5.5. Branch `feat/skill-93-skill-nueva-better`.

### Verification
`bash tests/ci/run.sh`, `check-docs.py`, `check-versions.py`, `claude plugin validate .`.

## Tasks
- [ ] T-1 Skill, checker, tests, docs (AC-1 to AC-4)
