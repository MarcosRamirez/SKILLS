# Model tiers: which agent and model for which work

Plans name a **tier**, never a model, so a new model release means editing only this table.

| Tier | Use for | Examples of work |
|---|---|---|
| **high** | Judgment and design | Architecture, specs, migrations of data or structure, security-sensitive changes, debugging hard failures, reviewing |
| **medium** | Normal implementation | Features from an approved plan, tests, refactors with a clear target |
| **low** | Mechanical work | Renames, formatting, docs updates, version bumps, applying a known pattern many times |

## Tier → agent and model

Last verified: 2026-10-13. Claude models from Anthropic's model list; open models from the
[Ollama library](https://ollama.com/search?c=tools) (tool-capable models). Check both sources
before updating this table.

| Tier | Claude Code | Open models (OpenCode, Codex, … via Ollama) |
|---|---|---|
| high | Claude Opus 5.5 (`claude-opus-5-5`) | Cloud: `deepseek-v4-pro`, `glm-5.3`, `kimi-k2.7-code`, `mistral-large-4` · Local: `mistral-medium-3.5` (128b) |
| medium | Claude Sonnet 5.5 (`claude-sonnet-5-5`) | Local: `qwen3.8` (27b), `nemotron3` (33b), `granite4.1` (30b), `ornith` (35b) |
| low | Claude Haiku 5.5 (`claude-haiku-5-5`) | Local: `granite4.1` (8b), `ornith` (9b), `lfm2.5` (8b) · Cloud: `deepseek-v4.1-flash`, `glm-5.3-flash` |

Notes:
- Open-model rows are candidates by size and tool support, not benchmark rankings. Try them
  on a real task before relying on a model for a tier.
- Local models need hardware to match: ±1 GB of RAM/VRAM per billion parameters at 8-bit, roughly half at 4-bit.
- When in doubt between two tiers, pick the higher one for planning and the lower one for execution.
