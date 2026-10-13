# SPEC-0004: defensive programming by default

Status: Approved
Date: 2026-10-13
Approved by: the user, 2026-10-13, "quiero que por defecto aplique programación defensiva … ponlo tú como sea correcto".

## Problem

senior-mindset validates input at boundaries (security.md), but does not ask for defensive
code in general: guard clauses, checking resources before acting (e.g. free disk space
before an upload), timeouts, limits, and handling the failures that checks cannot prevent.

## Requirements

- R-1 Defensive programming is an always-on rule, scripts included.
- R-2 A reference explains what to check and how: trust boundaries, guard clauses, resource
  checks, external calls, limits, failure handling, cleanup. It also says when not to overdo it.
- R-3 The self-review checklist includes it.

## Acceptance criteria

- AC-1 `references/defensive-programming.md` exists, with concrete patterns and short examples. It covers check-then-act races (e.g. a disk-space check plus handling `ENOSPC`).
- AC-2 `SKILL.md` lists defensive programming in the Always-on rules, and has a self-review item linking the reference.
- AC-3 `security.md` links to it; the README tables and the inventory list it.
- AC-4 senior-mindset 1.4.0; changelogs updated; plugin update verified after merge.

## Out of scope

- Language-specific linters or static analysis setup.
