# PLAN-0009: analyse existing projects and normalise them to the standard pattern

Spec: [SPEC-0009](spec.md)
Status: Draft
Recommended overall: high — Claude Opus 5.5 (reading unknown code and mapping heterogeneous docs is judgment-heavy)

## Context

Depends on PLAN-0008 (change notice). The user's documentation projects follow different patterns; code repos lack inventories. The analysis must be deterministic and verified: nothing invented.

## Design

### Code analysis pipeline (facts first, interpretation second)

1. **Map:** tree without `node_modules`, `dist`, `.venv`…; languages, size, monorepo or not.
2. **Manifests and config:** `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod` → stack,
   dependencies, scripts. Linter/formatter/test/CI/Docker/platform configs → tooling.
3. **Inventory facts**, found with grep, ast-grep or the language's LSP:
   - exported modules and functions;
   - endpoints and framework routes;
   - tables and models (migrations, ORM schema);
   - queues and events;
   - scripts and CLIs;
   - external integrations;
   - environment variables used (names only, never values).
4. **Conventions found:** naming, folder structure, error handling, logging, from code samples
   and linter config → AGENTS.md, even when they differ from skill defaults.
5. **Retroactive ADRs** (`Accepted`, context "found in code"), each with its evidence file.
6. **Health:** tests (count, passing), CI status, outdated or vulnerable dependencies,
   **committed secrets** (alert), TODO/FIXME, obvious dead code.

- Large repos: split by package or folder (one subagent each), then merge.
- Verification: drop or mark "to confirm" any entry whose path or symbol cannot be found.

### Documentation mapping

Existing files are mapped to the standard layout in a table inside the adoption spec
(source → target → action: move / split / merge / archive). Moves use `git mv`.

## Steps

### T-1 onboarding.md — high
- Recommended: high — Claude Opus 5.5 (designs the pipeline and the mapping)
- Branch: `feat/0009-t1-onboarding-reference`
- Do: state detection, six-stage code analysis pipeline, docs mapping table, ASSESSMENT template, verification rule
- Files: + references/onboarding.md
- Done when: AC-1

### T-2 First-use-in-project step — medium
- Recommended: medium — Claude Sonnet 5.5 (wiring into SKILL.md)
- Branch: `feat/0009-t2-onboarding-step`
- Do: run onboarding before kickoff when `## Engineering conventions` is missing and the project is not empty
- Files: ~ SKILL.md
- Done when: AC-1 (flow)

### T-3 Real test: documentation project — high
- Recommended: high — Claude Opus 5.5 (judging a real mapping)
- Branch: `test/0009-t3-docs-project`
- Do: clone one of the user's documentation projects into the scratchpad, run onboarding, review the mapping and the diff (no content lost)
- Files: nothing in the original repo
- Done when: AC-2

### T-4 Real test: code repo (blog) — high
- Recommended: high — Claude Opus 5.5 (verifying an inventory by hand)
- Branch: `test/0009-t4-code-project`
- Do: clone the blog, run onboarding, check every inventory entry (path exists, symbol found), conventions vs linter config, ADR evidence, secrets scan
- Files: nothing in the original repo
- Done when: AC-3, AC-4

### T-5 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0009-t5-release`
- Do: minor bump, docs, changelogs; PR body with `Closes-Spec: SPEC-0009`
- Files: ~ plugin.json, ~ READMEs, ~ CHANGELOGs
- Done when: bot closes spec and plan; plugin update

## Verification

Inventory verification script (paths + grep) run on the blog clone; docs-migration diff shows only moves/splits, no deletions.

## Risks

Hallucinated inventory entries → verification gate. Large repos blow the context → split by package with subagents. Secrets → alert, never copied.

## Out of scope

Fixing the health issues found.

## Changelog

- 2026-10-18: conventions file is AGENTS.md (SPEC-0019)
