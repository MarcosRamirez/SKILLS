# Automations catalog

Automations senior-mindset can install in a project. At kickoff, ask which ones to install
(one AskUserQuestion, `multiSelect: true`), with the recommended ones listed first and marked
"(Recommended)". Record the answer in CLAUDE.md (`Automations: …`) and do not ask again in
that project. If a requirement is missing (e.g. no GitHub remote), say so and leave that one out.

Adding a new automation = adding a row here, a section below, and its templates under
`templates/<automation>/`. The kickoff question picks it up from this file.

| Automation | What it does | Requires | Recommended | Details |
|---|---|---|---|---|
| **release-automation** | On merge: specs named in `Closes-Spec:` become Implemented (bot commit); new versions get a tag and a GitHub Release | GitHub remote, GitHub Actions | Yes | [release-automation.md](release-automation.md) |

## release-automation

- Templates: `templates/release-automation/` — `on-merge.yml`, `close-specs.sh`, `tag-release.sh`.
- Install: copy them into `.github/workflows/` and `.github/scripts/`, set the default branch,
  list them in `docs/INVENTORY.md`, and test the scripts locally (`DRY_RUN=1`).
- Without it: tag releases by hand, and mark specs Implemented in the next PR (manual fallback
  in [release-automation.md](release-automation.md)).

## Rules for every automation

- **Copied from the skill's templates**, never written from scratch, so every project gets the
  same, tested version.
- **Defensive:** untrusted input only through env vars, ids validated, idempotent, minimal permissions.
- **Tested before the first merge**, including in a runner-like environment (no git identity,
  `GIT_CONFIG_GLOBAL=/dev/null`): a local machine hides what a fresh runner lacks.
- **Installed through a PR**, like any other change.
