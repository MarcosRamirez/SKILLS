# Working safely on existing projects

Hard rule 4 in `SKILL.md`: before changing anything that already exists in a project, show a change
notice, wait for the user's explicit OK, and do the work on a new branch delivered by PR. This file
holds the notice template, the edge cases and examples.

## What counts as an existing project

Any folder with code or documentation that the skill did not just create: tracked or untracked
files, specs, ADRs, notes or wikis, even if they do not follow senior-mindset's layout. An empty
folder, or one that holds only what this session created, is a new project.

## The change notice

```text
Change notice — <one line: what and why>
Why: <the reason, linked to the spec or the request>
Files: + new · ~ modified · → moved · − deleted   (list them; group by package in a monorepo)
Risks: behaviour / data / migrations / public API / none
Rollback: revert PR #… (or the specific steps)
Branch: <type>/<slug> · OK to proceed?
```

- Ask for the OK with a closed question ([questions.md](questions.md)): "Yes, go ahead" / "Change
  something first" / "No".
- A one-line fix gets a one-line notice. A reorganisation gets the full list of files.
- A failed or skipped question is not an OK. In a headless run, show the notice in the final message
  and stop. That is hard rule 3.
- Once approved, the notice goes in the PR body.

## Edge cases

| Case | Behaviour |
|---|---|
| Empty folder | Normal kickoff, no notice: there is nothing to touch |
| Documentation only, with its own pattern | Notice before reorganising or renaming anything; adopting the standard layout is SPEC-0009 (assessment first) |
| Code, with or without docs | Notice before touching code or docs; existing conventions (naming, structure, libraries, configs) win over the skill's defaults |
| Not a git repo | Propose `git init` and a commit of the current state first, so there is a way back, then the notice |
| Uncommitted user changes | Never touch or mix them. Ask: commit them on their own branch, stash them, or stop. Do not offer to work around them in place: switching branches carries them along, and a later `git add` can mix them into your commit |
| The user is on another work branch | Do not reuse it. Branch from the updated default branch, or ask whether to stack on theirs |
| Existing CLAUDE.md, AGENTS.md, `.cursorrules` or other AI config | Read and respect them; merge, never overwrite. AGENTS.md and CLAUDE.md follow [agents-md.md](agents-md.md) |
| CI, branch protection, hooks, linters | Respect them; never disable a check or skip a hook to get a change through |
| Monorepo | The notice names the packages touched |

## Conventions win

When the project's conventions differ from the skill's defaults (another test runner, another
naming style, another folder layout), follow the project. Note the deviation in the notice or in
the PR, and propose aligning it as a separate change if it is worth it. Never impose the default.

## No drive-by refactors

What you notice on the way (dead code, a naming inconsistency, an outdated dependency) is
proposed separately: a line in the final message, or a Draft spec. The change you were asked
for touches only what it needs.

## Examples

**Code repository, "add validation to the form":**

```text
Change notice — validate the signup form (email format, password length)
Why: the request; no spec needed beyond SPEC-0012 (approved)
Files: ~ src/forms/signup.ts · ~ src/forms/signup.test.ts
Risks: behaviour: invalid signups are now rejected client-side
Rollback: revert PR #…
Branch: feat/0012-signup-validation · OK to proceed?
```

**Documentation-only repository, "organise the specs":** the notice lists every file moved and
renamed, with `git mv` so history is kept, and offers the SPEC-0009 assessment first, because the
project already follows a pattern of its own.

**Uncommitted changes in the working tree:** do not edit anything. Say which files have
uncommitted changes, and ask whether to commit them on their own branch, stash them, or stop.

**Folder without git:** propose `git init -b master` and a first commit of the current state
("chore: snapshot before senior-mindset changes"), then show the notice for the actual change.
