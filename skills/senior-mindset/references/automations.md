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
| **docs-check** | On every pull request: the living documents have no broken relative links and no link to a superseded ADR | GitHub remote, GitHub Actions, Python 3 on the CI runner | Yes, when the project has docs, specs or ADRs | [docs-check](#docs-check) |

## release-automation

- Templates: `templates/release-automation/` — `on-merge.yml`, `close-specs.sh`, `tag-release.sh`.
- Install: copy them into `.github/workflows/` and `.github/scripts/`, set the default branch,
  list them in `spec/INVENTORY.md`, and test the scripts locally (`DRY_RUN=1`).
- Without it: tag releases by hand, and mark specs Implemented in the next PR (manual fallback
  in [release-automation.md](release-automation.md)).

## docs-check

- What it does: `check-docs.py` reads the living documents and fails (exit 1, one `path:line: message`
  per finding) on a relative link that does not resolve and on a link to an ADR (any `adr/` folder)
  whose `Status:` starts with Superseded. Links in code fences and inline code are skipped; feature
  specs are not checked because they carry history. It is the deterministic half of the impact
  sweep in [adr.md](adr.md).
- Requires: Python 3 on the CI runner and a GitHub remote. Recommended when the project has docs,
  specs or ADRs.
- Templates: `templates/docs-check/` — `check-docs.py` and `checks.yml`.
- Install: copy `check-docs.py` to `.github/scripts/check-docs.py` and `checks.yml` to
  `.github/workflows/checks.yml` (the script finds the project root two folders up), list them in
  `spec/INVENTORY.md`, and run `python3 .github/scripts/check-docs.py` once before the first merge.
  Default documents: `README.md`, `AGENTS.md`, `CLAUDE.md`, `docs/**/*.md`, `spec/constitution/*.md`,
  `spec/INVENTORY.md`, `spec/POSTMORTEMS.md`. To change them, set `DOCS_CHECK_FILES` (comma-separated
  globs) in the workflow step, or pass files as arguments.
- Turn it off: delete `checks.yml` (and the script), and update the `Automations:` line in CLAUDE.md.

## Rules for every automation

- **Copied from the skill's templates**, never written from scratch, so every project gets the
  same, tested version.
- **Defensive:** untrusted input only through env vars, ids validated, idempotent, minimal permissions.
- **Tested before the first merge**, including in a runner-like environment (no git identity,
  `GIT_CONFIG_GLOBAL=/dev/null`): a local machine hides what a fresh runner lacks.
- **Installed through a PR**, like any other change.
