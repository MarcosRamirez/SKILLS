# SPEC-0023: versions go up only when something is implemented

Type: fix
Status: Draft
Date: 2026-10-13
Approved by: (empty until the user explicitly approves)
Plan: low — Claude Haiku 5.5 (a written rule and two small checks)
Depends on: SPEC-0022 (the bot closes `spec/fixes/` only once SPEC-0022 is implemented)

## Spec

**Problem.** A version must describe what users can actually run. Writing, editing or approving a
spec changes nothing that runs, so it must never move a version. This holds today, checked on
2026-10-13: every bump from 1.1.0 to 2.1.0 shipped implemented changes, and the specs written since
2.1.0 did not touch the version. But the rule is not written anywhere and nothing enforces it.

**Current behaviour**
- WHEN a project built with the skill has only `docs:` commits (specs, plans, ADRs) since its last
  tag and the user asks for a release, THEN the release step proposes the version that
  `git cliff --bumped-version` prints. The git-cliff docs only define fix → PATCH, feat → MINOR and
  breaking → MAJOR, and say nothing about docs-only commits, so a PATCH with nothing implemented
  may be proposed.
- WHEN a skill's version is bumped in this repository with no other change in `skills/<name>/` since
  its last tag, THEN `tag-skill-releases.sh` tags it and creates a Release anyway.

**Expected behaviour**
- WHEN only specs, plans, ADRs, the roadmap or other docs-only commits exist since the last tag, THEN
  the skill SHALL say "nothing to release" and SHALL NOT propose a version.
- WHEN a skill's version is bumped with no implemented change in its folder since its last tag, THEN
  `tag-skill-releases.sh` SHALL refuse to tag it and name the reason.

**Unchanged behaviour**
- WHEN implemented changes exist, THEN the bump SHALL CONTINUE TO follow SemVer: feat → MINOR,
  fix → PATCH, breaking → MAJOR.
- WHEN files inside `skills/<name>/` change, THEN that skill's version SHALL CONTINUE TO be bumped in
  its release, as CLAUDE.md requires.
- WHEN a release PR is merged, THEN the bot SHALL CONTINUE TO create the tag and the GitHub Release.
- Existing tags SHALL CONTINUE TO exist untouched.

**Reproduction**
1. Apps: in a scratch repository, tag `v0.1.0`, add one `📖 docs` commit that only adds a spec, then
   run `git cliff --bumped-version`. Record what it prints.
2. This repository: in a scratch clone, bump `skills/<name>/.claude-plugin/plugin.json` without any
   other change since the skill's last tag, then run `DRY_RUN=1 bash .github/scripts/tag-skill-releases.sh`.
   It reports that it would tag.

**Root cause.** The rule is implicit. The release step trusts the version calculator, and the tag
script only checks that a tag for the version does not exist yet.

**Fix**
- `references/versioning.md` and the release step in `SKILL.md`: before proposing a version, check
  that the commits since the last tag include implementation. That means `feat`, `fix`, `perf`,
  `refactor` or `!` commits that touch code, not only docs, specs, tests, CI or chore. If there is
  none, answer "nothing to release" and stop. State the rule: specs, plans and ADRs never change a version.
- `tag-skill-releases.sh`: refuse a new tag when nothing changed in `skills/<name>/` since the
  previous `<name>-v*` tag. `CHANGELOG.md`, `.claude-plugin/plugin.json` and the version line of
  `SKILL.md` do not count as changes.
- `CLAUDE.md`: state the rule in "Versioning skills".

**Acceptance criteria**
- AC-1 The reproduction is run and what git-cliff really does is recorded here. With only spec
  commits since the last tag, the skill answers "nothing to release".
- AC-2 With `DRY_RUN=1`, the tag script refuses a bump with no other change in the skill, and still
  tags a bump that comes with a real change.
- AC-3 The unchanged-behaviour cases hold: a feat release bumps MINOR, a fix release bumps PATCH,
  and existing tags are untouched.
- AC-4 The rule is written in `references/versioning.md`, `SKILL.md` and `CLAUDE.md`.

**Out of scope.** Changing versions that were already released.

## Plan

### Design
- The implementation check reads `git log <last-tag>..HEAD`: commit types from Conventional Commits,
  and changed paths outside `spec/`, `docs/` and other documentation.
- In the tag script, the path check runs per skill against its own previous tag; a skill's first tag
  has nothing to compare against and passes.

### Steps
- T-1 Run the reproduction and record the results in this file (AC-1, first half) — low — Claude Haiku 5.5. Branch `fix/0023-t1-reproduce`.
- T-2 The rule and the implementation check in `versioning.md` and `SKILL.md`; `CLAUDE.md` (AC-1, AC-4) — medium — Claude Sonnet 5.5. Branch `fix/0023-t2-release-check`.
- T-3 The path check in `tag-skill-releases.sh`, tested with `DRY_RUN` in a scratch clone (AC-2, AC-3) — medium — Claude Sonnet 5.5. Branch `fix/0023-t3-tag-guard`.
- T-4 PATCH release, changelogs, PR body with `Closes-Spec: SPEC-0023` — low — Claude Haiku 5.5. Needs SPEC-0022 implemented, so the bot can close a spec in `spec/fixes/`.

### Verification
The reproduction before and after the fix; the `DRY_RUN` cases; `claude plugin validate --strict`.

## Tasks
- [ ] T-1 Reproduce and record (AC-1)
- [ ] T-2 Rule and implementation check in the skill, CLAUDE.md (AC-1, AC-4)
- [ ] T-3 Tag-script check with DRY_RUN tests (AC-2, AC-3)
- [ ] T-4 PATCH release with `Closes-Spec: SPEC-0023`
