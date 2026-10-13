# Versioning the app (alpha → beta → rc → stable)

How the AI versions the **app it is building**, from the first alpha to 2.1 and beyond.
The chain is the same as the changelog: Conventional Commits → git-cliff → version + tag + CHANGELOG.

## Scheme (ask at kickoff, record as an ADR)

| Scheme | Use for |
|---|---|
| **SemVer 2.0** `MAJOR.MINOR.PATCH` (default) | Apps with an API, libraries, anything other people depend on |
| **CalVer** `YYYY.MM.PATCH` | Continuously delivered apps without a public API, where "when" matters more than "does it break" |
| None | Scripts |

The rest of this file assumes SemVer.

## Initial version: always `0.0.1-alpha.1`

- Set it in the manifest (`package.json`, `pyproject.toml`, `Cargo.toml`…) when the project is created.
- Typical progression:
  `0.0.1-alpha.1 → 0.0.1-alpha.2 → … → 0.1.0-beta.1 → … → 1.0.0-rc.1 → 1.0.0 → 1.1.0 → 2.0.0`

## Stages

SemVer precedence: `1.0.0-alpha.1 < 1.0.0-alpha.2 < 1.0.0-beta.1 < 1.0.0-rc.1 < 1.0.0`.

| Stage | Meaning | Exit criterion |
|---|---|---|
| `0.y.z` | Initial development; anything may change | Real users and an API worth keeping → work towards `1.0.0` |
| `alpha` | Features incomplete, internal use | All features planned for the version are implemented |
| `beta` | Feature-complete, external testers, bugs expected | No open blocking bugs; load-test targets met |
| `rc` | Release candidate: only blocker fixes, nothing new | One full cycle without new bugs |
| stable | Compatibility promise per SemVer | — |

Write the exit criteria of each stage in the spec (or an ADR) of that version.
**Changing stage is the user's decision**: the AI proposes it, and never promotes a version on its own.

## Next version: computed by git-cliff, not by the AI

The commits decide the bump: `fix` → PATCH, `feat` → MINOR, `!` / `BREAKING CHANGE:` → MAJOR.
In `0.x`, features bump PATCH and breaking changes bump MINOR. From `1.0.0` on, standard SemVer applies.

```bash
git cliff --bumped-version     # prints the next version
```

Add this to the project's `cliff.toml` (next to the config from [changelog.md](changelog.md)):

```toml
[bump]
features_always_bump_minor = false
breaking_always_bump_major = false
initial_tag = "0.0.1-alpha.1"
```

Verified behavior (git-cliff 2.x, scratch repo, 2026-10-12):

| Latest tag | New commits | `--bumped-version` |
|---|---|---|
| none | any | `0.0.1-alpha.1` |
| `v0.0.1-alpha.1` | fix or feat | `v0.0.1-alpha.2` |
| `v0.1.0` | breaking | `v0.2.0` |
| `v1.0.0` | feat | `v1.1.0` |
| `v1.0.0` | breaking | `v2.0.0` |
| `v1.1.0-beta.1` | fix | `v1.1.0-beta.2` |

So git-cliff keeps you inside the current stage. **Leaving a stage is manual**: when the user
approves, tag the first version of the next stage yourself (`v0.1.0-beta.1`, `v1.0.0-rc.1`, `v1.0.0`).
With no tags, git-cliff prints `0.0.1-alpha.1` without the `v`: add it when tagging.

## Release process (when the user says "release the beta", "release 2.1"…)

1. `git cliff --bumped-version` → propose the version. The user confirms it or picks another stage.
2. Branch `chore/release-vX.Y.Z` (never on the default branch).
3. Update the version in the manifest.
4. `git cliff --tag vX.Y.Z -o CHANGELOG.md`.
5. Commit following the active git convention (fallback: `🔧 chore(release): vX.Y.Z`).
6. Push the branch and open the release PR ([git.md](git.md)). **The user merges it.**
   Without a remote, merge locally with `--no-ff`.
7. **With `on-merge.yml`** ([release-automation.md](release-automation.md)): when the user
   merges, the workflow tags the merge commit `vX.Y.Z` and creates the GitHub Release with
   the changelog section (`--prerelease` for alpha, beta and rc). Nothing else to do.
8. **Without it** (manual fallback): `git switch <default> && git pull`, then
   `git tag -a vX.Y.Z <merge-sha> -m "vX.Y.Z"`. Only if the user asks: `git push origin vX.Y.Z`
   and `gh release create vX.Y.Z --notes-file <section from CHANGELOG>`.

## Source of truth and visibility

- The version is the **annotated git tag** `vX.Y.Z[-stage.N]`, mirrored in the manifest by the release commit.
- The running app exposes it:
  - a `GET /version` endpoint, or a `version` field in `/health`;
  - a `version` field in every log line;
  - `release` in Sentry (see [observability.md](observability.md)).
  A bug report without a version is guesswork.

## Long-term maintenance

- **Deprecation:** announce in a MINOR (changelog entry + runtime warning in logs) and remove in the next MAJOR.
- **Supporting several majors:** create `release/1.x` only when an old major needs a fix. Fixes land on
  the default branch first, then get cherry-picked. Record the support policy (which versions get
  fixes, and until when) as an ADR.
- **Database migrations stay backward compatible** (expand → migrate → contract), so a release can be rolled back.
- **App version ≠ API version.** `/v1` in the URL changes only with breaking API changes
  (see [api-design.md](api-design.md)); the app can be at 2.4.0 while the API is still `/v1`.
