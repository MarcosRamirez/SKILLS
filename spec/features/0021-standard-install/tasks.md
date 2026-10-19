# SPEC-0021 tasks

One branch per task, stacked PRs. Executed through PLAN-0021.

- [x] T-1 Manifest data in marketplace.json, version in `metadata.version`, tag script and version check (R-7, AC-6)
- [x] T-2 Verify `npx skills` (canonical copy, `--copy`, tags, update), then both READMEs (R-1…R-3, AC-1, AC-2)
- [x] T-3 First-use detection of global, project and duplicate installs, with headless tests (R-4, AC-3)
- [ ] T-4 "update senior-mindset" opens a PR from the latest release tag (R-5, AC-4)
- [ ] T-5 This repository: published copy and bridge, global plugin disabled here, AGENTS.md note (R-6, AC-5)
- [ ] T-6 Minor release with `Closes-Spec: SPEC-0021`

## Test results (T-2, 2026-10-19)

Scratch project (empty git repo) and an isolated Claude Code config (`CLAUDE_CONFIG_DIR` in the
scratchpad, no credentials copied). `skills@1.7.2`, OpenCode 1.19.2, Claude Code with
`--setting-sources project,local`. The user's `~/.claude/senior-mindset.md` kept its SHA-256
(`e2245cbe…`) and no global skill folder changed. The `npx skills` checks of SPEC-0024 T-1 (tags,
`update` pinned to the tag, `--copy`) still hold; these runs cover what they left open.

| Check | Result |
|---|---|
| `npx skills add MarcosRamirez/SKILLS --skill senior-mindset -a claude-code opencode --copy -y` from `master` (after T-1) | wrote `.agents/skills/senior-mindset/` and `.claude/skills/senior-mindset/` plus `skills-lock.json`; neither copy holds `.claude-plugin/` any more |
| OpenCode loads the project install (`.claude/` moved aside, so only `.agents/skills/` is there) | `opencode run` (free model `opencode/deepseek-v4.1-flash-free`) listed `senior-mindset` from the project's `.agents/skills/senior-mindset/SKILL.md` (AC-2) |
| Claude Code loads the project install | `claude -p --model haiku` listed `senior-mindset` (plain name, from `.claude/skills/`) (AC-2) |
| `/plugin` install from a local copy of the marketplace, no `plugin.json` in the skill | installed `senior-mindset@marcosramirez-skills` 2.8.0, files in the cache, version taken from the marketplace entry |
| `SKILL.md` bumped to 2.8.1, marketplace entry left at 2.8.0, then `marketplace update` + `plugin update` | "already at the latest version (2.8.0)": **no update** |
| marketplace entry bumped to 2.8.1 too | "updated from 2.8.0 to 2.8.1"; the cached `SKILL.md` and README carry the change (AC-6) |

Reading:
- `claude plugin update` compares only the marketplace entry's `version`. A release that bumps
  `SKILL.md` alone reaches nobody on `/plugin`, which is the failure `check-versions.py` (T-1) now
  blocks on every pull request.
- R-2 (install from the latest release tag): the `npx skills` paths already recommend pinning a tag.
  The "ask your agent" prompt and the manual copy pointed at `master`; both READMEs now point them at
  the latest `senior-mindset-vX.Y.Z` tag. save-image keeps its own Claude Code-only instructions.
- Codex was not run (not installed); OpenCode reads the same `.agents/skills/` folder.

## Test results (T-3, 2026-10-19)

Headless suite, Claude Code 2.1.303, model `claude-opus-5-5`, prompt "help" in a small committed
Python project, question tool failing (no UI). The suite's plugin plays the global copy;
`SCENARIO_LOAD=project` runs without it. A per-project disable was first checked without the model:
`"enabledPlugins": {"senior-mindset@marcosramirez-skills": false}` in one project's
`.claude/settings.local.json` turned the user-scope plugin off there (`claude plugin list --json`:
`enabled: false`) and left it on in another project.

| Scenario | Run | Result | Cost |
|---|---|---|---|
| `install-project-only` | 1 | PASS 7/7: no install or duplicate question, nothing changed | 0.23 USD |
| `install-global-only` | 1 (first wording) | FAIL 7/8: "help" answered without the install check; the model read the help exception as "Step 0a only when the setup file is missing" | 0.23 USD |
| `install-global-only` | 2 (rule now runs every project, before help and status, and ends with one line when it cannot ask) | PASS 8/8 | 0.23 USD |
| `install-duplicate` | 1 and 2 | 7/8 each: both answers named the two copies and proposed "turn off the global plugin for this project only (recommended)"; the check only matched "disabl". The check now also accepts "turn off", "switch off" and "deactivate", and both recorded answers pass it | 0.29 + 0.25 USD |

No run installed, disabled or uninstalled anything, wrote `.claude/settings.local.json` or committed.
The user's `~/.claude/senior-mindset.md` kept its SHA-256 in every run (`e2245cbe…`).
