# SKILLS

A collection of [Claude Code](https://claude.ai/code) skills.

## Skills

| Skill | Description |
|-------|-------------|
| [save-image](skills/save-image/) | Auto-saves images pasted in VS Code Claude Code to disk |

## Installation

Each skill lives in its own directory under `skills/`. See the skill's `README.md` for setup instructions.

## Structure

```
skills/
  <skill-name>/
    README.md   — usage & setup
    SKILL.md    — behavior spec loaded by Claude
src/
  hooks/        — hook scripts referenced by skills
```
