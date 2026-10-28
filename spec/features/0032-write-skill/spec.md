# SPEC-0032: write-skill — skills that fit the standard

Type: feature
Status: Approved
Date: 2026-10-28
Approved by: the user, 2026-10-28, chose the name `write-skill`, a validator with CI tests, the
standard's 500-line cap and one pull request
Plan: low — Claude Opus 4.6 (new skill, validator and tests)

## Problem

The repo ships two skills and explains how to contribute one (AGENTS.md, README "Contributing"), but
nothing tells the agent how to write a skill *well*. The rules that make a skill cheap and
predictable live in the standard ([agentskills.io](https://agentskills.io)) and in review
experience: a description that triggers, a body that stays short, one level of references, scripts
instead of prose. Without them a new skill drifts into a documentation dump: `SKILL.md` loaded on
every activation with thousands of tokens, references nobody reads, and the same example in two
files. The repo has no `skill-creator` of its own and the curated catalog has no entry for one.

## Requirements

- R-1 `skills/write-skill/` with `SKILL.md`, `README.md`, `references/` and `scripts/`, following the
  Agent Skills standard. The description carries triggers in English and Spanish.
- R-2 Budgets explicit and enforceable. Errors: `SKILL.md` over 500 lines or over 5000 estimated
  tokens, description over 1024 characters, a non-SemVer version, broken links, nested references.
  Warnings (this repo's stricter target): `SKILL.md` over 100 lines or 800 words, description over
  500 characters, a reference over 150 lines, a reference the body never links, leftover `TODO`.
- R-3 The body covers, in the order the work happens: whether the skill is worth writing, the name,
  the description, the body, progressive disclosure, scripts and assets, validation, publishing.
  The standard's fields and limits live in a reference, not in the body.
- R-4 `scripts/validate-skill.py`: standard library only, no network, `file:line: error|warning`
  output, exit 1 on errors, `--strict` turns warnings into errors, `--json` for tooling.
- R-5 The skill validates itself: `scripts/validate-skill.py` on `skills/write-skill/` reports no
  errors and no warnings, and `npx skills-ref validate` agrees.
- R-6 Publishing follows this repo's rules: entry in `.claude-plugin/marketplace.json` at
  `0.0.1-alpha.1`, root README, inventory and roadmap in the same change.

## Acceptance criteria

- AC-1 `skills/write-skill/SKILL.md` passes the validator with no warnings and states the budgets
  and the one-level rule explicitly.
- AC-2 `tests/ci/test-validate-skill.sh` covers every rule with at least one failing fixture, one
  CRLF case and this checkout; it runs from `tests/ci/run.sh` and in CI, and passes.
- AC-3 `python3 .github/scripts/check-versions.py`, `check-docs.py`, `check-catalog.py`,
  `bash tests/ci/run.sh` and `claude plugin validate .` are green.
- AC-4 The skill appears in the README table, its own section, the plugin install list and the
  `skills-3` badge, plus its rows in `spec/INVENTORY.md` and this spec's row in the roadmap.
- AC-5 The skill is installable from the published tag:
  `npx skills add MarcosRamirez/SKILLS#write-skill-v0.0.1-alpha.1 --skill write-skill -a claude-code opencode --copy`.

## Out of scope

- A headless scenario: `tests/headless/lib.sh` pins `senior-mindset` in the plugin and project copies;
  generalising it is SPEC-0013.
- An entry in the curated catalog (`skills/senior-mindset/catalog/`): this is a first-party skill.
- Changes to `senior-mindset`, which keeps proposing third-party skills and keeps its own install
  checks.

## Changelog

- 2026-10-28: written at the user's request, from the standard's research and the OpenCode install
  issue (#111).
