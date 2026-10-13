# SPEC-0008 design

## Edge cases

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

## Change notice template

```text
Change notice — <one line>
Why: …
Files: + new · ~ modified · → moved · − deleted
Risks: behaviour / data / migrations / public API
Rollback: revert PR #… (or the specific steps)
Branch: <type>/<slug> · OK to proceed?
```

## Decisions

- The notice is part of the approval gate (Hard rules); a one-line fix gets a one-line notice.
- Detection of "existing": any tracked or untracked file other than the skill's own docs.
