# SPEC-0009: analyse existing projects and normalise them to the standard pattern

Status: Draft
Date: 2026-10-13
Approved by: (empty until the user explicitly approves)

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
  (`spec/features/NNNN-slug/{spec,design,tasks}.md`, `spec/adr/`, `spec/features/`, INVENTORY,
  CLAUDE.md), recognising common patterns (spec-kit, loose documents, markdown wikis).
- R-4 Code projects: **deterministic analysis of the real code** feeds INVENTORY, conventions,
  retroactive ADRs with evidence, and health. Every inventory entry is verified.
- R-5 The adoption is proposed as a spec ("adopt senior-mindset"), goes through the change notice
  (SPEC-0008), on a branch, keeps history (`git mv`) and deletes nothing: what does not fit goes to `spec/archive/`.

## Acceptance criteria

- AC-1 `references/onboarding.md` with state detection, the analysis pipeline and the docs mapping.
- AC-2 On a clone of one of the user's documentation projects: ASSESSMENT + adoption spec + migration PR; no content lost (diff check).
- AC-3 On a clone of a code repo (e.g. the blog): INVENTORY where every entry's path exists and its
  symbol is found by grep; conventions match the linter config; each ADR cites its evidence.
- AC-4 Committed secrets, if any, are reported immediately and never copied into docs.

## Out of scope

- Fixing the health problems found (they become their own specs).
