# Curated catalog of skills and MCPs

senior-mindset ships two short lists of add-ons it may propose: `catalog/skills.json` (agent
skills) and `catalog/mcps.json` (MCP servers). They are curated: every entry was reviewed against
the criteria below and approved by the skill's maintainer one by one. One list serves every project;
the skill picks what fits the task and the stack. Nothing in them is installed without the user's
consent.

## Inclusion criteria

An entry is added only when all of these hold, and the entry's `why` says how:

1. **Official or vendor-maintained**: published by the tool's vendor or by the project that owns
   it. A community project qualifies only with a named maintainer and wide use.
2. **Actively maintained**: a release or a commit in the last six months, and issues answered.
3. **Open licence**: an OSI-approved licence, recorded in `source.license`.
4. **Minimal permissions**: what it reads, writes, runs or sends over the network is stated in
   `permissions`, and it asks for no more than its purpose needs.
5. **Reviewed before inclusion**: its `SKILL.md` (or the server's entry points and install
   script) was read; nothing runs at install time beyond what it states.
6. **Pinned**: `source.ref` and `version` name a release, a commit or a package version, never a
   moving branch, so an install today and an install next month get the same thing. A hosted
   (remote) server cannot be pinned: `version` records the release that was reviewed.
7. **Approved by the maintainer**, entry by entry. Rejected candidates go to `rejected`, with the
   reason, and are not proposed again.

An exception to a criterion is the maintainer's explicit decision, written in the entry's
`exception` field (which criterion, why, and the date). The skill names it when it proposes the
entry, so the user decides knowing it.

Each entry is reviewed again when it is updated, or at least once a year (`reviewed`).

## Entry fields

| Field | Meaning |
|---|---|
| `id`, `name`, `purpose` | Kebab-case id, display name, one line on what it does |
| `recommended` | Listed first in the question and marked "(Recommended)" |
| `proposeWhen.tasks`, `proposeWhen.stack` | Task words and stack signals that make it relevant (`any` for every stack) |
| `source` | Repository, optional path, pinned `ref`, licence |
| `install` | One command per installer or agent, **without scope flags**: `npx-skills` for skills; `claude-code` (and variants) for MCPs |
| `auth` | The secret it needs, if any, and where it goes. Never a value |
| `permissions` | What it can read, write, run or send |
| `version`, `added`, `reviewed` | Pinned version and dates |
| `why` | Why it is in the list, and how it meets the criteria |
| `exception` | Only when a criterion is waived: which one, why, and when the maintainer decided it |

`catalog.schema.json` describes the format. In this repository, `check-catalog.py` validates both
files on every pull request.

## Proposing an entry

- **When:** the task or the project matches an entry's `proposeWhen` (task words in the request or
  the spec, stack signals in the manifests and conventions), the entry is not installed yet, and
  the user has not declined it in this project.
- **How many:** at most three per question, recommended entries first. A closed question
  ([questions.md](questions.md)): each option names the entry, its purpose and what it can access.
  Include "None for now".
- **Consent:** install only what the user picks. A failed or skipped question installs nothing.
- **Recorded:** a declined entry is noted in the project's AGENTS.md conventions
  (`Declined add-ons: …`) so it is not proposed again there.

## Installing: the project first

Every install is for the current project unless the user picks "Global" in the question.

- **Skills:** the entry's `install.npx-skills` command plus `--copy`, at the pinned ref. It writes
  `.agents/skills/<name>/` and the `.claude/skills/<name>/` bridge for Claude Code; both are
  committed, with `skills-lock.json`. Global: `-g` instead of `--copy`.
- **MCP servers:** the agent's own project file, since there is no shared standard. Claude Code:
  the entry's `install.claude-code` command plus `--scope project`, placed before any `--` (it writes `.mcp.json`; Claude
  Code's default scope is `local`, so the flag is always explicit). Global: `--scope user`. Secrets
  go in environment variables, never in a committed file. Details: SPEC-0012.
- **It changes the project**, so it follows hard rule 4: a change notice (files, permissions,
  rollback), a branch, a pull request.
- **A new skill** goes through the collision check of the first-use setup
  ([setup.md](setup.md)) before it is used.
- **Where it is recorded:** project installs in the project's `spec/INVENTORY.md`
  (`name — path — purpose — usage`); global installs in `~/.claude/senior-mindset.md`.

## Updating and removing

- **Update** to a newer pinned version when the catalog entry moves, through a pull request with
  what changed upstream.
- **Remove** an add-on that the project no longer uses (no task in the roadmap needs it, and it has
  not been invoked in a long time): propose it as a change notice, never remove it unasked.
