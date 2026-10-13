# SPEC-0015 design

- **One-way mirror** keeps a single source of truth: specs, tasks and plans in the repo. The
  sync recomputes each issue from the files and overwrites title, body and labels.
- **Finding issues:** search by the hidden marker in the body (`gh issue list --search` or the API),
  never by title, which humans may edit.
- **Sub-issues:** check the official docs first (REST/GraphQL sub-issues API, `gh` support) and
  pin the approach in this design before writing the script.
- **State mapping:**

| Spec / plan state | Issue state | Label |
|---|---|---|
| Draft | open | `status:draft` |
| Approved / Ready | open | `status:approved` |
| In progress | open | `status:in-progress` |
| Implemented / Done | closed (by the bot) | `status:implemented` |

- **Where it runs:** `on-merge` (after `close-specs.sh`), and on demand by the AI after it writes
  a spec, plan or tasks. Disabled → the step exits before any API call.
- **Issue → spec:** reads the issue through `gh` into variables, writes a Draft spec whose Problem
  section quotes the issue, adds the marker to the issue, and links both ways.
- **Board:** created with `gh project` only when the user picks it; items added by the sync.
