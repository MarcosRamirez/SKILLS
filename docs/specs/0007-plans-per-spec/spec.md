# SPEC-0007: a written plan per spec, with the recommended agent and model

Status: Approved
Date: 2026-10-13
Approved by: the user, 2026-10-13, approving the plan in conversation ("implementa lo primero lo de los planes").

## Problem

Specs say what and why, and tasks list the work, but nothing written says *how* to execute
it, or which agent and model fit each step. The user wants to say "run plan X" and have it
executed.

## Requirements

- R-1 Each spec has a plan in `docs/plans/NNNN-<slug>.<tier>.md`, with the same number and slug as its spec and the overall tier (`high`/`medium`/`low`) as a filename suffix.
- R-2 A plan holds context, one step per task with its recommended tier and agent/model, verification, risks and out-of-scope.
- R-3 A tier table maps tiers to concrete agents and models: Claude and open models via Ollama.
- R-4 "Run plan X" executes a plan: approval check, `In progress`, branches and PRs, `Closes-Spec:` on the last PR.
- R-5 The plan becomes `Done` automatically when its spec closes on merge.

## Acceptance criteria

- AC-1 `references/plans.md` (template, naming, lifecycle, "run plan X") and `references/models.md` (tier table, dated, from official sources).
- AC-2 `SKILL.md` has a Plan step before implementation and triggers on "run plan X" / "ejecuta el plan X".
- AC-3 `close-specs.sh` also marks `docs/plans/NNNN-*.md` as `Done` (idempotent, works without a plan), and the workflows commit it.
- AC-4 `sdd.md`, `project-layout.md`, READMEs, inventory and CLAUDE.md updated.
- AC-5 The roadmap's pending steps exist as Draft specs 0008–0013 with Ready plans, plus plan 0007 as an example.
- AC-6 Merging the 1.8.0 release marks SPEC-0007 Implemented and PLAN-0007 Done via the bot.

## Out of scope

- Executing plans 0008–0013 (each is its own approval).
