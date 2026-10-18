# PLAN-0019: AGENTS.md as the single source of project instructions

Spec: [SPEC-0019](spec.md)
Status: In progress
Recommended overall: medium — Claude Sonnet 5.5 (mostly references and wording; one high-tier step for merging foreign content)

## Context

Verified in the official docs (code.claude.com/docs/en/memory): Claude Code reads `AGENTS.md`
natively since v2.1.277 only when there is no `CLAUDE.md`/`CLAUDE.local.md`; a `CLAUDE.md` with
`@AGENTS.md` loads both without duplication; symlinks break on Windows. Decided with the user:
AGENTS.md is the source; new projects get only AGENTS.md; migrated projects keep a one-line CLAUDE.md;
when both exist, merge and ask only the conflicts.

## Design

- **Where the skill writes:** `AGENTS.md` at the project root: `## Engineering conventions`,
  links to `spec/constitution/`, `spec/INVENTORY.md` and `spec/adr/README.md`.
- **One-line CLAUDE.md** (only when a CLAUDE.md already existed):

  ```markdown
  @AGENTS.md

  ## Claude Code
  (hooks, skills, plugins, slash commands, settings — only if any)
  ```
- **Merge algorithm (both files with content):**
  1. Split both files by headings.
  2. Identical or complementary sections → union.
  3. Contradictory rules (same topic, different instruction) → one closed question each, both versions shown.
  4. Claude-only items → stay in CLAUDE.md below the import.
  5. Show the result as a change notice, then commit on a branch.
- **Detection:** look for `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md` and
  `.claude/AGENTS.md` at the root and above, and per package in monorepos; check whether CLAUDE files start with `@AGENTS.md`.

## Steps

### T-1 References and SKILL.md — medium
- Recommended: medium — Claude Sonnet 5.5 (systematic wording changes)
- Branch: `feat/0019-t1-agents-md-references`
- Do: replace CLAUDE.md as the conventions file with AGENTS.md across SKILL.md and references
  (project-layout, setup, constitution, release-automation, …); add the case table and the safety rule
- Files: ~ SKILL.md, ~ references/*.md, ~ skills/senior-mindset/README.md
- Done when: AC-1

### T-2 Merge behaviour and headless tests — high
- Recommended: high — Claude Opus 5.5 (merging someone else's instructions without losing anything)
- Branch: `feat/0019-t2-merge-and-tests`
- Do: write the merge procedure; build six scratch repos (one per case in AC-2); run headless with `--plugin-dir`; fix wording until each case passes
- Files: ~ references/project-layout.md (or a new references/agents-md.md)
- Done when: AC-2

### T-3 Migrate this repo, update SPEC-0013 — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0019-t3-migrate-repo`
- Do: `git mv CLAUDE.md AGENTS.md`; new one-line CLAUDE.md; fix links in READMEs and docs; check `/memory`
- Files: CLAUDE.md → AGENTS.md, + CLAUDE.md, ~ README.md, ~ spec/**
- Done when: AC-3, AC-4

### T-4 Release (minor) — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0019-t4-release`
- Do: minor bump, changelogs; PR body with `Closes-Spec: SPEC-0019`
- Files: ~ plugin.json, ~ SKILL.md frontmatter, ~ CHANGELOGs
- Done when: the bot closes the spec, the plan and the roadmap row; `claude plugin update`

## Verification

Six headless cases (AC-2); `/memory` in a real session (AC-3); `git log --follow AGENTS.md` (AC-4); `claude plugin validate --strict`.

## Risks

- A CLAUDE.md added later without the import silently hides AGENTS.md → R-2b safety rule, checked at every session start.
- Losing content in a merge → the change notice shows the full result before anything is written; contradictions are always asked.

## Out of scope

Other agents' config files (SPEC-0013).
