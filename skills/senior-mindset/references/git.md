# Git (fallback convention)

**Precedence:** if a git skill is installed (e.g. `git-workflow`) or the project's
CLAUDE.md defines a git convention, follow that instead. This file applies only
when there is none.

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
- Integrate with `git merge --no-ff`, then delete the branch. No squash, no rebase of published branches.
- Already on the default branch with uncommitted changes? `git switch -c <type>/<slug>` first, then commit.

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

- Push, force-push, merge, rebase of shared branches, deleting branches or tags.
- Committing secrets — if one slips in, stop and tell the user (rotate it; history rewrite alone is not enough).
