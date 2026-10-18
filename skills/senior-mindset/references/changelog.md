# Changelog

Every project has a `CHANGELOG.md` at the root, kept up to date, **newest changes on top**.
Format follows [Keep a Changelog](https://keepachangelog.com): an `## [Unreleased]`
section first, then one section per released version with its date.

## How: generate it, don't hand-write it

| Option | Verdict |
|---|---|
| **git-cliff** (existing deterministic tool) | ✅ **Default.** Builds the changelog from Conventional Commits. Zero AI tokens, identical output on every run, never out of sync with history. |
| A script written for the project | ❌ Reinvents git-cliff. Breaks the "reuse before creating" rule. |
| The AI edits the file on every change | ⚠️ **Fallback only.** It costs tokens on every change, the wording drifts, and it can be forgotten. |

The changelog is only as good as the commit subjects. The git rules already require
subjects that state the decision ("add password reset", not "update auth.ts"), so the
generated changelog reads well without extra work.

## Setup (kickoff, projects only)

1. Install git-cliff: `npx git-cliff`, `pip install git-cliff`, `cargo install git-cliff`,
   `brew install git-cliff` or `scoop install git-cliff`. In JS projects add it as a dev dependency.
2. Add `cliff.toml` at the root (template below).
3. Generate: `git cliff -o CHANGELOG.md`.
4. JS projects: add `"changelog": "git-cliff -o CHANGELOG.md"` to `package.json` scripts.
5. Record it in AGENTS.md `## Engineering conventions` (`Changelog: git-cliff`) and in `spec/INVENTORY.md`.

## Keeping it up to date

- **After the user merges a PR:** regenerate with `git cliff -o CHANGELOG.md` on the next
  work branch (or in the release PR) and commit it there (`🔧 chore: update changelog`, or
  the type the git convention uses for chores). Never commit it on the default branch.
  Full regeneration is idempotent, so running it twice changes nothing.
- **On release:** `git cliff --tag vX.Y.Z -o CHANGELOG.md` as part of the release process in
  [versioning.md](versioning.md), which also covers stages, the check that something was
  implemented ("nothing to release" otherwise), the next version and tagging.
- Do **not** use `--unreleased --prepend` repeatedly: it duplicates entries. Regenerate instead.
- The file is generated: do not hand-edit it, because the next run overwrites the edit. To
  change an entry, fix it at the source (write better commit subjects from now on).

## cliff.toml template

Tested with git-cliff 2.x. It strips the leading emoji (`✨ feat(auth): …` →
`feat(auth): …`), groups by Keep a Changelog sections, skips internal chores and merge
commits, and sorts newest first.

**Every entry has a date.** Released versions get a dated heading from their tag
(`## [1.2.0] - 2026-10-12`). Entries still in `[Unreleased]` show their own commit date
(`- **auth:** Add password reset (2026-10-12)`). Dated sections exist only once releases are
tagged, so tag every release ([versioning.md](versioning.md)).

**Monorepo or several packages in one repo:** generate one changelog per package with
`git cliff --include-path "packages/<name>/**" --tag-pattern "<name>-v.*" -o packages/<name>/CHANGELOG.md`
and tags like `<name>-v1.2.0`. Put each tag on the release merge commit (the one that bumps
that package's version). A tag on a commit that touches no file in the include path is
filtered out, and that release disappears from the changelog.

```toml
[changelog]
header = """
# Changelog

All notable changes to this project are documented here, newest first.
Generated from the commit history with git-cliff: do not edit by hand.
"""
body = """
{% if version %}## [{{ version | trim_start_matches(pat="v") }}] - {{ timestamp | date(format="%Y-%m-%d") }}{% else %}## [Unreleased]{% endif %}
{% for group, commits in commits | group_by(attribute="group") %}
### {{ group | striptags | trim | upper_first }}

{% for commit in commits %}- {% if commit.scope %}**{{ commit.scope }}:** {% endif %}{{ commit.message | upper_first }}{% if not version %} ({{ commit.committer.timestamp | date(format="%Y-%m-%d") }}){% endif %}
{% endfor %}{% endfor %}
"""
trim = false

[git]
conventional_commits = true
filter_unconventional = true
commit_preprocessors = [
  # strip a leading emoji so "✨ feat: x" parses as Conventional Commits
  { pattern = '^[^a-zA-Z]+\s*', replace = "" },
]
commit_parsers = [
  { message = "^feat", group = "<!-- 0 -->Added" },
  { message = "^fix", group = "<!-- 1 -->Fixed" },
  { message = "^(refactor|perf)", group = "<!-- 2 -->Changed" },
  { message = "^docs", group = "<!-- 3 -->Documentation" },
  { message = "^revert", group = "<!-- 4 -->Reverted" },
  { message = "^(test|chore|ci|build|style)", skip = true },
]
sort_commits = "newest"
```

Breaking changes (`feat!:` or a `BREAKING CHANGE:` footer) can be highlighted by adding
`{% if commit.breaking %}**BREAKING** {% endif %}` in the body template.

## Fallback: the AI maintains it

Use this only when git-cliff is not an option: the user declines the tool, or the commits
do not follow Conventional Commits.

- In the same commit as each significant change, add one line under `## [Unreleased]`,
  in the right group (`### Added`, `### Changed`, `### Fixed`, `### Removed`, `### Security`).
- New lines go **at the top** of their group. Read only the head of the file, not the whole thing.
- Write for users, not developers: what changed for them, not which files were touched.
- On release, rename `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD` and open a new empty `## [Unreleased]` above it.
