# SPEC-0014: documented commands, help and status

Status: Draft
Date: 2026-10-13
Approved by: (empty until the user explicitly approves)

## Problem

senior-mindset reacts to phrases ("reconfigure senior-mindset", "run plan X", "release the beta"),
but they are scattered across `SKILL.md` and references. Nobody can discover them, and there is no
way to ask the skill what it can do or where a project stands.

## Requirements

- R-1 One documented list of commands, `references/commands.md`: each command is an **intent**,
  with example phrases, what it does, and where it is specified. Example phrases are illustrative,
  not a closed list.
- R-1b **Any language.** Commands are recognised by intent in whatever language the user writes
  ("¿qué puedes hacer?", "what can you do?", "qu'est-ce que tu sais faire ?"…), and every
  answer, including help and status, is in the user's language.
- R-2 **help** ("ayuda", "¿qué puedes hacer?", "help", "what can you do?"): shows the commands
  with one example each, plus a summary of the current configuration (`~/.claude/senior-mindset.md`
  and the project's `## Engineering conventions`).
- R-3 **status** ("estado del proyecto", "status"): specs and plans with their states, open PRs,
  current version and release tags, installed automations.
- R-4 **list plans** ("lista los planes", "list plans"): plans with state and tier, highlighting
  which can be run now.
- R-5 Existing commands are listed too: reconfigure, run plan X, release.
- R-6 The help reads `commands.md`, so adding a command means adding a row there.
- R-8 **Help on install.** The welcome message shown when the first-use setup finishes (SPEC-0006)
  adds a short "what I can do" summary and how to ask for the full help, in the user's language,
  keeping the author credit. The update message stays one line plus the credit.
- R-7 Check the official docs on whether a plugin can also expose these as slash commands
  (e.g. `/senior-mindset:help`). Add them if supported, as thin aliases of the same behaviour.

## Acceptance criteria

- AC-1 `references/commands.md` with every command; `SKILL.md` has a short "Commands" section linking it; the README lists them.
- AC-2 Headless test: "¿qué puedes hacer?" → command list + configuration summary, no other action.
- AC-2b Headless tests in two more languages (e.g. English and French) → help recognised, answer in that language.
- AC-2c The welcome message includes the short summary and the help hint, in the user's language.
- AC-3 Headless test in this repo: "status" → specs and plans with correct states (cross-checked with the files).
- AC-4 Slash-command aliases added, or the reason they are not (with the doc link) recorded in the design.

## Out of scope

- New behaviour beyond help, status and list plans.
