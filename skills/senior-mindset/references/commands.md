# Commands

senior-mindset reacts to **intents**, not to fixed strings. Each row is one command: the example
phrases are illustrations in a few languages, never a closed list. Recognise the intent in
whatever language the user writes, and answer in that language.

This file is the single source of the command list: `help` renders it, the README links it.
**Adding a command means adding a row here** (and, if it needs more than a line, a section below
or in the reference it points to).

| Command | Example phrases | What it does | Specified in |
|---|---|---|---|
| **help** | "help", "what can you do?", "¿qué puedes hacer?", "ayuda", "qu'est-ce que tu sais faire ?" | Lists the commands with one example each and summarises the current configuration. Read-only | Section "help" below |
| **status** | "status", "project status", "estado del proyecto", "où en est le projet ?" | Specs and plans with their states, open pull requests, current version and tags, installed automations. Read-only | Section "status" below |
| **list plans** | "list plans", "lista los planes", "quels plans peut-on lancer ?" | Plans with state and tier, marking which can run now. Read-only | Section "list plans" below |
| **run plan** | "run plan 0008", "ejecuta el plan 0008", "lance le plan 0008" | Checks the spec is approved (asks if it is Draft), then executes the plan step by step with branches and PRs | [plans.md](plans.md) |
| **release** | "release the beta", "release 2.1", "saca la versión 2.1", "publie la version 2.1" | Checks something was implemented since the last tag, proposes the version, opens the release PR | [versioning.md](versioning.md) |
| **reconfigure** | "reconfigure senior-mindset", "reconfigura senior-mindset" | Runs the first-use collision setup again and rewrites `~/.claude/senior-mindset.md` | [setup.md](setup.md) |
| **update senior-mindset** | "update senior-mindset", "actualiza senior-mindset", "mets à jour senior-mindset" | Installs the latest release tag over the project's copies on a branch and opens a PR with that version's changelog; a global copy is updated in place after an OK | [setup.md](setup.md#8-update-senior-mindset) |
| **install or remove an automation** | "add the docs check", "quita la automatización de releases", "désactive le check des docs" | Copies an automation's templates into the project (or deletes them) through a PR, and updates the `Automations:` line | [automations.md](automations.md) |

**Not commands.** The update message ("senior-mindset updated to vX.Y.Z") is shown by the skill
itself the first time it runs after an update; there is nothing to ask for ([setup.md](setup.md)).
Building, fixing and scripting are the skill's normal work, not commands.

## Read-only commands: help, status, list plans

These three share the same rules:

- **Read-only.** Run only commands that read (`ls`, `cat`, `grep`, `git tag`, `git log`,
  `gh pr list`). Create, edit, move, commit, branch, install or push nothing.
- **No kickoff, no spec, no approval gate.** Asking for help or status is not a request to build
  anything: skip Steps 0, 1 (the proposals), 2 and 3, and do not offer a change notice. The
  hard rules are about changing things, and these commands change nothing.
- **Answer in the user's language**, whatever it is, including headings and state names you
  translate. File names, commands and the state keywords as written in the files (`Draft`,
  `Approved`, `In progress`, `Implemented`) stay as they are.
- **Missing pieces degrade, they do not fail.** No `spec/` folder, no remote, no `gh`, no
  `~/.claude/senior-mindset.md`: say what is missing in one line and show the rest.
- Keep it short: a table or a list, not an essay.

### help

Shown when the user asks what the skill can do, how to use it, or for its commands.

1. The commands from the table above, one line each: the command, one example phrase **in the
   user's language**, and what it does.
2. **Configuration summary**, read from the files (never guessed):
   - `~/.claude/senior-mindset.md`: the skill version it was written for and the winner per area
     (git flow, commit format, changelog/versioning, specs, review, tests). If the file is
     missing, say the first-use setup is still pending.
   - the project's `AGENTS.md` `## Engineering conventions` (or `CLAUDE.md` if it is not migrated
     yet): stack, default branch, versioning, automations, N/A items. If the project has none,
     say the kickoff has not run and that a new feature would start it.
3. End with one line on how to ask for more ("status", "list plans").

### status

Shown when the user asks where the project stands.

1. **Specs and plans.** Read the `Status:` line of every `spec/features/NNNN-*/spec.md`,
   `spec/features/NNNN-*.md`, `spec/fixes/NNNN-*.md` (and `spec/fixes/NNNN-*/spec.md`), their plans
   (`plan.<tier>.md`, or the `## Plan` of a single file) and the rows of `spec/constitution/roadmap.md`.
   Show one row per spec: id, title, type (feature or fix), spec state, plan state and tier. If a
   file and the roadmap disagree, show the file's state and flag the mismatch.
2. **Open pull requests**, with `gh pr list --state open` when `gh` is installed and the repository
   has a GitHub remote. Otherwise say they could not be read, and why in a few words.
3. **Version and tags.** The version in the manifest (`SKILL.md` `metadata.version`, `plugin.json`,
   `package.json`… whichever the project uses), the latest tags (`git tag --sort=-creatordate`),
   and the commits since the last tag when that is cheap (`git log --oneline <tag>..HEAD`).
4. **Automations installed.** Compare the `Automations:` line of the conventions with the files
   that exist (`.github/workflows/on-merge.yml`, `.github/workflows/checks.yml`…). Name any that
   is listed but missing, or present but not listed.

### list plans

Shown when the user asks which plans exist or what can be run.

1. One row per plan: `PLAN-NNNN`, title, state (`Draft`, `Ready`, `In progress`, `Done`), overall
   tier and the spec's state. Plans live in `plan.<tier>.md` or the `## Plan` of a single file
   ([plans.md](plans.md)).
2. **Mark which can run now**, with the roadmap rule: the spec is `Approved` (or its plan is
   `Ready` or `In progress`), every spec in its `Depends on` column is `Implemented`, and the
   plan is not `Done`. List the runnable ones first, in roadmap order.
3. For every plan that cannot run, give the reason in a few words ("spec still Draft", "waits for
   SPEC-0021"). A Draft spec can still be run after asking for approval (see run plan), so say
   that, but do not mark it as runnable.
4. Do not start any plan: running one is the separate **run plan** command.
