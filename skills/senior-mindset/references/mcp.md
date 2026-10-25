# MCP servers

MCP servers give the agent tools: a browser, a database, a docs service, an issue tracker. They
also get access to things that matter: credentials, data, a logged-in session. This reference covers
when the skill proposes one, how it installs it without leaking a secret, how much access it gets,
and how it is kept tidy. The candidates come from `catalog/mcps.json`, curated under the rules of
[catalog.md](catalog.md).

## When a server is proposed

- **At the kickoff:** one multi-select question with the entries of `catalog/mcps.json` that fit
  the project, recommended ones first and marked "(Recommended)", plus "None for now". Servers
  already available (global, or already in `.mcp.json`) are shown as installed, not proposed.
  The "Find more MCPs" directories go under the question (below). For each pick, a second
  question: "This project (Recommended)" or "Global (all your projects)".
- **Projects set up before this question existed** are asked once, the next time the skill works
  in them.
- **During the work**, when a task matches an entry (Step 3d of `SKILL.md`), at most three at a time.
- **The answer is recorded**, even "none": `MCP servers: context7, toolbox-postgres` (or
  `MCP servers: none`) in the project's `## Engineering conventions`, so it is not asked again.
- A failed or skipped question installs nothing. Each entry's `permissions`, `auth` and any
  `exception` are shown with it, so the user knows what it can reach before choosing.

## Installing in Claude Code

The scope is always explicit, because Claude Code's default (`local`) is private to one user in one
project, which is neither of the two choices the user is offered:

| Choice | Scope | Stored in | Shared |
|---|---|---|---|
| This project (default) | `--scope project` | `.mcp.json` at the project root, committed | with everyone who clones it |
| Global | `--scope user` | `~/.claude.json` | no; every project of this user |

- Use the entry's `install.claude-code` command with `--scope project` added, placed before any
  `--` (options after `--` go to the server). Entries written as JSON use
  `claude mcp add-json --scope project <name> '<json>'`.
- Adding a server to `.mcp.json` changes the project: change notice, branch, pull request (hard
  rule 4). Global installs touch only the user's own configuration and need the user's explicit
  pick; they are recorded in `~/.claude/senior-mindset.md`.
- The first time Claude Code meets a project server in an interactive session, it asks the user to
  approve it (`claude mcp reset-project-choices` resets those answers). Headless runs load them
  without asking.
- Other agents keep MCP servers in their own project file; there is no shared standard yet.

## Secrets never reach a file

- `.mcp.json` holds variable names, never values. Claude Code expands `${VAR}` and `${VAR:-default}`
  in `command`, `args`, `env`, `url` and `headers` when it starts the server.
- **Single quotes** around the JSON or the header in the install command, so the shell does not
  expand `${VAR}` and write the real value into the file.
- **Optional keys use `${VAR:-}`.** A missing variable without a default stays as literal text: with
  Context7, `Authorization: Bearer ${CONTEXT7_API_KEY}` sent as text fails with "Invalid API key",
  while `Bearer ${CONTEXT7_API_KEY:-}` falls back to anonymous use (checked on 2026-10-25).
- Credential names that Claude Code reserves (such as `ANTHROPIC_API_KEY`) read as empty in remote
  `url` and `headers`; pick a name of the server's own.
- The values live in the user's environment or secret store. The skill tells the user which
  variable to set and never asks for the value in the conversation.
- **Check after every install**, before committing; it prints nothing when `.mcp.json` is clean:

  ```bash
  grep -n -E 'AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36}|sk-[A-Za-z0-9_-]{20,}|ctx7sk[A-Za-z0-9_-]+|Bearer [A-Za-z0-9._-]{20,}|://[^/:@ ]+:[^@ ]+@' .mcp.json | cut -d: -f1,2
  ```

## Least privilege

Give each server the smallest access that does the job, and say what it can reach in the change notice.

- **Databases:** a dedicated read-only role, never the application's or an admin account. For
  PostgreSQL (the user runs it and keeps the password in their environment):

  ```sql
  CREATE ROLE agent_readonly LOGIN PASSWORD :'password';
  GRANT CONNECT ON DATABASE app TO agent_readonly;
  GRANT USAGE ON SCHEMA public TO agent_readonly;
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO agent_readonly;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO agent_readonly;
  ```

  Point the server at a development or staging database, not production, unless the user asks.
- **Tokens:** fine-grained, scoped to the repositories and permissions the work needs, with an expiry.
- **Browsers:** a clean profile, not one where the user is logged in to personal accounts.
- **Write access** (a database role that can write, a token that can push) only when a task needs it,
  as its own question with the reason.

## Documentation lookups

"Official documentation first" works in this order:

1. **Context7, when it is installed:** `resolve-library-id` for the library, then `query-docs` for
   the version the project uses (from its manifest or lock file).
2. **The official website** (WebFetch) when Context7 does not have the library or the version, or
   its answer looks out of date.
3. **Cite the source** (library id or URL) whenever the answer is not obvious.

Context7 is an external service: queries carry library names and general questions, never
secrets, credentials, private code or customer data.

## Managing installed servers

- **List:** `claude mcp list` (all scopes), `claude mcp get <name>`, and the project's `.mcp.json`.
- **Record:** each project server has a line in `spec/INVENTORY.md`
  (`name — .mcp.json — purpose — main tools`).
- **Update:** when the catalog entry moves to a newer pinned version, change it through a pull
  request with what changed upstream.
- **Remove:** `claude mcp remove <name> --scope project` (or `--scope user`), with a change notice.
  Never remove a server unasked.
- **Review routine:** before a release, or when the user asks, list the project's servers and
  propose removing those no current task needs or that have not been used for a long time.

## Find more MCPs

Shown under the kickoff question. Official sources first:

- [Official MCP Registry](https://registry.modelcontextprotocol.io)
- [Official reference servers](https://github.com/modelcontextprotocol/servers)
- [Docker MCP Catalog](https://hub.docker.com/mcp)
- [MCP.Directory](https://mcp.directory)
- [Smithery](https://smithery.ai)
- [Glama](https://glama.ai/mcp/servers)
- [PulseMCP](https://www.pulsemcp.com/servers)

A server found there is not installed straight away: it is checked against the catalog criteria
([catalog.md](catalog.md)) first. One the user wants to keep goes into the catalog through a pull
request in the skill's repository.
