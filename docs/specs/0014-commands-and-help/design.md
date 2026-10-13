# SPEC-0014 design

## Commands (initial set)

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

## Welcome message with help (extends SPEC-0006)

```text
✅ senior-mindset vX.Y.Z installed and configured.
I can: write specs and plans before code, run a plan ("run plan 0008"), show project status,
release versions, and keep your conventions. Ask "what can you do?" for the full list.
Made by Marcos Ramírez — https://blog.marcosramirez.info/sobre-mi/
```

Rendered in the user's language. At most four lines.

## Decisions

- `commands.md` is the single source; help renders it, README links it.
- status is read-only: it runs only read commands (`ls`, `grep`, `git tag`, `gh pr list` when available)
  and changes nothing.
- Read-only commands bypass the kickoff and spec flow: asking for help is not a request to build anything.
- Slash aliases: verify in official docs whether plugins can ship commands, and how they are named,
  before adding them.
