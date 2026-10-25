# SPEC-0012 tasks

One branch per task, stacked PRs. Executed through PLAN-0012.

- [x] T-1 Verify current `claude mcp` docs; write `references/mcp.md` (AC-1)
- [ ] T-2 MCP flow in `SKILL.md`; headless tests (AC-2, AC-3)
- [ ] T-2b MCP question at kickoff (project scope by default), Context7 recommended and default for
  docs, MCP directories (AC-4, AC-5)
- [ ] T-3 Release (minor), docs, changelogs; last PR carries `Closes-Spec: SPEC-0012`

## Notes (T-1, 2026-10-25)

- Verified in Claude Code's MCP docs: the three scopes and where they are stored, the approval prompt
  for project servers in interactive sessions (headless loads them), `${VAR}` / `${VAR:-default}`
  expansion in `command`, `args`, `env`, `url` and `headers`, options before `--`, `add-json`, `list`,
  `get`, `remove --scope`.
- `claude mcp add-json --scope project` with the catalog's Context7, GitHub and Toolbox commands, in an
  isolated config on Windows Git Bash: all three added, `.mcp.json` holds only variable names, and
  `claude mcp list` shows them pending approval.
- Context7 probed directly: no header and an empty `Bearer ` work anonymously; a literal unset
  `Bearer ${CONTEXT7_API_KEY}` fails every tool call with "Invalid API key". The catalog entry now
  installs with `${CONTEXT7_API_KEY:-}`.
- AC-2 needs a PostgreSQL entry: the official reference server is archived. The user approved MCP
  Toolbox for Databases (Google, Apache-2.0) as recommended for PostgreSQL, connected through a
  read-only role, and rejected Postgres MCP Pro (last release May 2025).
- The seven "Find more MCPs" directories answer (PulseMCP blocks `curl` but serves browsers).
