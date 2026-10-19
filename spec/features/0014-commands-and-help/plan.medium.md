# PLAN-0014: documented commands, help and status

Spec: [SPEC-0014](spec.md)
Status: In progress
Recommended overall: medium — Claude Sonnet 5.5 (documentation plus small read-only behaviours)

## Context

Commands exist today as phrases scattered across `SKILL.md`, `setup.md`, `plans.md` and `versioning.md`.
This plan gathers them into one documented list, adds help, status and list plans, and checks
whether plugins can expose slash aliases.

## Design

### Commands (initial set)

| Command | Phrases | What it does | Specified in |
|---|---|---|---|
| help | "help", "what can you do?", "ayuda", "¿qué puedes hacer?" | Commands + one example each + configuration summary | commands.md |
| status | "status", "project status", "estado del proyecto" | Specs/plans with state, open PRs, version/tags, automations | commands.md |
| list plans | "list plans", "lista los planes" | Plans with state and tier; runnable ones first | plans.md |
| run plan | "run plan 0008", "ejecuta el plan 0008" | Approval check, then execute the plan | plans.md |
| reconfigure | "reconfigure senior-mindset", "reconfigura senior-mindset" | Re-run the collision setup | setup.md |
| release | "release the beta", "release 2.1", "saca la versión 2.1" | Release process | versioning.md |

Phrases above are examples in two languages; the skill matches the intent in any language and
answers in the user's language.

### Welcome message with help (extends SPEC-0006)

```text
✅ senior-mindset vX.Y.Z installed and configured.
I can: write specs and plans before code, run a plan ("run plan 0008"), show project status,
release versions, and keep your conventions. Ask "what can you do?" for the full list.
Made by Marcos Ramírez — https://blog.marcosramirez.info/sobre-mi/
```

Rendered in the user's language. At most four lines.

### Decisions

- `commands.md` is the single source; help renders it, README links it.
- status is read-only: it runs only read commands (`ls`, `grep`, `git tag`, `gh pr list` when available)
  and changes nothing.
- Read-only commands bypass the kickoff and spec flow: asking for help is not a request to build anything.
- Slash aliases: verify in official docs whether plugins can ship commands, and how they are named,
  before adding them.

### Slash aliases: decision (T-3, AC-4)

**No aliases are added.** Checked on 2026-10-19 against the official docs:

- [Skills](https://code.claude.com/docs/en/skills): "Custom commands have been merged into skills."
  A file in `commands/` and a skill both create `/name`; command files are the older format and the
  docs say to prefer a skill. A plugin skill is invoked as `/plugin-name:skill-name`.
- [Plugins overview](https://code.claude.com/docs/en/plugins): a plugin holds skills, agents, hooks and
  MCP servers; its skill "runs as /my-plugin:review".

So the skill is already a slash command: `/senior-mindset:senior-mindset` from the plugin and
`/senior-mindset` from a project copy, and the text after it ("/senior-mindset help", "/senior-mindset
status") reaches the skill as the request, which the commands already recognise by intent in any
language. Thin aliases such as `/senior-mindset:help` would need a `commands/` folder (or extra
skill folders) inside the skill, and:

- ADR-0005 makes the Agent Skills standard and `npx skills` the primary channel, and the standard has
  no commands. A Claude Code-only folder inside the skill would ship to every agent that cannot use
  it, and the aliases would exist only for plugin installs, so behaviour would differ by channel.
- `commands/` is the legacy format, and another skill folder for each alias adds three more names and
  descriptions to Claude's context on every turn for what the intent matching already does.
- ADR-0006 keeps the version and everything the skill needs in `SKILL.md`, with no Claude Code-only
  files inside the skill folder.

Revisit if Claude Code or the standard adds a way to declare aliases in `SKILL.md` frontmatter.

## Steps

### T-1 commands.md and links — medium
- Recommended: medium — Claude Sonnet 5.5 (collecting and documenting what exists)
- Branch: `feat/0014-t1-commands-reference`
- Do: write the commands table (intent, example phrases, effect, source; examples are not a closed list); add a short "Commands" section to `SKILL.md`; list commands in the skill README
- Files: + references/commands.md, ~ SKILL.md, ~ skills/senior-mindset/README.md, ~ spec/INVENTORY.md
- Done when: AC-1

### T-2 help, status, list plans — medium
- Recommended: medium — Claude Sonnet 5.5 (read-only behaviours, clear spec)
- Branch: `feat/0014-t2-help-status`
- Do: define each behaviour in commands.md (read-only, no kickoff); headless tests with `--plugin-dir`: "¿qué puedes hacer?", "what can you do?" and a French equivalent in an empty folder (answers in each language), "status" in this repo
- Files: ~ references/commands.md, ~ SKILL.md
- Done when: AC-2, AC-2b, AC-3 (status output matches the spec and plan files)

### T-2b Welcome message with help — low
- Recommended: low — Claude Haiku 5.5 (small wording change)
- Branch: `feat/0014-t2b-welcome-help`
- Do: add the "what I can do" summary and help hint to the install welcome in SKILL.md Step 0a and setup.md, in the user's language, keeping the credit
- Files: ~ SKILL.md, ~ references/setup.md
- Done when: AC-2c

### T-3 Slash aliases — medium
- Recommended: medium — Claude Sonnet 5.5 (docs check + small manifest change)
- Branch: `feat/0014-t3-slash-aliases`
- Do: check the official plugin docs for shipping commands; if supported, add thin aliases (help, status, plans); validate the plugin
- Files: maybe + skills/senior-mindset/commands/*.md, ~ plugin docs
- Done when: AC-4

### T-4 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0014-t4-release`
- Do: minor bump, READMEs, changelogs; PR body with `Closes-Spec: SPEC-0014`
- Files: ~ plugin.json, ~ SKILL.md frontmatter, ~ CHANGELOGs
- Done when: the bot closes spec and plan; `claude plugin update`

## Verification

Headless runs for help and status; status cross-checked against `grep ^Status` of specs and plans; `claude plugin validate --strict`.

## Risks

Help triggering the kickoff or the approval flow → read-only commands are explicitly exempt.
Status relying on `gh` → degrade gracefully when `gh` is missing or there is no remote.

## Out of scope

New behaviours beyond help, status and list plans.
