# First-use setup: collisions with other skills

senior-mindset imposes rules (branch per change, pull requests, commit cadence, changelog,
versioning, specs) that other installed skills may contradict. A skill cannot run anything
at install time, so this check runs **the first time the skill is used**, once per user.

## When it runs

- `~/.claude/senior-mindset.md` does not exist → run the full setup before anything else.
- The user says "reconfigure senior-mindset" → run it again.
- In Step 1, an installed skill overlaps an area and is not listed in the file → ask only
  about that skill and area, then update the file.
- The file's `senior-mindset version` is older than the skill's `metadata.version` → show the
  update message once (step 5) and record the new version. No questions.
- In every project, the install check of section 7 runs until its question is answered there
  (or `Install: global` is recorded). It is part of Step 0a, so it also runs before help and status.

## 1. Inventory (cheap: names and descriptions only)

- The list of available skills already in your context (name + description).
- On disk, frontmatter only (first ±15 lines) of:
  - `~/.claude/skills/*/SKILL.md`
  - `~/.claude/plugins/cache/*/*/*/SKILL.md` and `~/.claude/plugins/cache/*/*/*/skills/*/SKILL.md`
  - `.claude/skills/*/SKILL.md` in the current project
- Conventions in `~/.claude/CLAUDE.md` (git, commits, changelog, testing).

Never read whole skill bodies for this: it wastes context.

## 2. Classify overlaps by area

| Area | senior-mindset's rule | Typical colliding skills |
|---|---|---|
| Git flow | Branch per change, PR to the default branch, the user merges, stacked PRs | git workflow skills, "commit and push" skills |
| Commit format | Emoji + Conventional Commits, English, imperative | commit message skills |
| Changelog / versioning | git-cliff, SemVer from `0.0.1-alpha.1`, tags | release skills, changelog generators |
| Specs / planning | `spec/features/NNNN/` spec → design → tasks, approval gate | spec-kit style skills, planning skills |
| Code review | Self-review checklist (OWASP, cost, readability) | review skills |
| Tests | Unit always, TDD for critical logic, k6 for load | testing skills |

An area collides only when another skill gives **contradictory** instructions (e.g. "merge
locally, never open PRs" vs "always open a PR"). Complementary skills are not collisions:
for example, a Cloudflare skill and senior-mindset's platform choice coexist.

## 3. Ask, one question per colliding area (AskUserQuestion, max 4 per round)

Options, each with a one-line consequence:

1. **senior-mindset** (Recommended) — what its rule enforces.
2. **<other skill name>** — what that skill does instead.
3. **Combine** — only when it makes sense, e.g. "commit format from <other>, branch and PR flow from senior-mindset".

Areas without a collision are not asked about: they use senior-mindset.

## 4. Write `~/.claude/senior-mindset.md`

```markdown
# senior-mindset configuration

Written by senior-mindset's first-use setup. Edit freely, or say "reconfigure senior-mindset".

- Date: 2026-10-13
- senior-mindset version: 1.3.0
- Skills seen: git-workflow, caveman-commit, cloudflare, …

## Decisions

| Area | Winner | Notes |
|---|---|---|
| Git flow | senior-mindset | PRs to master, user merges |
| Commit format | senior-mindset | |
| Changelog / versioning | senior-mindset | no collision |
| Specs / planning | senior-mindset | no collision |
| Code review | senior-mindset | no collision |
| Tests | senior-mindset | no collision |

## Install

- Install: not asked           (project | global | not asked; section 7)
- Kept global in: (none)       (projects where the user declined a project copy)
- Duplicates kept in: (none)   (projects where the user kept a global and a project copy)
```

Precedence when working in a project:
1. The project's AGENTS.md `## Engineering conventions`.
2. `~/.claude/senior-mindset.md`.
3. senior-mindset defaults.

When a decision names another skill, follow that skill for that area, and senior-mindset
for everything else.

**Git flow won by senior-mindset while another git skill is installed:** the other skill may load
alone for a git-only request and senior-mindset never sees it. So also write the choice into the
project's `## Engineering conventions` as the "Git rules that always hold" block (text in
[project-layout.md](project-layout.md)). In a project that already has conventions, add it once
as a change notice on its own branch. The other skill is not edited or uninstalled.

## 5. Welcome and update messages (once each, never more)

Right after writing the file for the first time, greet the user in their language:

```text
✅ senior-mindset vX.Y.Z installed and configured.
I can: write specs and plans before code, run a plan ("run plan 0008"), show project status,
release versions, and keep your conventions. Ask "what can you do?" for the full list.
Made by Marcos Ramírez — https://blog.marcosramirez.info/sobre-mi/
```

At most four lines, all in the user's language (translate the phrases, including the example
question). The second and third lines are the short "what I can do" summary and the hint for the
**help** command ([commands.md](commands.md)); the author credit always stays.

When the skill finds a newer version than the one recorded in the file (one line plus the credit,
no command summary):

```text
🔄 senior-mindset updated to vX.Y.Z — see what's new in its CHANGELOG.md.
By Marcos Ramírez — https://blog.marcosramirez.info/sobre-mi/
```

Then update `senior-mindset version` in the file, so the message does not repeat.

These are the only two moments: not on every use, not at the end of tasks. A credit that shows
up every time is noise.

## 6. When you cannot ask (headless, no AskUserQuestion)

- Use senior-mindset defaults, but **no push and no pull requests**: integrate with a local
  `git merge --no-ff`. Remote actions need a decision the user never gave.
- Do not write `~/.claude/senior-mindset.md`, so the setup runs at the next interactive use.
- Mention in your final message that the setup is pending. Do not show the welcome message:
  it belongs to the moment the file is written.
- Install check (section 7): detect, but install, disable, uninstall and record nothing. Say in the
  final message which copies you found and that the decision is pending.

## 7. Where the skill loads from (each project)

senior-mindset can be installed globally (a Claude Code plugin, `~/.claude/skills/`,
`~/.agents/skills/`) and in the project (`.agents/skills/senior-mindset/` plus the
`.claude/skills/senior-mindset/` bridge for Claude Code). A project copy travels with the
repository: the team and cloud sessions get the same version. Two copies at once load twice, or the
global one hides the project one.

### Detect (cheap: one command)

1. **Where this copy loads from:** the base directory shown when the skill loaded. Inside the current
   project → a project copy. Anywhere else (`~/.claude/plugins/cache/…`, `~/.claude/skills/`,
   `~/.agents/skills/`, a `--plugin-dir`) → a global copy.
2. **Project copies:** `ls -d .agents/skills/senior-mindset .claude/skills/senior-mindset 2>/dev/null`.
3. **A second senior-mindset in your skills list:** a plain `senior-mindset` next to a namespaced one
   (`senior-mindset:senior-mindset`) means Claude Code loads both.
4. When there are two copies, read `metadata.version` from both `SKILL.md` frontmatters.

### Decide

| Situation | Question (closed, [questions.md](questions.md)) |
|---|---|
| Project copy only | None |
| Global copy only, and the file says `Install: global` or lists this project in `Kept global in` | None |
| Global copy only, nothing recorded | "Install it in this project (Recommended)": the team and cloud sessions get the same version, pinned to a release · "Keep it global": every project shares one copy |
| Global plugin and a project copy, this project not in `Duplicates kept in` | "Disable the global plugin in this project (Recommended)" · "Uninstall the global plugin" · "Keep both" |
| Global folder copy and a project copy, this project not in `Duplicates kept in` | "Remove the global copy (Recommended)" · "Keep both (the global copy wins)" |

Name the versions in the question when the copies differ.

### Act on the answer

- **Install it in this project.** It changes the project, so it follows hard rule 4: change notice,
  branch, pull request. Install the latest release, never the default branch:
  `npx skills add MarcosRamirez/SKILLS#senior-mindset-vX.Y.Z --skill senior-mindset -a claude-code codex --copy`
  (the highest tag of `git ls-remote --tags https://github.com/MarcosRamirez/SKILLS 'senior-mindset-v*'`).
  Commit `.agents/skills/`, `.claude/skills/` and `skills-lock.json`. The global copy is now a
  duplicate: offer to disable it here in the same notice. Record `Install: project`.
- **`Install: project` recorded, and a project without a copy:** offer the install once, in the
  change notice of the first change there. Declined → add the project path to `Kept global in`.
- **Keep it global.** Record `Install: global`. Not asked again, in any project.
- **Disable the global plugin in this project.** Merge `"enabledPlugins": { "<plugin id>": false }`
  into `.claude/settings.local.json` (local scope, not committed; keep every other key). The plugin
  id is `senior-mindset@<marketplace>`, from `claude plugin list --json` or from the cache path
  `plugins/cache/<marketplace>/senior-mindset/<version>`. Other projects keep the plugin, and the
  project copy loads alone from the next session.
- **Uninstall the global plugin.** Warn first: every project without its own copy loses the skill.
  Only after an explicit OK: `claude plugin uninstall <plugin id>`.
- **Remove the global copy** (a folder). A folder copy cannot be disabled per project, and in Claude
  Code a personal skill wins over a project skill with the same name. Same warning, then
  `npx skills remove senior-mindset -g`, or delete the folder after the OK.
- **Keep both.** Add the project path to `Duplicates kept in`. Not asked again in this project.

Never install, disable, uninstall or remove anything without the answer, and never touch other
skills or plugins.
