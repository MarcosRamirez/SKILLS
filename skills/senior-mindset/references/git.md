# Git (fallback convention)

**Precedence:** the project's CLAUDE.md, then the decisions in `~/.claude/senior-mindset.md`
(first-use setup, see [setup.md](setup.md)), then this file. Another git skill is followed
only for the areas the user assigned to it in the setup.

## Init

- Project without a repo → `git init -b master`. Default is `master`; ask once whether the
  user prefers `main` and record the choice in CLAUDE.md (`Default branch: ...`).
- Script → ask before creating a repo.
- `.gitignore` for the stack (start from github/gitignore templates), always including:

  ```gitignore
  .env
  .env.*
  !.env.example
  node_modules/
  dist/
  build/
  .venv/
  __pycache__/
  *.log
  .DS_Store
  ```

- Commit a `.env.example` with variable names and no values.

## Branches

- `master` (or the user's chosen default branch) is always deployable. **Nobody commits on it
  directly**, not even for a one-line or docs-only change.
- **One branch per change**, created from the up-to-date default branch
  (`git switch master && git pull` when there is a remote, then `git switch -c <type>/<slug>`).
- Naming: `<type>/<slug>`, with the spec and task number when there is one:
  - `feat/0001-user-auth` — a whole feature (spec 0001)
  - `feat/0001-t3-invoices-endpoint` — task T-3 of spec 0001
  - `fix/cursor-pagination`, `docs/api-readme`, `chore/upgrade-deps`
- One branch = one unit of work, short-lived. A large task in `tasks.md` gets its own branch;
  small, tightly coupled tasks may share the feature branch.
- No squash, no rebase of published branches.
- Already on the default branch with uncommitted changes? `git switch -c <type>/<slug>` first, then commit.

## Pull requests: the only way into the default branch

Nothing is merged or pushed into the default branch directly. Every branch becomes a PR,
and **the user reviews and merges it**.

1. Task done, checks green → `git push -u origin <branch>`.
2. Open the PR:
   - GitHub: `gh pr create --base <base> --title "<main commit subject>" --body-file <tmp>`
   - GitLab: `glab mr create --target-branch <base>`
   - other hosts: push and give the user the compare URL.

   Body:

   ```markdown
   ## What and why
   <one paragraph>

   ## Scope
   SPEC-0001 · T-3 · covers AC-2, AC-4

   ## Checks
   lint ✔ · tests ✔ (42) · build ✔

   ## Merge order
   Stacked on #12; merge #12 first.   ← only for stacked PRs
   ```

3. **Stop.** Do not merge the PR yourself, unless the user explicitly asks for that specific PR.
   Merges use a merge commit (no squash).
4. After the user merges: `git switch <default> && git pull`, delete the local branch, continue.

### Stacked PRs for dependent tasks

When T-2 builds on T-1, do not wait for T-1 to be merged:

```text
master ← PR #1 (t1) ← PR #2 (t2, base: t1 branch) ← PR #3 (t3, base: t2 branch)
```

- Create the T-2 branch from the T-1 branch, and open its PR with `--base <t1-branch>`.
- PRs are merged in order, bottom first, and **each next PR is retargeted before its base
  branch is deleted**. Do not count on automatic retargeting: deleting a base branch (e.g.
  `gh pr merge --delete-branch`) **closes** the PRs stacked on it, and a closed PR cannot be
  reopened while its base is gone. This happened on 2026-10-13.
- Safe order, for each PR from the bottom up:
  1. `gh pr edit <next> --base <default>`: retarget the PR stacked on this one.
  2. `gh pr merge <this> --merge`: merge commit, no squash, **without** `--delete-branch`.
  3. `git push origin --delete <this-branch>`: delete the branch only now.

  The AI runs this only when the user asks it to merge. When the user merges in the GitHub UI,
  tell them to retarget the next PR first, or to merge without deleting the branch.
- Independent tasks branch from the default branch, and their PRs target it directly.

### No remote

If the repo has no remote, there is nowhere to open a PR. Offer to create one:
- GitHub: `gh repo create <name> --private --source . --push`
- GitLab: `glab repo create`
- any other host: ask for the URL and run `git remote add origin <url>`

If the user declines, integrate locally with `git merge --no-ff <branch>` and delete the
branch, and record `Integration: local merge, no remote` in CLAUDE.md so you do not ask again.

## Commits

**Commit often.** One commit per significant change: a task of `tasks.md`, a decision,
a fix, a refactor. Each commit leaves the repo working and coherent.

- Small commits are easy to review, revert and bisect; a day of work in one commit is none of these.
- If the subject needs an "and", it is probably two commits.
- Do not wait for the end of the session: commit when the change is done and the checks pass.
- No "wip" commits on the default branch.

Format — Conventional Commits with an emoji in front:

```
<emoji> <type>(<scope>): <subject>

<body: why, not what — optional>

Refs: SPEC-0001
```

- **English, imperative mood:** "add", "fix", "remove" — never "added", "fixed", "removes".
- Subject ≤ 72 characters, lowercase, no trailing period.
- Breaking change: `!` after the type and a `BREAKING CHANGE:` footer.

| Emoji | Type | Use |
|---|---|---|
| ✨ | `feat` | New feature |
| 🐛 | `fix` | Bug fix |
| 📝 | `docs` | Documentation, specs, ADRs |
| ♻️ | `refactor` | Code change without behavior change |
| ✅ | `test` | Add or fix tests |
| ⚡️ | `perf` | Performance |
| 🎨 | `style` | Formatting, no logic change |
| 🔧 | `chore` | Config, tooling |
| 👷 | `ci` | CI/CD |
| 📦 | `build` | Build system, dependencies |
| 🔒 | `fix` / `feat` | Security |
| 🔥 | `refactor` / `chore` | Remove code or files |
| 🚀 | `chore` | Deploy / release |
| ⏪ | `revert` | Revert a commit |
| 💥 | `<type>!` | Breaking change |

Examples:

```
✨ feat(auth): add password reset
🐛 fix(api): handle empty cursor
📝 docs(adr): add ADR-0005 queue choice
💥 feat(api)!: rename amount to amountCents
```

## Never without explicit user request

Choosing the PR flow (setup) is standing permission to push **work branches** and open PRs.
Everything else needs an explicit request:

- Pushing to the default branch, force-push, merging a PR, rebasing shared branches, deleting remote branches or tags.
- Committing secrets — if one slips in, stop and tell the user (rotate it; history rewrite alone is not enough).
