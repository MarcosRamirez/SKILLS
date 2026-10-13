<div align="center">

# 🧰 SKILLS

**Plug-and-play superpowers for [Claude Code](https://claude.ai/code).**
Drop a skill in, and Claude learns a new trick. No config hell.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skills-D97757?logo=anthropic&logoColor=white)](https://claude.ai/code)
[![Skills](https://img.shields.io/badge/skills-2-brightgreen)](#-the-skills)
[![Last commit](https://img.shields.io/github/last-commit/MarcosRamirez/SKILLS/master)](https://github.com/MarcosRamirez/SKILLS/commits/master)

[The skills](#-the-skills) · [Install](#-install-in-30-seconds) · [How skills work](#-how-skills-work) · [Contributing](#-contributing)

</div>

---

## ✨ The skills

| | Skill | What it does | |
|---|---|---|---|
| 🧠 | **senior-mindset** | Claude thinks like a human senior engineer before writing a single line | [Docs](skills/senior-mindset/README.md) |
| 🖼️ | **save-image** | Images you paste into Claude Code are saved to disk automatically | [Docs](skills/save-image/README.md) |

### 🧠 senior-mindset

**Claude thinks like a human senior engineer.** Before writing code, it asks the questions
a senior would ask: what problem are we solving, what already exists, what will this cost
to run, how could it break, and will someone understand it in a year. It writes the
spec first, records every important decision with its reasons, reuses before building,
and picks the simplest design that works. It asks about your conventions **once** per
project and remembers them. Work is split into branches and delivered as pull requests that
you merge. On first use, it checks your other skills for conflicting rules and lets you
pick which one wins.

```text
you    › build me a booking app
claude › Before writing code, 4 quick questions (I'll remember the answers):
         stack · database · where you deploy · default branch…
         ✔ ADR-0001..0004 written · CLAUDE.md updated · docs/INVENTORY.md created
         Here's docs/specs/0001-bookings/spec.md: 6 acceptance criteria.
         Approve it and I'll start with the tests.
```

| Without | With senior-mindset |
|---|---|
| Code first, questions never | Spec → design → tasks, approved by you |
| `data2`, `handleStuff()` | Names that explain themselves, in English |
| A new DB helper every session | Checks `docs/INVENTORY.md` and reuses it |
| "Why Postgres?" — nobody knows | `docs/adr/0001-use-postgresql.md` |
| SQL built with string concat | OWASP checklist before every hand-over |
| Code that trusts every input and fills the disk | Guard clauses, resource checks, timeouts and limits by default |
| `console.log` when things break | Structured logs from the first commit |
| One giant commit on `master` | A branch per change, a commit per task, a PR you merge |
| "Which version is in production?" | `0.0.1-alpha.1` → beta → rc → `1.0.0`, numbers computed from commits |

### 🖼️ save-image

**Images you paste into Claude Code are saved to disk automatically.** Writing docs or a
blog post with screenshots? Paste the image and keep writing: no filenames, no export
dialogs, no interruptions.

```text
you    › [pastes screenshot] here's the error I'm getting
you    › any idea what's wrong?
claude › Image saved to ~/Pictures/claude-images/2026-10-12_10-41-07_3_0.png
         The stack trace shows a null `userId` in…
```

## 🚀 Install in 30 seconds

Pick whichever you like. All three work for every skill.

### 1. Ask your agent (easiest)

Paste this into Claude Code, swapping in the skill you want:

> Install the **senior-mindset** skill from https://github.com/MarcosRamirez/SKILLS/tree/master/skills/senior-mindset
> into `~/.claude/skills/senior-mindset`. Copy the whole folder.

### 2. Plugin marketplace (one-click updates)

```text
/plugin marketplace add MarcosRamirez/SKILLS
/plugin install senior-mindset@marcosramirez-skills
/plugin install save-image@marcosramirez-skills
```

Update later with `claude plugin marketplace update marcosramirez-skills`, then
`claude plugin update <skill>@marcosramirez-skills`. Plugins also register their hooks for you.

### 3. Manual

**macOS / Linux**

```bash
git clone --depth 1 https://github.com/MarcosRamirez/SKILLS.git /tmp/skills
cp -r /tmp/skills/skills/senior-mindset ~/.claude/skills/
```

**Windows (PowerShell)**

```powershell
git clone --depth 1 https://github.com/MarcosRamirez/SKILLS.git $env:TEMP\skills
Copy-Item -Recurse $env:TEMP\skills\skills\senior-mindset $HOME\.claude\skills\
```

Skills with hooks (like save-image) need one extra step when installed by hand; it's in their README.

## 🧩 How skills work

A skill is a folder with a `SKILL.md`. Claude reads its short description all the time,
and loads the full instructions only when your request matches. Heavy details live in
`references/` and are read on demand, so skills cost almost nothing until you need them.

```text
.claude-plugin/
  marketplace.json      — makes this repo a plugin marketplace
skills/<name>/
  SKILL.md              — what Claude loads (the behavior)
  README.md             — for humans: setup and usage
  .claude-plugin/       — plugin manifest
  references/           — detail docs, loaded on demand
  scripts/ · hooks/     — hook scripts and their auto-registration
```

## 🤝 Contributing

Got a skill that makes Claude better at something? Open a PR.

- One folder per skill under `skills/<name>/` with a `SKILL.md` and a `README.md`
- Add a `.claude-plugin/plugin.json` and an entry in `.claude-plugin/marketplace.json`
- Run `claude plugin validate .` and `claude plugin validate ./skills/<name> --strict`
- MIT license

## 👋 Author

Made by **Marcos Ramírez**: [marcosramirez.info](https://marcosramirez.info) ·
[blog](https://blog.marcosramirez.info) · [marcosramirez.dev](https://marcosramirez.dev)

If a skill saved you time, a ⭐ helps others find it.
