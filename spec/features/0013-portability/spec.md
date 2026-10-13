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
- R-2 AGENTS.md is already the single source of project instructions (SPEC-0019). This spec covers the
  other agents' own config files (`.cursorrules`, `.github/copilot-instructions.md`, `GEMINI.md`…):
  point them to AGENTS.md or merge them into it, never overwrite.
- R-3 Install instructions for each supported agent, based on its official documentation. Skills
  install the same way everywhere, with `npx skills` into `.agents/skills/` (ADR-0005).
  The per-agent part covers bridges, MCP files and agent-specific settings.
- R-4 Model recommendations already work per tier (SPEC-0007); verify the open-model rows on real tasks.

## Acceptance criteria

- AC-1 Equivalence table and portable wording across `SKILL.md` and references.
- AC-2 Other agents' config files are detected and pointed to or merged into AGENTS.md (no overwrite); AGENTS.md itself follows SPEC-0019.
- AC-3 Install docs for OpenCode, Codex, Gemini CLI and Cursor, each verified against official docs.
- AC-4 Real run with OpenCode + a local Ollama model on a small task in a test project; findings fixed.

## Out of scope

- Agent-specific features beyond what the skill needs.
