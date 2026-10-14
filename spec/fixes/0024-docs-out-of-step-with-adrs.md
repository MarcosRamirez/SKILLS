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

   **Recorded results (T-1, 2026-10-14)**

   Run in a scratch git repository (the "user project"), with `skills@1.7.2` (`npx --yes skills --help`
   ran 1.7.2, also `npm view skills version`), nothing global (`-g` never used). Checked before and
   after: `~/.claude/skills`, `~/.agents/skills` and `~/.claude/senior-mindset.md` (sha256 unchanged).
   Commands below use `npx --yes skills@1.7.2` (shortened to `skills@1.7.2`). Source: this repository
   at `master` (SKILL.md `metadata.version` 2.4.0).

   1. **List.** `skills@1.7.2 add MarcosRamirez/SKILLS --list` found 2 skills: `save-image` and
      `senior-mindset`. It detected Claude Code as the running agent and installed non-interactively.
   2. **Claude Code, copy.** `add MarcosRamirez/SKILLS --skill senior-mindset -a claude-code --copy -y`
      wrote only `.claude/skills/senior-mindset/` (whole folder: SKILL.md, README.md, CHANGELOG.md,
      `references/`, `templates/` and `.claude-plugin/plugin.json`) and `skills-lock.json` at the project
      root (source, `skillPath`, `computedHash`; a `ref` field when installed from a ref). The summary
      lists a canonical `.agents/skills/` path, but with `--copy` no `.agents/` folder was created.
   3. **Agents that read `.agents/skills/`.** `-a codex` and, separately, `-a opencode` (both with
      `--copy`) wrote only `.agents/skills/senior-mindset/` (with `.claude-plugin/plugin.json`) plus
      `skills-lock.json`.
   4. **Both in one command.** `-a claude-code codex --copy -y` worked: it wrote both
      `.agents/skills/senior-mindset/` and `.claude/skills/senior-mindset/`, so one command gives the
      ADR-0005 layout (standard location plus the Claude Code bridge copy).
   5. **From a tag.** Both of these installed the tagged version, `skills-lock.json` recorded
      `"ref": "senior-mindset-v2.4.0"` and the installed `metadata.version` was `"2.4.0"`:
      - `add https://github.com/MarcosRamirez/SKILLS/tree/senior-mindset-v2.4.0/skills/senior-mindset -a codex --copy -y`
      - `add MarcosRamirez/SKILLS#senior-mindset-v2.4.0 --skill senior-mindset -a codex --copy -y`

      The tree URL with `senior-mindset-v2.3.0` installed `2.3.0` (`SKILL.md` and `plugin.json`), so
      the tag really selects the version.
   6. **Claude Code loads the copy.** `claude -p "Which skills are available? Answer with their names
      only."` from the project (no `--plugin-dir`) listed the project copy as plain `senior-mindset`
      next to the globally installed plugin `senior-mindset:senior-mindset`. It did not appear as a
      skills-directory plugin: `claude plugin list --json` showed `(suppressed)@skills-dir`, scope
      `project`, with the note that the project directory under `.claude/skills/` was skipped because
      the workspace was not trusted when plugins were scanned (`-p` has no trust dialog). So in
      practice the copy loads as a plain skill; whether it loads as `/senior-mindset:senior-mindset`
      after the trust dialog was not tested (it needs an interactive session).
   7. **Updates.** `update [skills...]` with `-g`, `-p` and `-y`; there is no flag to choose a ref.
      `skills@1.7.2 update -p -y` on a project installed from the tag `senior-mindset-v2.3.0` reported
      "All project skills are up to date" and kept version 2.3.0 with `ref` unchanged in
      `skills-lock.json`: a skill installed from a ref stays pinned, and one installed without a ref
      follows the default branch. To move to a new tag, run `add` again with the new ref.

   **Recommended commands for the READMEs** (all verified above, except where noted)
   - Project, all agents that read `.agents/skills/` plus Claude Code:
     `npx skills add MarcosRamirez/SKILLS --skill senior-mindset -a claude-code codex --copy`
     (drop `--copy` to symlink and update with `npx skills update`; `-a '*'` for all agents, documented in `--help` but not run here).
   - Project, Claude Code only: `npx skills add MarcosRamirez/SKILLS --skill senior-mindset -a claude-code`.
   - Global: add `-g` (not run here, to protect the user's machine; the flag is in `--help`).
   - Committed copy (team and cloud sessions get it): `--copy`, then commit `.agents/skills/`,
     `.claude/skills/` and `skills-lock.json`.
   - From a release tag: `npx skills add https://github.com/MarcosRamirez/SKILLS/tree/senior-mindset-vX.Y.Z/skills/senior-mindset`
     or `npx skills add MarcosRamirez/SKILLS#senior-mindset-vX.Y.Z --skill senior-mindset`.

   **Surprises**
   - Name collision: with the global plugin installed, Claude Code lists `senior-mindset` (project copy)
     and `senior-mindset:senior-mindset` (plugin) together. Not a conflict, but two entries for one skill.
   - The copy carries `.claude-plugin/plugin.json` into `.agents/skills/` too, so agents other than
     Claude Code receive a Claude Code file until SPEC-0021 T-1 moves it out.
   - `--copy` with `-a claude-code` does not create `.agents/skills/`: ask for both agents to get both.
   - `skills-lock.json` is created in the project root; it should be committed with the copies.
   - On Windows the CLI ends some runs with `Assertion failed: !(handle->flags & UV_HANDLE_CLOSING)`
     after finishing the work; the installs were complete.
   - Opening the scratch checks changed only the modification time of `~/.claude` itself (from running
     `claude -p`); the contents of the two skills folders did not change.
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
- [x] T-1 Verify `npx skills` and record (AC-2)
- [x] T-2 Align READMEs, identity, CLAUDE.md, mission and Draft specs (AC-1, AC-2)
- [x] T-3 `check-docs.py` and `checks.yml` with planted-failure tests (AC-3)
- [ ] T-4 Postmortem and PATCH release with `Closes-Spec: SPEC-0024` (AC-4)
