# AGENTS.md: the project's instructions

The project's conventions live in **`AGENTS.md`**, the file most coding agents read (Codex, Cursor,
Gemini CLI, Copilot, OpenCode, Zed…). Claude Code reads it natively since v2.1.277, but **only when
no `CLAUDE.md` or `CLAUDE.local.md` exists** in the working directory or above. When both exist,
Claude reads only `CLAUDE.md` and silently ignores `AGENTS.md`
(source: code.claude.com/docs/en/memory, "AGENTS.md").

The kickoff writes to `AGENTS.md`: the `## Engineering conventions` section, the links to
`spec/constitution/`, `spec/INVENTORY.md` and `spec/adr/README.md`, the "Git rules that always hold"
block, `Code: <folder>` and every recorded choice (`Automations: …`, `Default branch: …`).
The section template is in [project-layout.md](project-layout.md).

## What stays in CLAUDE.md

Only what is specific to Claude Code: hooks, skills, plugins, slash commands, subagents, `/config` and
settings. Everything else goes to `AGENTS.md`. A `CLAUDE.md` looks like this:

```markdown
@AGENTS.md

## Claude Code
(hooks, skills, plugins, slash commands, settings: only if any)
```

## Cases

Detect `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md` and `.claude/AGENTS.md` at the
root and above, and per package in a monorepo. Check whether each CLAUDE file starts with `@AGENTS.md`.

| Case | What the skill does |
|---|---|
| New project | Creates **only `AGENTS.md`**. No `CLAUDE.md`: Claude Code reads AGENTS.md natively |
| Only `CLAUDE.md` | Proposes migrating: `git mv CLAUDE.md AGENTS.md` (keeps history) and a new `CLAUDE.md` with `@AGENTS.md` plus, below it, only Claude Code-specific content. Change notice + branch |
| Only `AGENTS.md` | Uses it as the source. Does **not** create a `CLAUDE.md` |
| Both; `CLAUDE.md` already imports `@AGENTS.md` | Nothing to migrate; moves anything that is not Claude-specific from `CLAUDE.md` into `AGENTS.md`, if any |
| Both, with different content | **Warns** that Claude currently ignores `AGENTS.md`. Proposes merging into `AGENTS.md`: non-conflicting content merges by itself, each contradictory rule is asked with the question tool, nothing is lost. `CLAUDE.md` keeps only the import. Change notice + branch |
| `CLAUDE.md` is a symlink | On Windows or shared repos, replaces it with the `@AGENTS.md` import (symlinks break on Windows clones) |
| `CLAUDE.local.md` present | Respected; it must start with `@AGENTS.md` (see the safety rule) |
| Monorepo with an `AGENTS.md` per package | Same rule per folder; the closest `AGENTS.md` wins |

Every case that changes a file is a **proposal**: a change notice (the template in the merge section
below, without the lines that do not apply), a closed question
([questions.md](questions.md)) and, for tracked files, a branch. **Nothing is written until the user
answers.** A failed or skipped question, or a headless run, is no answer: leave the files as they
are, end with the notice and the numbered questions, and go on with the user's request.

## Safety rule

In a project with `AGENTS.md`, any `CLAUDE.md` or `CLAUDE.local.md` must start with `@AGENTS.md`.
When the skill creates one or finds one without that line, it proposes adding it, because otherwise
Claude stops reading `AGENTS.md`. If a session does not see `AGENTS.md` (Claude Code older than
v2.1.277, sessions without support; check with `/memory`), the documented fix is the one-line `CLAUDE.md`.

## Merging: both files with different content

While `CLAUDE.md` exists, Claude reads only `CLAUDE.md`: the rules in `AGENTS.md` are not in force in
Claude sessions, and other agents never see the rules in `CLAUDE.md`. Say so first, in one line:
"⚠️ Claude Code reads only CLAUDE.md here, so AGENTS.md is ignored in Claude sessions."
Then propose the merge:

1. **Read both files in full**, and any file they import with `@path`.
2. **Sort every section and rule** into one of four groups:
   - in both, with the same meaning → kept once;
   - in one file only → kept (it does not conflict, it adds);
   - Claude Code-only (hooks, skills, plugins, slash commands, subagents, `/config`, settings) →
     stays in `CLAUDE.md`, below the import;
   - **conflict**: the same topic with different instructions (default branch `main` vs `master`,
     tabs vs spaces, "commit on the default branch" vs "pull requests only").
3. **Build the merged `AGENTS.md` without writing it.** Start from the structure of `AGENTS.md`, add
   the sections of `CLAUDE.md` that it lacks, and join the rules of sections present in both. Keep
   every section, rule, link and example word for word. Each conflict waits for its answer.
4. **Show the change notice** with a summary that proves nothing is lost:

   ```text
   Change notice: merge CLAUDE.md into AGENTS.md
   Why: Claude Code reads only CLAUDE.md while it exists, and other agents read only AGENTS.md.
   Files: ~ AGENTS.md (merged) · ~ CLAUDE.md (becomes @AGENTS.md + Claude Code-only content)
   Kept from CLAUDE.md: <each section or rule>
   Kept from AGENTS.md: <each section or rule>
   Stays in CLAUDE.md (Claude Code only): <each item, or "nothing">
   Conflicts: 1) <topic>: CLAUDE.md says "…" / AGENTS.md says "…"
   Risks: instructions only, no code. Rollback: close the PR.
   Branch: docs/merge-agents-md
   ```

5. **Ask one closed question per conflict**, in one call (up to 4; more go in the next call),
   showing both versions ([questions.md](questions.md)). Recommended first: the version the repository
   already follows (its branches, configs, code); when that cannot be checked, the `CLAUDE.md` version,
   because it is the one Claude sessions apply today. Add a last question to approve the notice.
6. **Nothing is written until every question is answered** and the notice is approved. Until then,
   where the files conflict, follow `CLAUDE.md`, the file Claude reads today.
7. **Apply on the branch:** write the merged `AGENTS.md` with the answers, and replace `CLAUDE.md`
   with `@AGENTS.md` plus a `## Claude Code` section holding only its Claude Code-only content (no
   section when there is none). Commit, push and open the PR as usual ([git.md](git.md)), with the
   summary in the PR body.
8. **Check before committing:** every item of both "Kept from" lists is in the new `AGENTS.md`, every
   Claude Code-only item is in `CLAUDE.md`, and each conflict appears once, in the chosen version.

## Symlinked CLAUDE.md

A `CLAUDE.md` that is a symlink (`test -L CLAUDE.md`, or mode `120000` in `git ls-files -s`) breaks on
Windows clones: git writes a plain file that holds the target path, not its content.

- Pointing at `AGENTS.md` → propose replacing the link with a regular file that holds `@AGENTS.md`
  (change notice, branch). The content does not change.
- Pointing anywhere else → treat the target's content as the `CLAUDE.md` content and apply the
  matching case (only `CLAUDE.md`, or the merge above).

## CLAUDE.local.md

A personal file, usually git-ignored. Its content is the user's and is never moved into `AGENTS.md`.
Its presence alone, even without a `CLAUDE.md`, stops Claude Code from reading `AGENTS.md`. When it
does not start with `@AGENTS.md`, propose adding that line at the top: a short change notice and a
closed question. The file is not tracked, so no branch and no commit: after the OK, add the line and
nothing else.

## Not project instructions

`~/.claude/CLAUDE.md` (the user's global file) and `~/.claude/senior-mindset.md` are user-level and
stay as they are. Other agents' config files (`.cursorrules`, `.github/copilot-instructions.md`,
`GEMINI.md`) are a separate feature (SPEC-0013).
