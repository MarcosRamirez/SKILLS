# Release automation: specs close on merge, releases tag themselves

Two manual steps used to follow every merge: tagging the release, and opening a PR only to
mark the spec Implemented. A spec cannot be marked Implemented *inside* its PR, because that
claims what has not happened yet. This workflow does both at merge time.

## When to propose it

At kickoff, if the project has a GitHub remote: propose `on-merge.yml`, and record the choice
as an ADR. Without GitHub, or if the user declines, use the manual fallback at the end.

## How it works

On every push to the default branch (that is, every merged PR):

1. Find the merged PR for the pushed commit.
2. **Close specs:** every `Closes-Spec: SPEC-NNNN` line in the PR body turns
   `docs/specs/NNNN-*/spec.md` from `Approved` into `Status: Implemented` +
   `Implemented: <date>, PR #<n>`, committed by `github-actions[bot]`. This is the **only**
   commit allowed on the default branch outside a PR.
3. **Tag the release:** if the manifest version has no `v<version>` tag yet, tag the merge
   commit and create a GitHub Release with that version's changelog section
   (`--prerelease` for alpha, beta and rc).

The AI's part: the last PR of a spec carries `Closes-Spec: SPEC-NNNN`, and checks that only
make sense after the merge go in the PR body under "Post-merge checks".

## Templates (shipped with this skill)

Copy them from the skill's own folder, `templates/release-automation/` next to this
`references/` folder, into the project:

| Template | Copy to | What it does |
|---|---|---|
| `on-merge.yml` | `.github/workflows/on-merge.yml` | Runs on push to the default branch: finds the merged PR, tags the release, closes specs |
| `close-specs.sh` | `.github/scripts/close-specs.sh` | Marks the specs named in `Closes-Spec:` as Implemented |
| `tag-release.sh` | `.github/scripts/tag-release.sh` | Reads the version from `package.json` / `pyproject.toml` / `Cargo.toml`, tags `v<version>` once, creates the GitHub Release |

After copying:
- set the default branch in `on-merge.yml` (`branches: [master]`);
- adapt the bot's commit message to the project's git convention;
- add the files to `docs/INVENTORY.md`;
- record the decision as an ADR.

What `close-specs.sh` guarantees:
- reads the PR body only from `PR_BODY`;
- accepts only ids matching `^SPEC-[0-9]{4}$`;
- fails if the spec is missing or not `Approved`;
- skips specs that are already `Implemented`;
- prints the files it changed.

Test both scripts locally before the first merge:

```bash
PR_NUMBER=1 PR_BODY='Closes-Spec: SPEC-0001' bash .github/scripts/close-specs.sh
DRY_RUN=1 bash .github/scripts/tag-release.sh
```

For monorepos (several packages, tags `<name>-v<version>`), loop over the manifests as
senior-mindset's own repository does in its `.github/scripts/tag-skill-releases.sh`.

## Security and safety

- The PR body is **untrusted** (anyone can open a PR). It travels only in an env var. Never
  write `${{ github.event.pull_request.body }}` inside a `run:` block: that is script injection.
- Minimal permissions: `contents: write`, `pull-requests: read`.
- Trigger on `push`, not `pull_request: closed`: fork PRs get a read-only token on `pull_request` events.
- Pushes made with `GITHUB_TOKEN` do not trigger workflows, so the bot commit cannot loop.
- `concurrency` serializes runs, so two quick merges do not race on the status commit.
- **Branch protection:** if the default branch requires PRs, allow `github-actions[bot]` to
  bypass for this workflow, or use a GitHub App token with bypass rights. Otherwise the status
  commit is rejected; the tag step still works.

## Manual fallback (no GitHub, or no Actions)

- After the merge, tag by hand: `git tag -a vX.Y.Z <merge-sha> -m "vX.Y.Z" && git push origin vX.Y.Z`.
- Mark the spec Implemented in the **next** PR (or the user marks it), never inside its own PR.
