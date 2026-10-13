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
- R-2 Each entry: id, name, purpose, `recommended` (listed first and marked "(Recommended)" in the
  install question), when to propose it (task types / stack signals), source and install command,
  permissions it needs, pinned version, why it is in the list, date added.
- R-3 Written **inclusion criteria** in `references/catalog.md`: official or vendor-maintained,
  actively maintained, open licence, minimal permissions, reviewed before inclusion.
- R-4 A JSON Schema for both lists and a CI check that rejects malformed entries.
- R-5 Third-party skills that pass the criteria are also added to the user's marketplace
  (`.claude-plugin/marketplace.json`, pinned source), so they install with `/plugin install`.
- R-6 **The initial lists are built with the user**, not by the AI alone. When this step is reached,
  the AI asks the user for the skills and MCPs they already use or want, and proposes researched
  candidates (by task type and stack), each with why and how it meets the criteria. Nothing enters
  the catalog without the user's approval, entry by entry.
- R-7 Skill management: propose (by task type) → install only if the user accepts → record in the
  project → update with releases → propose removing unused ones. New skills go through the
  collision check of the first-use setup.
- R-8 **Install scope: the project by default.** Every skill and MCP is installed for the current
  project unless the user picks "Global" in the install question:
  - skills: `claude plugin install <plugin>@<marketplace> --scope project`, recorded in the project's
    `.claude/settings.json` (shared through git); the marketplace is declared the same way
    (`claude plugin marketplace add … --scope project`);
  - MCPs: `claude mcp add --scope project` → `.mcp.json` (SPEC-0012);
  - Claude Code's own defaults are not the project (`user` for plugins, `local` for MCPs), so the
    skill always passes `--scope project` explicitly;
  - global (`--scope user`) only when the user picks it. Global installs are recorded in
    `~/.claude/senior-mindset.md`, project installs in the project's INVENTORY.

## Acceptance criteria

- AC-1 Both catalog files, the schema, and `references/catalog.md`.
- AC-1b The initial set comes from a review session with the user: their lists plus proposed
  candidates, every entry approved explicitly. Rejected candidates are recorded with the reason
  (so they are not proposed again).
- AC-1c `catalog/mcps.json` starts with **Context7** as a recommended entry (the user's own pick, see
  SPEC-0012 R-6).
- AC-2 CI validation step; a malformed entry fails the check (tested locally).
- AC-3 Headless test: "design a landing page" in a test project → proposes the web-design entry, installs nothing without consent.
- AC-4 At least one vetted third-party skill installable from the user's marketplace.

## Questions decided with the user

- How the skills installed in a project are declared in that project (the counterpart of
  `.mcp.json` for MCPs): in the project's `.claude/settings.json`, through
  `claude plugin install … --scope project` (R-8, ADR-0004).

## Out of scope

- MCP installation and management (SPEC-0012), beyond the shared catalog file.

## Changelog

- 2026-10-13: open question decided by the user: skills and MCPs install at project scope by
  default, global only when the user asks (R-8, ADR-0004).
