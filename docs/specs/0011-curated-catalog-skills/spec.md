# SPEC-0011: curated catalog of skills and MCPs, and skill management

Status: Draft
Date: 2026-10-13
Approved by: (empty until the user explicitly approves)

## Problem

The skill cannot recommend task-specific skills (web design, accessibility, performance…) or MCPs
because there is no curated source to choose from, and nothing manages what gets installed.

## Requirements

- R-1 **Curated lists inside the skill**: `skills/senior-mindset/catalog/skills.json` and
  `catalog/mcps.json`, maintained by the user in this repository and shipped with every install
  and `plugin update`. One list for every project; the skill picks what fits each project.
- R-2 Each entry: id, name, purpose, when to propose it (task types / stack signals), source and
  install command, permissions it needs, pinned version, why it is in the list, date added.
- R-3 Written **inclusion criteria** in `references/catalog.md`: official or vendor-maintained,
  actively maintained, open licence, minimal permissions, reviewed before inclusion.
- R-4 A JSON Schema for both lists and a CI check that rejects malformed entries.
- R-5 Third-party skills that pass the criteria are also added to the user's marketplace
  (`.claude-plugin/marketplace.json`, pinned source), so they install with `/plugin install`.
- R-6 Skill management: propose (by task type) → install only if the user accepts → record in the
  project → update with releases → propose removing unused ones. New skills go through the
  collision check of the first-use setup.

## Acceptance criteria

- AC-1 Both catalog files with an initial curated set, the schema, and `references/catalog.md`.
- AC-2 CI validation step; a malformed entry fails the check (tested locally).
- AC-3 Headless test: "design a landing page" in a test project → proposes the web-design entry, installs nothing without consent.
- AC-4 At least one vetted third-party skill installable from the user's marketplace.

## Open question (decide with the user before approval)

- How the skills installed in a project are declared in that project (the counterpart of
  `.mcp.json` for MCPs).

## Out of scope

- MCP installation and management (SPEC-0012), beyond the shared catalog file.
