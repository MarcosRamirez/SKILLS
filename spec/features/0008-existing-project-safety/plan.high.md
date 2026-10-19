# PLAN-0008: work safely on existing projects (code or documentation)

Spec: [SPEC-0008](spec.md)
Status: Done
Done: 2026-10-19, PR #89
Recommended overall: high — Claude Opus 5.5 (safety rules that must hold under pressure need careful wording and adversarial tests)

## Context

Today the approval gate covers new code, but not reorganising existing docs, uncommitted user changes, or existing AI configs. The user has documentation-only projects that must not be restructured without warning. Read first: `SKILL.md` Hard rules, SPEC-0003 (headless gate lessons).

## Design

### Edge cases

| Case | Behaviour |
|---|---|
| Empty folder | Normal kickoff, no notice (nothing to touch) |
| Documentation only, own pattern | Notice before reorganising or renaming; normalisation is SPEC-0009 |
| Code, with or without docs | Notice before touching code or docs; existing conventions win |
| Not a git repo | Propose `git init` + a commit of the current state first (a way back) |
| Uncommitted user changes | Never touch or mix them: ask (commit on their branch, stash, or stop) |
| User on another work branch | Do not reuse it: branch from the updated default branch, or ask to stack |
| Existing CLAUDE.md, AGENTS.md, .cursorrules, other AI config | Read, respect, merge; never overwrite |
| CI, branch protection, hooks, linters | Respect them; never disable them to get something through |
| Monorepo | The notice names the packages touched |

### Change notice template

```text
Change notice — <one line>
Why: …
Files: + new · ~ modified · → moved · − deleted
Risks: behaviour / data / migrations / public API
Rollback: revert PR #… (or the specific steps)
Branch: <type>/<slug> · OK to proceed?
```

### Decisions

- The notice is part of the approval gate (Hard rules); a one-line fix gets a one-line notice.
- Detection of "existing": any tracked or untracked file other than the skill's own docs.

## Steps

### T-1 Hard rule + Step 0 check — high
- Recommended: high — Claude Opus 5.5 (rule wording decides behaviour)
- Branch: `feat/0008-t1-existing-project-rule`
- Do: add Hard rule 4 (change notice + wait + branch) and an 'is this an existing project?' check to Step 0
- Files: ~ SKILL.md
- Done when: AC-1 (rule part)

### T-2 existing-projects.md — medium
- Recommended: medium — Claude Sonnet 5.5 (reference writing from a settled design)
- Branch: `feat/0008-t2-existing-projects-reference`
- Do: notice template, edge-case table, examples per case, AI-config merge rules
- Files: + references/existing-projects.md
- Done when: AC-1, AC-6

### T-3 Headless tests — high
- Recommended: high — Claude Opus 5.5 (adversarial testing and rewording until it holds)
- Branch: `test/0008-t3-headless-cases`
- Do: build four scratch repos (code, docs-only, dirty tree, no git), run `claude -p` with `--plugin-dir`, inspect, fix wording, repeat
- Files: test fixtures stay in the scratchpad; wording fixes in SKILL.md / reference
- Done when: AC-2…AC-5

### T-4 Release — low
- Recommended: low — Claude Haiku 5.5 (mechanical)
- Branch: `chore/0008-t4-release`
- Do: minor bump, docs, changelogs; PR body with `Closes-Spec: SPEC-0008`
- Files: ~ plugin.json, ~ READMEs, ~ CHANGELOGs
- Done when: bot closes spec and plan; plugin update

## Verification

Each AC maps to one headless case; a case passes only if no file outside the notice is touched (git status clean except allowed).

## Risks

Over-warning makes the skill tedious → one-line notices for one-line changes. Under-warning on docs → docs-only case is an explicit test.

## Out of scope

Normalising projects to the standard layout (PLAN-0009).
