# SPEC-0009: analyse existing projects and normalise them to the standard pattern

Type: feature
Status: Implemented
Implemented: 2026-10-19, PR #101
Date: 2026-10-13
Approved by: the user, 2026-10-13, "implementa todas las fases, una a una, con subagentes"

## Problem

The user has several projects in the documentation phase, each following a different pattern,
and projects with code but no inventory. One reason for senior-mindset is to make every project
follow the same pattern, built from what actually exists, not from assumptions.

## Requirements

- R-1 On first use in a project without `## Engineering conventions`, detect its state (empty /
  docs only / code / code + docs) and what it is (stack, structure, tests, CI).
- R-2 Write `spec/ASSESSMENT.md`: what exists, which pattern it follows, gaps against the
  standard, risks and health.
- R-3 Documentation projects: map existing docs onto the standard layout
  (`spec/features/NNNN-slug/{spec.md,plan.<tier>.md,tasks.md}`, `spec/fixes/`, `spec/adr/`, INVENTORY,
  and the project instructions per SPEC-0019 instead of CLAUDE.md), recognising common patterns (spec-kit, loose documents, markdown wikis).
- R-4 Code projects: **deterministic analysis of the real code** feeds INVENTORY, conventions,
  retroactive ADRs with evidence, and health. Every inventory entry is verified.
- R-5 The adoption is proposed as a spec ("adopt senior-mindset"), goes through the change notice
  (SPEC-0008), on a branch, keeps history (`git mv`) and deletes nothing: what does not fit goes to `spec/archive/`.

## Acceptance criteria

- AC-1 `references/onboarding.md` with state detection, the analysis pipeline and the docs mapping.
- AC-2 On a synthetic documentation project built by the headless suite (spec-kit specs, an ADR
  folder, a PRD and loose notes; no code): ASSESSMENT + adoption spec + migration commits; every
  source file appears in the mapping, and nothing is deleted (`git diff -M --diff-filter=D` is empty).
- AC-3 On a synthetic code repository built by the headless suite (routes, a model and its
  migration, environment variables, a payment integration, linter config, tests, CI): INVENTORY
  where every entry's path exists and its name is found by grep; conventions cite the linter
  config; each ADR cites its evidence.
- AC-4 Committed secrets, if any, are reported immediately and never copied into docs (the suite
  plants a fake password and a tracked `.env`, and checks that no written file and no answer holds
  their values).

## Out of scope

- Fixing the health problems found (they become their own specs).

## Changelog

- 2026-10-14: aligned with ADR-0005/0006 (SPEC-0024)
- 2026-10-19: AC-2 and AC-3 run on synthetic projects built by the headless suite (the user, during T-3).
