# SPEC-0024: docs follow the current ADRs

Type: fix
Status: Approved
Date: 2026-10-14
Approved by: the user, 2026-10-14, approved the plan that defines this spec
Plan: medium — Claude Sonnet 5.5 (a verification, wording across many files, and a small check script)
Depends on: SPEC-0026 (this fix gets the first postmortem in the new format)

## Spec

**Problem.** ADR-0005 (standard locations first) and ADR-0006 (version in SKILL.md, no Claude Code
files in skill folders) were accepted in PR #40. That PR updated `tech-stack.md` and three Draft specs,
but none of the living documents. The user found it: the repository still presents itself, installs
and documents itself as Claude-first, and points to decisions that no longer hold.

**Current behaviour**
- WHEN someone reads `CLAUDE.md` THEN its conventions present ADR-0003 (distribution) and ADR-0001
  (versioning) as current, though ADR-0005 and ADR-0006 superseded them, and its first line says
  "skills for Claude Code".
- WHEN someone installs from `README.md` or `skills/senior-mindset/README.md` THEN they get a
  Claude-first, global install: `/plugin install` at user scope, or a copy in `~/.claude/skills/`.
- WHEN someone reads the repository's identity THEN it says Claude Code only:
  - the README title is "superpowers for Claude Code";
  - the marketplace description is "Claude Code skills";
  - the mission's success criterion is "one command (`/plugin`)".
- WHEN someone reads the Draft specs THEN some still use replaced terms:
  - SPEC-0009 R-3 maps docs onto `{spec,design,tasks}.md` and CLAUDE.md;
  - SPEC-0015 R-1 records the choice "in CLAUDE.md";
  - PLAN-0012 cites ADR-0004.

**Expected behaviour**
- WHEN someone reads a living document THEN it SHALL state the current decisions.
- WHEN a decision is accepted but not implemented yet THEN the document SHALL say so and name the
  spec that brings it (e.g. "until SPEC-0021 T-1, the version still lives in `plugin.json`").
- WHEN someone installs from a README THEN the first path SHALL be the standard one
  (`npx skills`, into the project). The Claude Code marketplace SHALL appear as an option for Claude Code only.
- WHEN a Draft spec describes an area that a newer ADR changed THEN it SHALL use the current terms.

**Unchanged behaviour**
- Implemented specs, ADR files, `CHANGELOG.md` files and the `## Changelog` sections of specs SHALL
  CONTINUE TO keep their history as written.
- The skill's behaviour SHALL CONTINUE TO be the same. Only documentation changes.
- Installing with `/plugin install senior-mindset@marcosramirez-skills` SHALL CONTINUE TO work.

**Reproduction**
1. `grep -rn "ADR-0001\|ADR-0003" CLAUDE.md README.md` lists the superseded ADRs presented as current.
2. `grep -n "~/.claude/skills\|/plugin install" README.md skills/senior-mindset/README.md` shows the
   Claude-first, global install paths.
3. `grep -n "Claude Code" README.md .claude-plugin/marketplace.json spec/constitution/mission.md`
   shows the Claude-only identity.

**Root cause.** Accepting an ADR does not require checking every document that describes the
decision it changes. Nothing detects a living document that links a superseded ADR. The rule
"documentation is updated in the same commit" covers changes to a skill, not decisions.

**Fix**
1. Verify `npx skills` against this repository, in a scratch project:
   - it finds `skills/senior-mindset`;
   - what `--copy` writes into `.agents/skills/` and `.claude/skills/`;
   - Claude Code loads the copy. Until SPEC-0021 T-1 moves `plugin.json` out, it loads as a
     skills-directory plugin, `/senior-mindset:senior-mindset`;
   - whether it can install from a tag.

   Record the results here.
2. READMEs, root and skill, in this order:
   1. `npx skills add MarcosRamirez/SKILLS --skill senior-mindset` (into the project; `-g` for
      global; `--copy` when the copy is committed);
   2. the "ask your agent" prompt, with `.agents/skills/` and the bridge for agents that do not read it;
   3. a manual copy;
   4. the Claude Code marketplace, as an option for Claude Code only.

   This takes over SPEC-0021 R-3 and AC-1.
3. Identity, in honest wording: "Agent Skills standard; built and tested on Claude Code; other
   agents: SPEC-0013". It goes in:
   - the README title and intro;
   - the first line of `CLAUDE.md`;
   - the marketplace description;
   - the mission's "Success looks like" (`npx skills` or `/plugin`), as approved by the user with the plan.
4. The `CLAUDE.md` conventions:
   - distribution → ADR-0005;
   - versioning → ADR-0006, with "until SPEC-0021 T-1, `plugin.json`".
5. Draft specs:
   - SPEC-0009 R-3: the current layout (features and fixes, plan files) and AGENTS.md per SPEC-0019;
   - SPEC-0015 R-1: the project instructions;
   - PLAN-0012: ADR-0005.
6. Regression guard: `.github/scripts/check-docs.py` (Python standard library), run by a new
   `.github/workflows/checks.yml` on every pull request. On the living documents it checks:
   - that every relative link resolves (fenced code is skipped);
   - that no link points to an ADR whose `Status:` line is `Superseded`.

   The living documents are `README.md`, `CLAUDE.md`, `AGENTS.md`, `skills/*/README.md`,
   `skills/*/SKILL.md`, `skills/*/references/*.md`, `spec/constitution/*.md` and
   `spec/INVENTORY.md`. Specs are left out on purpose, because they carry history.

**Acceptance criteria**
- AC-1 The reproduction greps return nothing in the living documents, except a mention that
  explicitly says the ADR was superseded.
- AC-2 The `npx skills` verification is recorded here, and the READMEs follow it.
- AC-3 `check-docs.py` fails on a planted broken link and on a planted link to a superseded ADR,
  and passes on master after the fix.
- AC-4 The unchanged-behaviour cases hold, and `claude plugin validate .` plus
  `claude plugin validate ./skills/senior-mindset --strict` pass.

**Out of scope.** Changing what the skill does: AGENTS.md (SPEC-0019), installs, detection and the
manifest move (SPEC-0021).

## Postmortem

Written when this fix runs, with the template of SPEC-0026.

## Plan

### Design
- Living documents describe what holds today. A decided change that is not implemented yet is
  stated with its spec, not hidden and not claimed early.
- The check reads each ADR's `Status:` line to know which ADRs are superseded, so nothing needs to
  be listed by hand.

### Steps
- T-1 Verify `npx skills` in a scratch project and record the results (AC-2, first half) — medium — Claude Sonnet 5.5. Branch `fix/0024-t1-verify-npx-skills`.
- T-2 READMEs, identity, the `CLAUDE.md` conventions, the mission and the Draft specs (AC-1, AC-2) — medium — Claude Sonnet 5.5. Branch `fix/0024-t2-align-docs`.
- T-3 `check-docs.py`, `checks.yml` and its tests (AC-3) — medium — Claude Sonnet 5.5. Branch `fix/0024-t3-docs-check`.
- T-4 Postmortem (SPEC-0026), then a PATCH release, because the skill README changes; PR body with `Closes-Spec: SPEC-0024` — low — Claude Haiku 5.5. Branch `chore/0024-t4-release`.

### Verification
The reproduction greps before and after; the planted failures for the check; `claude plugin validate`.

## Tasks
- [ ] T-1 Verify `npx skills` and record (AC-2)
- [ ] T-2 Align READMEs, identity, CLAUDE.md, mission and Draft specs (AC-1, AC-2)
- [ ] T-3 `check-docs.py` and `checks.yml` with planted-failure tests (AC-3)
- [ ] T-4 Postmortem and PATCH release with `Closes-Spec: SPEC-0024` (AC-4)
