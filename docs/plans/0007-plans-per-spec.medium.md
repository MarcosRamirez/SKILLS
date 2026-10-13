# PLAN-0007: a plan per spec, with the recommended agent and model

Spec: [SPEC-0007](../specs/0007-plans-per-spec/spec.md)
Status: In progress
Recommended overall: medium — Claude Sonnet 5.5 (well-specified documentation and a small script change)

## Context

Implemented while writing this very plan: `references/plans.md`, `references/models.md`, the Plan step in `SKILL.md`, and `close-specs.sh` marking plans Done. This plan is the example of the format, and the bot sets it to Done when the 1.8.0 release merges.

## Steps

### T-1 Plans capability in the skill — medium
- Recommended: medium — Claude Sonnet 5.5 (templates and wording, no design risk)
- Branch: `feat/0007-t1-plans-per-spec`
- Do: write plans.md and models.md (check Ollama's library for names); add Step 3c and the trigger; extend close-specs.sh to mark plans Done; validate the plan before touching the spec
- Files: + references/plans.md, + references/models.md, ~ SKILL.md, ~ sdd.md, ~ project-layout.md, ~ close-specs.sh, ~ workflows
- Done when: AC-1…AC-4; close-specs tests: spec + plan, idempotent, no plan, duplicate plan leaves nothing changed

### T-2 Roadmap specs and plans — high
- Recommended: high — Claude Opus 5.5 (planning six features is judgment work)
- Branch: `docs/0007-t2-roadmap-plans`
- Do: write Draft specs 0008–0013 (three files each) and plans 0007–0013 with tiers as filename suffix
- Files: + docs/specs/0008…0013/, + docs/plans/0007…0013.*.md
- Done when: AC-5; every plan links to an existing spec

### T-3 Release 1.8.0 — low
- Recommended: low — Claude Haiku 5.5 (mechanical bump and changelogs)
- Branch: `chore/0007-t3-release-1-8-0`
- Do: bump plugin.json + frontmatter, regenerate changelogs, PR body with `Closes-Spec: SPEC-0007`
- Files: ~ plugin.json, ~ SKILL.md, ~ CHANGELOG.md files
- Done when: AC-6 after merge: bot marks SPEC-0007 Implemented and this plan Done

## Verification

close-specs.sh tests in a scratch repo; `claude plugin validate --strict`; post-merge: bot commit, tag `senior-mindset-v1.8.0`, Release, `claude plugin update`.

## Risks

The bot commit touching two files with a malformed plan status → the script validates before writing and fails without changes.

## Out of scope

Executing plans 0008–0013.
