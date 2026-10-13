# SPEC-0010: environments: local, preview, staging, production

Status: Draft
Date: 2026-10-13
Approved by: (empty until the user explicitly approves)

## Problem

Apps built with the skill have no defined environments, no rule for which code reaches which
environment, and no separation of secrets and data.

## Requirements

- R-1 Default environments: **local** (developer machine), **preview** (per-PR, ephemeral,
  when the platform provides it), **staging** (pre-production, mirror of production),
  **production**. **development** (shared integration server) only for teams.
- R-2 Mapping: own branch → local; PR → preview; merge to default branch → staging;
  release tag `vX.Y.Z` → production.
- R-3 Configuration through environment variables (12-factor), `.env.example` committed,
  secrets and databases separate per environment.
- R-4 The same build artifact is promoted from staging to production, never rebuilt.
- R-5 Migrations run staging first, then production; backward compatible.

## Acceptance criteria

- AC-1 `references/environments.md` with the table, mapping, config, secrets, data, migrations and parity rules.
- AC-2 Kickoff asks which environments the project has (with the default recommended) and records an ADR.
- AC-3 A deploy-per-environment automation is evaluated for the automations catalog (added or explicitly deferred).

## Out of scope

- Writing deploy pipelines for every platform.
