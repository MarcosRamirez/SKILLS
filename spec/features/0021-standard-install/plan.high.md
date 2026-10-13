# PLAN-0021: install in the project, standard locations first

Spec: [SPEC-0021](spec.md)
Status: Draft
Recommended overall: high — Claude Opus 5.5 (release automation, install behaviour across agents, migration of an existing global install)

## Context

Decided in ADR-0005 (standard locations first) and ADR-0006 (version in SKILL.md, no Claude Code
files in skill folders). It depends on SPEC-0019, because the note for this repository goes in AGENTS.md.

Sources to re-read before implementing:
- github.com/vercel-labs/skills (flags, where the canonical copy goes, `update`);
- code.claude.com/docs/en/plugins/loading (skills-directory plugins, precedence);
- code.claude.com/docs/en/plugins/marketplace-reference (entries without `plugin.json`).

## Design

- **Project install:**
  `npx skills@<pinned> add https://github.com/MarcosRamirez/SKILLS/tree/<tag>/skills/senior-mindset --copy`.
  If the tree URL at a tag is not accepted, use whatever the CLI documents for refs. It writes the
  copies into `.agents/skills/senior-mindset/` and `.claude/skills/senior-mindset/`.
- **Where the skill loads from (first use):**
  - `claude plugin list --json` shows the scope of `senior-mindset@marcosramirez-skills`;
  - global skill folders: `~/.claude/skills/senior-mindset`, `~/.agents/skills/senior-mindset`;
  - project folders: `.agents/skills/senior-mindset`, `.claude/skills/senior-mindset`.
- **Disable the global plugin in one project:** `"senior-mindset@marcosramirez-skills": false` in
  `.claude/settings.local.json` (local scope, not committed).
- **Manifest move (ADR-0006):**
  - the marketplace entry gets `version`, `author`, `homepage`, `repository` and `license`;
  - `skills/*/.claude-plugin/` is deleted;
  - `tag-skill-releases.sh` reads the `metadata.version` frontmatter line;
  - a check script compares that version with the entry's `version` and runs in CI and before every release.
- **Update command:** find the latest `senior-mindset-v*` tag (`gh release list` or
  `git ls-remote --tags`), branch `chore/update-senior-mindset-vX.Y.Z`, install from that tag,
  open a PR whose body carries that version's CHANGELOG section.

## Steps

### T-1 Manifest out of skill folders, version in SKILL.md — high
- Recommended: high — Claude Opus 5.5 (release automation must keep working)
- Branch: `feat/0021-t1-manifest-in-marketplace`
- Do:
  - move both skills' `plugin.json` data into their marketplace entries;
  - add `metadata.version` to save-image;
  - the tag script reads SKILL.md, plus the version check;
  - update the CLAUDE.md versioning rules and the validate commands;
  - check `/plugin` install and update from a local marketplace copy.
- Files: ~ .claude-plugin/marketplace.json, − skills/*/.claude-plugin/, ~ skills/save-image/SKILL.md, ~ .github/scripts/tag-skill-releases.sh, + version check script, ~ CLAUDE.md
- Done when: AC-6

### T-2 Verify npx skills, then the READMEs — medium
- Recommended: medium — Claude Sonnet 5.5 (verification, then documentation)
- Branch: `feat/0021-t2-standard-install-docs`
- Do:
  - in a scratch repository, check where the canonical copy goes, `--copy`, installing from a tag,
    and how `npx skills update` resolves versions;
  - write both READMEs (R-3);
  - check that Claude Code and Codex or OpenCode load the skill.
- Files: ~ README.md, ~ skills/senior-mindset/README.md
- Done when: AC-1, AC-2

### T-3 First-use detection — high
- Recommended: high — Claude Opus 5.5 (changes other installs on the user's machine)
- Branch: `feat/0021-t3-install-detection`
- Do: the detection and questions from R-4 in references/setup.md and in Step 0a of SKILL.md;
  headless tests with only a global copy, only a project copy, and both
- Files: ~ references/setup.md, ~ SKILL.md
- Done when: AC-3

### T-4 Update by pull request — medium
- Recommended: medium — Claude Sonnet 5.5 (scripted flow)
- Branch: `feat/0021-t4-update-command`
- Do: the "update senior-mindset" command (R-5); test it in a scratch repository
- Files: ~ SKILL.md, ~ references/setup.md (or the commands reference from SPEC-0014)
- Done when: AC-4

### T-5 This repository — low
- Recommended: low — Claude Haiku 5.5 (install and document)
- Branch: `chore/0021-t5-install-here`
- Do:
  - install the published version (R-6);
  - disable the global plugin here in `.claude/settings.local.json`;
  - add the note to AGENTS.md;
  - check how to try the working copy without loading two senior-mindsets.
- Files: + .agents/skills/senior-mindset/, + .claude/skills/senior-mindset/, ~ AGENTS.md
- Done when: AC-5

### T-6 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0021-t6-release`
- Do: minor bump (existing installs keep working); changelogs; PR body with `Closes-Spec: SPEC-0021`
  and the post-merge checks (bot run, tag, `claude plugin update`)
- Done when: the bot closes the spec, the plan and the roadmap row

## Verification

`DRY_RUN` of the tag script, version check in CI, headless first-use tests, scratch-repo install with
two agents, and `claude plugin update` after the release.

## Risks

- `npx skills` changes behaviour or installs from the default branch → pin the CLI version and install
  from the tag URL; verify in T-2.
- Uninstalling the global copy affects every other project → that is a separate question with a warning.
- The two copies drift apart → the update writes both, and first use compares them.
- Supply chain: `npx` runs a package from npm → pin the version and record it in the README.

## Out of scope

Install docs for each agent (SPEC-0013); AGENTS.md (SPEC-0019).
