# SPEC-0025: propagate every decision to what it touches

Type: feature
Status: Approved
Date: 2026-10-14
Approved by: the user, 2026-10-14, approved the plan that defines this spec

## Problem

A decision changes in one place (an ADR, a spec that changes a convention or a layout), but many
documents describe it: READMEs, the project instructions, the constitution, references, and other
specs. Nothing makes the change reach them, so documents drift and contradict the decision.
SPEC-0024 is the proof in this repository. Projects built with the skill have the same risk, and
older projects or data may need a migration that nobody plans.

## Requirements

- R-1 **Every ADR has an `## Impact` section:**
  - the documents that describe the decision (READMEs, the conventions in AGENTS.md or CLAUDE.md,
    the constitution, references, other specs), each marked "updated in this PR" or
    "follow-up: SPEC-NNNN";
  - `Replaces terms: old → new`, the words a search should catch (e.g. `~/.claude/skills → .agents/skills`);
  - existing projects or data affected, with the migration (R-3).
- R-2 **The impact sweep.** It is written in `references/adr.md`, with a short rule in `SKILL.md`.
  It runs when an ADR is accepted or superseded, or when a spec changes a convention, a layout or
  behaviour that documents describe:
  1. search for the ADR id and file name, the replaced terms, and the files of the area;
  2. update in the same PR the living documents and the text of Draft and Approved specs;
  3. keep the history of Implemented specs, ADR files and changelogs as written; a spec whose text
     changes gets a line in its `## Changelog`;
  4. state a decided change that is not implemented yet with its spec ("changing in SPEC-NNNN"),
     never hidden and never claimed early;
  5. turn implementation work into Draft specs, linked from the Impact section.
- R-3 **Old projects and data.** When the change affects existing projects or data (a layout, file
  names, a format), the Impact section lists the migration. The skill proposes it through the change
  notice of SPEC-0008, on a branch, and never applies it silently.
- R-4 **Deterministic check, offered as an automation:**
  - a `docs-check` entry in `references/automations.md`;
  - a template with the `check-docs.py` of SPEC-0024 and its CI step;
  - it checks that the living documents have no broken relative links and no links to a superseded ADR;
  - it is recommended for projects with docs.
- R-5 **This repository:** `CLAUDE.md` "Documentation is updated in the same commit as the change"
  adds the sweep for ADRs and for specs that change conventions or layouts.

## Acceptance criteria

- AC-1 The ADR template in `references/adr.md` has the `## Impact` section with `Replaces terms`.
- AC-2 The sweep procedure is written in `references/adr.md`, and `SKILL.md` has the rule.
- AC-3 Headless test: in a test project whose README and conventions describe PostgreSQL through an
  ADR, superseding that ADR with SQLite makes the agent do three things in the same change:
  - update the README and the conventions;
  - fill in the Impact section;
  - list the follow-up work as Draft specs.
- AC-4 The `docs-check` automation, copied into a test project, fails on a link to a superseded ADR
  and on a broken link.
- AC-5 `CLAUDE.md` in this repository has the sweep rule.

## Out of scope

- Rewriting the history of Implemented specs or ADRs.
- Migrating projects automatically. Migrations are proposed through SPEC-0008.
