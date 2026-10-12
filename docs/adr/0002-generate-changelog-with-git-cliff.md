# ADR-0002: Generate the changelog with git-cliff

Status: Accepted
Date: 2026-10-12

## Context

The repo needs a `CHANGELOG.md`, newest changes on top, kept current. Commits already follow
Conventional Commits with a leading emoji (git-workflow skill) and state the decision.

## Options considered

1. **git-cliff** — existing deterministic tool; builds the changelog from commits.
2. **A custom script** — full control, but reinvents git-cliff.
3. **The AI edits the file on every change** — flexible wording, but costs tokens, drifts, and can be forgotten.

## Decision

We choose **git-cliff**, with the `cliff.toml` template from senior-mindset's
`references/changelog.md` (strips the leading emoji, groups by Keep a Changelog sections,
newest first). Regenerate with `npx git-cliff -o CHANGELOG.md` after merging to `master`.

## Consequences

- Positive: zero AI tokens, identical output on every run, never out of sync with history.
- Negative: changelog quality depends on commit subjects; the file must not be hand-edited.
- This is the same approach senior-mindset recommends for the apps it builds, so the repo dogfoods it.
