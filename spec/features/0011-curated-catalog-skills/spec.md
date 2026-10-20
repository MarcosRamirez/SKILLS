# SPEC-0011: curated catalog of skills and MCPs, and skill management

Type: feature
Status: Implemented
Implemented: 2026-10-20, PR #108
Date: 2026-10-13
Approved by: the user, 2026-10-19, chose "0011 ahora, contigo" in the next-step question

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
- R-5 Third-party skills that pass the criteria install with `npx skills add <source> --skill <name>`,
  pinned to a release or commit. Listing them in the user's marketplace
  (`.claude-plugin/marketplace.json`) is optional, for those who use `/plugin` in Claude Code.
- R-6 **The initial lists are built with the user**, not by the AI alone. When this step is reached,
  the AI asks the user for the skills and MCPs they already use or want, and proposes researched
  candidates (by task type and stack), each with why and how it meets the criteria. Nothing enters
  the catalog without the user's approval, entry by entry.
- R-7 Skill management: propose (by task type) → install only if the user accepts → record in the
  project → update with releases → propose removing unused ones. New skills go through the
  collision check of the first-use setup.
- R-8 **Install in the project, standard locations first** (ADR-0005). Every skill and MCP is
  installed for the current project unless the user picks "Global" in the install question:
  - skills: `npx skills add <source> --skill <name> --copy` → `.agents/skills/<name>/`, plus a copy in
    `.claude/skills/<name>/` for Claude Code, which does not read `.agents/skills/` yet. Both are committed;
  - MCPs: each agent's own project file, since there is no shared standard (Claude Code:
    `claude mcp add --scope project` → `.mcp.json`, SPEC-0012). Claude Code's default MCP scope is
    `local`, so the flag is always explicit;
  - global (`npx skills add … -g`; `claude mcp add --scope user`) only when the user picks it. Global
    installs are recorded in `~/.claude/senior-mindset.md`, project installs in the project's INVENTORY.

## Acceptance criteria

- AC-1 Both catalog files, the schema, and `references/catalog.md`.
- AC-1b The initial set comes from a review session with the user: their lists plus proposed
  candidates, every entry approved explicitly. Rejected candidates are recorded with the reason
  (so they are not proposed again).
- AC-1c `catalog/mcps.json` starts with **Context7** as a recommended entry (the user's own pick, see
  SPEC-0012 R-6).
- AC-2 CI validation step; a malformed entry fails the check (tested locally).
- AC-3 Headless test: "design a landing page" in a test project → proposes the web-design entry, installs nothing without consent.
- AC-4 At least one vetted third-party skill installs with `npx skills add` (and, optionally, from the user's marketplace).

## Questions decided with the user

- How the skills installed in a project are declared in that project (the counterpart of
  `.mcp.json` for MCPs): as folders in the project's `.agents/skills/`, plus the `.claude/skills/`
  bridge for Claude Code, committed (R-8, ADR-0005). This replaces the first answer,
  `.claude/settings.json` (ADR-0004).

## Out of scope

- MCP installation and management (SPEC-0012), beyond the shared catalog file.

## Changelog

- 2026-10-13: open question decided by the user: skills and MCPs install at project scope by
  default, global only when the user asks (R-8, ADR-0004).
- 2026-10-13: R-5, R-8 and the decided question changed to standard locations first: `npx skills`
  into `.agents/skills/` with a bridge copy for Claude Code; the plugin marketplace is optional
  (ADR-0005, which supersedes ADR-0004).
