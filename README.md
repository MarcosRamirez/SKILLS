# SKILLS

> Plug-and-play skills for [Claude Code](https://claude.ai/code).
> Drop a skill in, get new superpowers — no config hell.

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)

## Skills

### 🖼️ save-image

Writing docs or a blog post and need to paste screenshots?
Paste the image in Claude Code, keep writing — it saves to disk automatically.
No filenames, no export dialogs, no interruptions.

→ [README](skills/save-image/README.md) · [Spec](skills/save-image/SKILL.md)

## How to install a skill

1. Copy `skills/<name>/SKILL.md` to `~/.claude/skills/<name>/SKILL.md`
2. Register any hooks listed in the skill's README
3. That's it

## Repo structure

```
skills/<name>/
  SKILL.md    — behavior spec (what Claude loads)
  README.md   — setup & usage
  scripts/    — hook scripts
src/hooks/    — shared hook scripts
```

## Contributing

Got a skill? Open a PR.
Each skill needs a `SKILL.md`, a `README.md`, and a MIT license header.
