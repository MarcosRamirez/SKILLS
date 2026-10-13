# SPEC-0012 design

- Official docs first: verify `claude mcp add` flags and the `.mcp.json` format before writing the reference.
- Secrets: `${ENV_VAR}` references in `.mcp.json`; values in the user's environment or secret store.
- Review routine: at release time or on request, list MCPs not used in the last N sessions and propose removal.
