---
name: write-skill
description: >
  Creates or reviews agent skills that follow the Agent Skills standard
  (agentskills.io): valid SKILL.md frontmatter, a description that triggers, one
  level of references, scripts only for deterministic work, and token budgets
  checked by a script. Use when asked to create a skill, write or review a
  SKILL.md, split a big skill, or fix its description.
  Triggers: "create a skill", "write a skill", "review this skill", "crear una
  skill", "nueva skill", "revisa esta skill", "SKILL.md".
license: MIT
metadata:
  author: Marcos Ramírez
  homepage: https://marcosramirez.info
  blog: https://blog.marcosramirez.info
  dev: https://marcosramirez.dev
  version: "0.0.1-alpha.1"
allowed-tools: Read Write Edit Bash Glob Grep
---

## Hard rules

1. **One skill, one job.** A procedure you will repeat becomes a skill; a one-off stays a script or a doc.
2. **Name it for the job**: `^[a-z0-9]+(-[a-z0-9]+)*$`, 1–64 chars, equal to its folder, and not the name of an installed skill.
3. **The description is the trigger**: what it does, when to use it, and the words the user types, in the languages you expect. 1–1024 chars (standard), 500 in this repository.
4. **The body is the whole procedure.** What every activation needs stays in `SKILL.md`; what only some paths need goes to `references/`.
5. **One level deep.** `SKILL.md` → `references/<topic>.md`. A reference never links to another reference.
6. **Nothing twice.** Each rule, table or example lives in exactly one file.
7. **Scripts for determinism.** Self-contained, no network, non-interactive, explicit exit codes.
8. **Validate before publishing.** `scripts/validate-skill.py` and the standard's `skills-ref`.

## Step 0 — Does it deserve a skill?

- A repeated procedure, a convention, or a format to follow exactly: yes.
- A fact, a one-off task, or something the model already does well: no. Say so and write the script or the doc instead.
- Another skill already covers it: extend that skill or point to it. Do not duplicate.

## Step 1 — Name and folder

- Lowercase kebab-case, no leading or trailing `-`, no `--`, at most 64 characters.
- The folder carries the name: `skills/<name>/SKILL.md`.
- Look for collisions in `~/.claude/skills/`, `.claude/skills/`, `.agents/skills/` and `~/.config/opencode/skills/`. On a collision, rename: a same or near name makes the agent pick the wrong one.

## Step 2 — Description that triggers

How to write it, with good and bad examples: [references/description.md](references/description.md).

It answers three questions in one paragraph: **what** it does, **when** to use it, **which words** the user will type. Add other languages when you work in them, and say what it does *not* do when that prevents a wrong activation.

## Step 3 — The body

Write the steps in the order the work happens. For each: the rule, the reason when it is not obvious, and one short example.

- Imperative, English identifiers, no prose that only explains the topic.
- Every rule must change behaviour. A rule nothing depends on is context the agent pays for.
- Budget: 500 lines hard (standard), 100 lines and 800 words as the target here. Over the target, compress first and split second.

## Step 4 — Split with progressive disclosure

`SKILL.md` (about 5k tokens at most) → `references/<topic>.md` (one topic, about 150 lines) → `scripts/`, `assets/`.

- Link each reference with when to read it: "See [budget](references/budget.md) when a file does not fit."
- Move only what the normal path does not need. If every activation reads a reference, inline its essence instead.
- Delete any reference the body never mentions: it is weight nobody reads.

The math and the anti-patterns: [references/budget.md](references/budget.md).

## Step 5 — Scripts and assets

- Code goes in `scripts/`, templates and sample data in `assets/`.
- Standard library when you can, errors that say what to do, idempotent runs.
- Never paste a long script into the body: the agent runs files.

## Step 6 — Validate

```bash
python3 scripts/validate-skill.py <skill-folder>   # this repo's budgets and structure
npx skills-ref validate <skill-folder>             # the standard's validator
```

Both must pass. The script prints `file:line: error|warning` and exits 1 on errors; warnings are the stricter budgets here. The checklist: [references/checklist.md](references/checklist.md).

## Step 7 — Publish

- `metadata.version`, SemVer: `0.0.1-alpha.1` for a new skill, `1.0.0` once tested and stable.
- Repeat the version in the project's manifest when it has one (here: `.claude-plugin/marketplace.json`), and update the READMEs and the inventory in the same change.
- Install with `npx skills add <owner>/<repo> --skill <name>`; tag `<name>-v<version>`.
- Frontmatter fields and their limits: [references/standard.md](references/standard.md).
