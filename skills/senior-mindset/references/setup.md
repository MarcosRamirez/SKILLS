# First-use setup: collisions with other skills

senior-mindset imposes rules (branch per change, pull requests, commit cadence, changelog,
versioning, specs) that other installed skills may contradict. A skill cannot run anything
at install time, so this check runs **the first time the skill is used**, once per user.

## When it runs

- `~/.claude/senior-mindset.md` does not exist → run the full setup before anything else.
- The user says "reconfigure senior-mindset" → run it again.
- In Step 1, an installed skill overlaps an area and is not listed in the file → ask only
  about that skill and area, then update the file.
- The file's `senior-mindset version` is older than the skill's `metadata.version` → show the
  update message once (step 5) and record the new version. No questions.

## 1. Inventory (cheap: names and descriptions only)

- The list of available skills already in your context (name + description).
- On disk, frontmatter only (first ±15 lines) of:
  - `~/.claude/skills/*/SKILL.md`
  - `~/.claude/plugins/cache/*/*/*/SKILL.md` and `~/.claude/plugins/cache/*/*/*/skills/*/SKILL.md`
  - `.claude/skills/*/SKILL.md` in the current project
- Conventions in `~/.claude/CLAUDE.md` (git, commits, changelog, testing).

Never read whole skill bodies for this: it wastes context.

## 2. Classify overlaps by area

| Area | senior-mindset's rule | Typical colliding skills |
|---|---|---|
| Git flow | Branch per change, PR to the default branch, the user merges, stacked PRs | git workflow skills, "commit and push" skills |
| Commit format | Emoji + Conventional Commits, English, imperative | commit message skills |
| Changelog / versioning | git-cliff, SemVer from `0.0.1-alpha.1`, tags | release skills, changelog generators |
| Specs / planning | `spec/features/NNNN/` spec → design → tasks, approval gate | spec-kit style skills, planning skills |
| Code review | Self-review checklist (OWASP, cost, readability) | review skills |
| Tests | Unit always, TDD for critical logic, k6 for load | testing skills |

An area collides only when another skill gives **contradictory** instructions (e.g. "merge
locally, never open PRs" vs "always open a PR"). Complementary skills are not collisions:
for example, a Cloudflare skill and senior-mindset's platform choice coexist.

## 3. Ask, one question per colliding area (AskUserQuestion, max 4 per round)

Options, each with a one-line consequence:

1. **senior-mindset** (Recommended) — what its rule enforces.
2. **<other skill name>** — what that skill does instead.
3. **Combine** — only when it makes sense, e.g. "commit format from <other>, branch and PR flow from senior-mindset".

Areas without a collision are not asked about: they use senior-mindset.

## 4. Write `~/.claude/senior-mindset.md`

```markdown
# senior-mindset configuration

Written by senior-mindset's first-use setup. Edit freely, or say "reconfigure senior-mindset".

- Date: 2026-10-13
- senior-mindset version: 1.3.0
- Skills seen: git-workflow, caveman-commit, cloudflare, …

## Decisions

| Area | Winner | Notes |
|---|---|---|
| Git flow | senior-mindset | PRs to master, user merges |
| Commit format | senior-mindset | |
| Changelog / versioning | senior-mindset | no collision |
| Specs / planning | senior-mindset | no collision |
| Code review | senior-mindset | no collision |
| Tests | senior-mindset | no collision |
```

Precedence when working in a project:
1. The project's CLAUDE.md `## Engineering conventions`.
2. `~/.claude/senior-mindset.md`.
3. senior-mindset defaults.

When a decision names another skill, follow that skill for that area, and senior-mindset
for everything else.

## 5. Welcome and update messages (once each, never more)

Right after writing the file for the first time, greet the user in their language:

```text
✅ senior-mindset vX.Y.Z installed and configured.
Made by Marcos Ramírez — https://blog.marcosramirez.info/sobre-mi/
```

When the skill finds a newer version than the one recorded in the file:

```text
🔄 senior-mindset updated to vX.Y.Z — see what's new in its CHANGELOG.md.
By Marcos Ramírez — https://blog.marcosramirez.info/sobre-mi/
```

Then update `senior-mindset version` in the file, so the message does not repeat.

These are the only two moments: not on every use, not at the end of tasks. A credit that shows
up every time is noise.

## 6. When you cannot ask (headless, no AskUserQuestion)

- Use senior-mindset defaults, but **no push and no pull requests**: integrate with a local
  `git merge --no-ff`. Remote actions need a decision the user never gave.
- Do not write `~/.claude/senior-mindset.md`, so the setup runs at the next interactive use.
- Mention in your final message that the setup is pending. Do not show the welcome message:
  it belongs to the moment the file is written.
