# SPEC-0005 design

- **Trigger on `push` to master, not `pull_request: closed`.** PRs from forks get a read-only
  token on `pull_request` events; `push` runs in the base repo with write access. The merged
  PR is found via `GET /repos/{owner}/{repo}/commits/{sha}/pulls`. With no PR (direct push),
  nothing happens.
- **Logic in scripts, not inline YAML:** `.github/scripts/close-specs.sh` and
  `.github/scripts/tag-releases.sh`, so they can be tested locally with a sample PR body and
  a dry run. JSON is parsed with Python (present on runners and locally), not jq.
- **Untrusted input:** the PR body only ever travels in an env var (`PR_BODY`), never via
  `${{ }}` interpolation into the script. Ids are matched against a strict regex before they
  touch the filesystem.
- **Bot exception:** the status commit is pushed by `github-actions[bot]` with `GITHUB_TOKEN`.
  Pushes made with `GITHUB_TOKEN` do not trigger workflows, so there is no loop.
- **Tags on the merge commit** (`$GITHUB_SHA`), the commit that bumped the version, so
  `git cliff --include-path` keeps the release.
- `concurrency: on-merge` serializes runs, so two quick merges cannot race on the status commit.
- **Release:** senior-mindset 1.5.0 (MINOR: new automation and reference).
