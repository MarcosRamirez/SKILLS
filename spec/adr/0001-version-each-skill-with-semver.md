# ADR-0001: Version each skill with SemVer in its plugin.json

Status: Accepted
Date: 2026-10-12

## Context

Skills are installed as plugins with `/plugin install`. `claude plugin update` only
delivers a new release when the plugin's `version` changes; if `version` is omitted, every
commit counts as a release. Each skill evolves at its own pace.

## Options considered

1. **One version for the whole repo** — simple, but bumps every skill when one changes.
2. **No version (commit SHA)** — zero effort, but every typo fix is pushed to users as an update and versions carry no meaning.
3. **SemVer 2.0 per skill in `plugin.json`** — meaningful versions, updates only when a skill changes; requires discipline on every change.

## Decision

We choose **option 3**. `plugin.json` holds the version; the `SKILL.md` frontmatter mirrors it.
Rules for PATCH / MINOR / MAJOR are in CLAUDE.md. New skills start at `0.0.1-alpha.1`.

## Consequences

- Positive: users get updates exactly when a skill changes, and the number says how big the change is.
- Negative: forgetting a bump silently withholds the change from plugin users. Mitigated by the CLAUDE.md rule.
- Verified on 2026-10-12: installed 1.0.0 from GitHub, pushed 1.1.0, `claude plugin update` moved to 1.1.0.
