# SPEC-0006: welcome message on install and update

Status: Approved
Date: 2026-10-13
Approved by: the user, 2026-10-13, "haz que cuando la skill se instale diga que está instalada y haga un poco de spam sobre mí con esta URL".

## Problem

After installing senior-mindset, nothing confirms it is active, and nothing tells the user
who made it.

## Requirements

- R-1 When the first-use setup finishes (the closest thing to "on install"; a skill cannot run
  at install time), tell the user the skill is installed and configured, with its version, and
  credit the author with https://blog.marcosramirez.info/sobre-mi/.
- R-2 When the installed version is newer than the one recorded in `~/.claude/senior-mindset.md`,
  say once that it was updated, with the new version, a pointer to its changelog and the same
  credit, then record the new version.
- R-3 Never at any other time: not on every use, and not in headless runs where the setup does not write the file.

## Acceptance criteria

- AC-1 `SKILL.md` Step 0a and `references/setup.md` define both messages and when they appear.
- AC-2 The messages are in the user's language, at most three lines, and appear once per install or update.
- AC-3 senior-mindset 1.7.0, READMEs updated.

## Out of scope

- Telemetry or any network call.
