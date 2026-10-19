<div align="center">

# 🧰 SKILLS

**Plug-and-play superpowers for AI coding agents.**
Skills follow the [Agent Skills](https://agentskills.io) standard. Built and tested on
[Claude Code](https://claude.ai/code); other agents are planned ([SPEC-0013](spec/features/0013-portability)).
Drop a skill in, and your agent learns a new trick. No config hell.

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
pick which one wins. Ask "what can you do?" (in any language) for its commands: help, status,
list plans, run plan, release and more ([full list](skills/senior-mindset/references/commands.md)).

```text
you    › build me a booking app
claude › Before writing code, 4 quick questions (I'll remember the answers):
         stack · database · where you deploy · default branch…
         ✔ 4 ADRs written · conventions saved in AGENTS.md · spec/INVENTORY.md created
         Here's spec/features/0001-bookings/spec.md: 6 acceptance criteria.
         Approve it and I'll start with the tests.
```

| Without | With senior-mindset |
|---|---|
| Code first, questions never | Spec → design → tasks, approved by you |
| `data2`, `handleStuff()` | Names that explain themselves, in English |
| A new DB helper every session | Checks `spec/INVENTORY.md` and reuses it |
| "Why Postgres?" — nobody knows | `spec/adr/0001-use-postgresql.md` |
| SQL built with string concat | OWASP checklist before every hand-over |
| No mission, the roadmap lives in the chat | `spec/constitution/`: mission, tech stack and a roadmap the bot keeps current |
| Specs closed by hand, release tags forgotten | Specs close themselves on merge, releases tag themselves |
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

Skills follow the [Agent Skills](https://agentskills.io) standard, so the first path is the standard
one: `npx skills`, into your project. Pick whichever you like.

### 1. `npx skills` (recommended)

```bash
# Claude Code plus agents that read .agents/skills/ (Codex, OpenCode...)
npx skills add MarcosRamirez/SKILLS --skill senior-mindset -a claude-code codex --copy

# Claude Code only
npx skills add MarcosRamirez/SKILLS --skill senior-mindset -a claude-code

# For all your projects instead of this one: add -g
npx skills add MarcosRamirez/SKILLS --skill senior-mindset -a claude-code -g
```

- The command writes `.agents/skills/senior-mindset/` (the standard location) and
  `.claude/skills/senior-mindset/` (the bridge Claude Code reads today), plus `skills-lock.json`.
- `--copy` writes real folders instead of symlinks. Commit `.agents/skills/`, `.claude/skills/` and
  `skills-lock.json` and your team and cloud sessions get the skill too.
- **Pin a release tag.** The default branch can hold changes that are not released yet. Pick a
  version on the [Releases page](https://github.com/MarcosRamirez/SKILLS/releases):

  ```bash
  npx skills add MarcosRamirez/SKILLS#senior-mindset-vX.Y.Z --skill senior-mindset -a claude-code codex --copy
  ```

- `npx skills update` keeps a tag-pinned install on its tag. To move to a new version, run `add`
  again with the new tag.

### 2. Ask your agent

Paste this into your agent, swapping in the skill you want:

> Install the **senior-mindset** skill from https://github.com/MarcosRamirez/SKILLS/tree/master/skills/senior-mindset
> into this project's `.agents/skills/senior-mindset/`. Copy the whole folder. If your agent does not
> read `.agents/skills/` (Claude Code does not yet), also copy it to `.claude/skills/senior-mindset/`.
> Ask me before installing it globally.

### 3. Manual

Copy the folder into `.agents/skills/` (and into `.claude/skills/` for Claude Code).

**macOS / Linux**

```bash
git clone --depth 1 https://github.com/MarcosRamirez/SKILLS.git /tmp/skills
mkdir -p .agents/skills .claude/skills
cp -r /tmp/skills/skills/senior-mindset .agents/skills/
cp -r /tmp/skills/skills/senior-mindset .claude/skills/
```

**Windows (PowerShell)**

```powershell
git clone --depth 1 https://github.com/MarcosRamirez/SKILLS.git $env:TEMP\skills
New-Item -ItemType Directory -Force .agents\skills, .claude\skills | Out-Null
Copy-Item -Recurse $env:TEMP\skills\skills\senior-mindset .agents\skills\
Copy-Item -Recurse $env:TEMP\skills\skills\senior-mindset .claude\skills\
```

Skills with hooks (like save-image) need one extra step when installed by hand; it's in their README.

### 4. Claude Code plugin marketplace (Claude Code only)

```text
/plugin marketplace add MarcosRamirez/SKILLS
/plugin install senior-mindset@marcosramirez-skills
/plugin install save-image@marcosramirez-skills
```

Update later with `claude plugin marketplace update marcosramirez-skills`, then
`claude plugin update <skill>@marcosramirez-skills`. Plugins also register their hooks for you,
which is why save-image needs this path.

> **Known duplicate.** If senior-mindset is also installed globally as a plugin, Claude Code lists
> both `senior-mindset` (the project copy) and `senior-mindset:senior-mindset` (the plugin).
> Keep one. Detecting it comes with SPEC-0021.

## 🧩 How skills work

A skill is a folder with a `SKILL.md`. The agent reads its short description all the time,
and loads the full instructions only when your request matches. Heavy details live in
`references/` and are read on demand, so skills cost almost nothing until you need them.

```text
.claude-plugin/
  marketplace.json      — makes this repo a Claude Code plugin marketplace
skills/<name>/
  SKILL.md              — what the agent loads (the behavior)
  README.md             — for humans: setup and usage
  .claude-plugin/       — Claude Code plugin manifest
  references/           — detail docs, loaded on demand
  scripts/ · hooks/     — hook scripts and their auto-registration
spec/                   — this repo's own specs: constitution/, features/, fixes/, adr/,
                          INVENTORY.md, POSTMORTEMS.md
.github/                — workflows/ (close specs, tag releases) · scripts/
tests/headless/         — headless suite: real `claude -p` runs with checks, before each release
```

## 🤝 Contributing

Got a skill that makes Claude better at something? Open a PR.

- One folder per skill under `skills/<name>/` with a `SKILL.md` and a `README.md`
- Put the version in `metadata.version` of the `SKILL.md` frontmatter and add an entry with the same
  version in `.claude-plugin/marketplace.json` (no `.claude-plugin/` inside the skill folder)
- Run `claude plugin validate .` and `python3 .github/scripts/check-versions.py`
- MIT license

## 👋 Author

Made by **Marcos Ramírez**: [marcosramirez.info](https://marcosramirez.info) ·
[blog](https://blog.marcosramirez.info) · [marcosramirez.dev](https://marcosramirez.dev)

If a skill saved you time, a ⭐ helps others find it.
