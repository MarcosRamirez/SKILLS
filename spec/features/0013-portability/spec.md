# SPEC-0013: portable to other agents and open models

Status: Draft
Date: 2026-10-13
Approved by: (empty until the user explicitly approves)

## Problem

senior-mindset is written for Claude Code. The user wants it to work in other agents
(OpenCode, Codex, Gemini CLI, Cursor…) and with open models, including local ones via Ollama.

## Requirements

- R-1 Follow the open Agent Skills format; remove hard dependencies on Claude Code-only tools,
  using wording with an equivalence table (e.g. "ask the user — AskUserQuestion in Claude Code").
- R-2 Generate `AGENTS.md` next to CLAUDE.md (or have one import the other), so non-Claude agents get the project conventions.
- R-3 Install instructions for each supported agent, based on its official documentation.
- R-4 Model recommendations already work per tier (SPEC-0007); verify the open-model rows on real tasks.

## Acceptance criteria

- AC-1 Equivalence table and portable wording across `SKILL.md` and references.
- AC-2 AGENTS.md handling in the kickoff and in existing projects (no overwrite).
- AC-3 Install docs for OpenCode, Codex, Gemini CLI and Cursor, each verified against official docs.
- AC-4 Real run with OpenCode + a local Ollama model on a small task in a test project; findings fixed.

## Out of scope

- Agent-specific features beyond what the skill needs.
