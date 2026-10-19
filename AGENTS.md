# AGENTS.md

Plug-and-play skills for AI coding agents, following the Agent Skills standard (standard first,
[ADR-0005](spec/adr/0005-standard-locations-first.md)). Built and tested on Claude Code; other agents
are planned (SPEC-0013). The Claude Code plugin marketplace is one distribution channel
(`/plugin marketplace add MarcosRamirez/SKILLS`).

## Engineering conventions

Managed with the senior-mindset skill. Details and reasons live in the ADRs.

- **Project type:** documentation-first repo: Markdown skills, JSON manifests, one Python hook.
  Not applicable here: database, deployment platform, API, logging, load tests (no runtime).
- **Distribution:** `npx skills` into the project's `.agents/skills/` plus the `.claude/skills/` bridge for Claude Code; the Claude Code plugin marketplace in `.claude-plugin/marketplace.json` (one plugin per skill) is an optional channel. See [ADR-0005](spec/adr/0005-standard-locations-first.md).
- **Versioning:** SemVer 2.0 per skill, kept in its `SKILL.md` ([ADR-0006](spec/adr/0006-version-in-skill-md.md)). Until SPEC-0021 T-1 moves it, the source of truth is still `plugin.json` (rules below).
- **Changelog:** `CHANGELOG.md` generated with git-cliff from the commit history. See [ADR-0002](spec/adr/0002-generate-changelog-with-git-cliff.md).
- **Checks (instead of a linter):** `claude plugin validate .` and `claude plugin validate ./skills/<name> --strict`, plus
  `python3 .github/scripts/check-docs.py` (relative links resolve, no link to a superseded ADR in the living documents).
  The docs check runs on every pull request through `.github/workflows/checks.yml`. Before every
  release, the headless suite (`bash tests/headless/run.sh`) checks the skill's behaviour.
- **Scripts have tests:** when a script under `.github/scripts/` or `skills/*/templates/` changes,
  its suite in `tests/ci/` changes in the same pull request.
- **Language:** skill files, READMEs and docs in English.
- **Git:** default branch `master`, PR flow from senior-mindset (see Git below). Before creating anything, check [spec/INVENTORY.md](spec/INVENTORY.md).

**Git rules that always hold** (full rules in [Git](#git) below):
- Changes reach `master` through pull requests that the user merges.
- Never merge, push or force-push unless the user asks.
- Confirm with a closed question (options to pick), never by assuming.
  Before writing a spec, reviewing a change or preparing a release, read [spec/POSTMORTEMS.md](spec/POSTMORTEMS.md).

## Git

Git rules follow senior-mindset (decided in `~/.claude/senior-mindset.md`); commit format
follows senior-mindset's convention, which matches the emoji + Conventional Commits style used here.

- **One branch per change, never commit directly on `master`**, not even a one-line or docs-only change.
  Branch `<type>/<slug>` (with spec and task, e.g. `feat/0002-t3-pr-flow`).
- **Commit often:** one commit per significant change, each leaving the repo coherent.
- **Everything reaches `master` through a pull request that the user merges.** Push the branch,
  `gh pr create`, stop. Dependent tasks are stacked PRs (base = the previous task's branch),
  merged by the user in order. Before deleting a merged base branch, retarget the next PR
  (`gh pr edit <next> --base master`): deleting the base closes the stacked PRs.
  Never push to `master`, never merge a PR yourself unless asked.
- **The only exception to "never commit on master":** `github-actions[bot]`, through
  `.github/workflows/on-merge.yml`, and only to mark specs Implemented after a merge.
- Scopes: one per skill (`senior-mindset`, `save-image`), plus `marketplace` and `repo`.

## Plans

- Every feature lives in `spec/features/NNNN-<slug>/` with `spec.md`, `plan.<tier>.md` (overall tier
  as suffix; its `## Design` holds the technical how) and `tasks.md`, or in a single
  `spec/features/NNNN-<slug>.md` when small. The plan is written before implementation. "Run plan NNNN" executes it.
- Fixes live in `spec/fixes/NNNN-<slug>.md` (one file with Spec / Plan / Tasks; a folder when large),
  sharing the SPEC-NNNN numbering (SPEC-0022). The bot closes them like features.
- Every fixed bug gets a row in `spec/POSTMORTEMS.md` and, when it has a fix spec, a blameless
  `## Postmortem` in it, written in the same branch as the fix (SPEC-0026).
- The plan becomes `Done` together with its spec when the `Closes-Spec:` PR is merged.

## Specs close themselves on merge

- The last PR of a spec carries `Closes-Spec: SPEC-NNNN` in its body (one line per spec).
- **Never mark a spec Implemented by hand or inside the PR.** When the PR is merged,
  `on-merge.yml` sets `Status: Implemented` + `Implemented: <date>, PR #<n>` and commits it as the bot.
- Checks that can only run after the merge (plugin update, etc.) go in the PR body under
  "Post-merge checks", not in `tasks.md`. Their result is posted with `gh pr comment <n>`.
- If the workflow fails, set the status by hand in the next PR and fix the workflow.

## Documentation is updated in the same commit as the change

Whenever a skill, a skill feature or a reference is added, or anything changes what a skill
does or how it is installed, update in the same commit:

- Root `README.md`: skills table, the skill's section, the skills-count badge, the repo
  structure and the install instructions if they change.
- The skill's `README.md`: what it does and its `references/` table.
- `.claude-plugin/marketplace.json` and the skill's `plugin.json`: description if it changes,
  version per the rules below.
- `spec/INVENTORY.md` when files are added, moved or removed, or when what a file does changes
  (its line and every mention that describes it).
- `spec/constitution/roadmap.md` when a feature is added (the bot sets Implemented on merge).
- `spec/constitution/tech-stack.md` when an ADR is added or superseded.

**Impact sweep:** when an ADR is accepted or superseded, or a spec changes a convention or a layout
that documents describe, search for the ADR id, the replaced terms and the files of the area
(`git grep -n`), update the living documents and Draft/Approved specs in the same PR, and keep
Implemented specs, ADR files and changelogs as written. Procedure and Impact template:
`skills/senior-mindset/references/adr.md`.

Before committing, check that every relative link in the READMEs resolves.

## Versioning skills (SemVer 2.0)

**Every change inside `skills/<name>/` bumps that skill's version.** Without a bump,
users who installed it with `/plugin` never receive the update.

- Source of truth: `version` in `skills/<name>/.claude-plugin/plugin.json`. Keep
  `metadata.version` in the skill's `SKILL.md` frontmatter identical. No version in `marketplace.json`.
- **PATCH** (`1.1.0 → 1.1.1`): typos, wording, clarifications, examples that do not change behavior.
- **MINOR** (`1.1.0 → 1.2.0`): new rule, step, reference or feature that does not break what was there.
- **MAJOR** (`1.x → 2.0.0`): a skill or command is removed or renamed, installation or required
  setup changes (e.g. a hook that needs a manual step), or behavior is reversed.
- Only the skill whose files changed is bumped. Changes to the root README or this file bump nothing.
- **Specs, plans and ADRs never move a version.** They live in `spec/`, outside any skill, and ship
  nothing a user runs. A skill's version moves only in the release that ships implemented changes
  inside `skills/<name>/`.
- Unpublished changes are grouped: one bump per push, using the highest level that applies.
- The bump goes in the same commit as the change, or in the last commit of the branch before merging.
- **New skills start at `0.0.1-alpha.1`** and reach `1.0.0` when tested and stable.

## Releasing a skill: tag and changelog

1. Run the headless suite first: `bash tests/headless/run.sh` (see `tests/headless/README.md`). Paste
   its summary (scenarios, results, cost, model, Claude Code version) into the release PR body.
   A FAIL blocks the release until it is fixed or the user accepts it explicitly. A run SKIPPED
   by a usage limit is reported as such and rerun later. The suite makes model calls, so it runs
   before releases, not on every pull request.
2. In the release PR, regenerate the changelogs:
   - repo: `npx git-cliff -o CHANGELOG.md`
   - per skill: `npx git-cliff --include-path "skills/<name>/**" --tag-pattern "<name>-v.*" --tag <name>-vX.Y.Z -o skills/<name>/CHANGELOG.md`
3. When the user merges it, `on-merge.yml` tags the merge commit `<name>-vX.Y.Z` and creates
   the GitHub Release with that version's changelog section (`--prerelease` for alpha/beta/rc).
   The tag must sit on the merge commit that bumped the version, which is why the workflow tags
   `$GITHUB_SHA`. Manual fallback if the workflow fails:
   `git tag -a <name>-vX.Y.Z <merge-sha> -m "<name> X.Y.Z" && git push origin <name>-vX.Y.Z`.
   The script refuses a version when nothing but the version and the changelog changed in the skill
   since its previous tag (the job fails and names it): drop the bump, do not use the fallback.
4. Post-merge checks: `gh run list --workflow on-merge.yml` is green, the tag and Release exist,
   then `claude plugin marketplace update marcosramirez-skills` +
   `claude plugin update <name>@marcosramirez-skills`. Post the result as a PR comment.

## Structure

```text
.claude-plugin/marketplace.json   marketplace manifest
skills/<name>/
  SKILL.md                        what Claude loads
  README.md                       for humans
  .claude-plugin/plugin.json      plugin manifest (version lives here)
  references/ scripts/ hooks/     optional
spec/constitution/  mission.md · tech-stack.md · roadmap.md
spec/features/     NNNN-slug/{spec.md, plan.<tier>.md, tasks.md} or NNNN-slug.md
spec/fixes/        NNNN-slug.md (bug specs: current / expected / unchanged behaviour, postmortem)
spec/adr/  spec/INVENTORY.md
spec/POSTMORTEMS.md               one row per bug: category, root cause, prevention and its status
CHANGELOG.md  cliff.toml
.github/workflows/on-merge.yml    closes specs + tags releases after each merge
.github/scripts/tag-skill-releases.sh   tags new skill versions, refuses version-only bumps (repo-only, DRY_RUN=1 to test)
.github/workflows/checks.yml        on every pull request: check-docs.py (job docs) and tests/ci/run.sh (job scripts)
.github/scripts/check-docs.py       living documents: broken relative links, links to superseded ADRs
tests/ci/                          tests of the release scripts and the docs check (run.sh; the scripts job in CI)
tests/headless/                    headless suite: run.sh, scenarios/ (run before every release)
skills/senior-mindset/templates/  files the skill copies into apps; this repo reuses close-specs.sh
```
