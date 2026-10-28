# write-skill

**Skills that fit the standard, and stay small.**

Tells the agent how to write a skill instead of a documentation dump: a name and a description that
trigger, a body that carries only the procedure, references read on demand, scripts for the work a
script should do, and budgets measured by a validator.

Based on the [Agent Skills](https://agentskills.io) standard, plus the stricter targets this repo
uses (and that any project can adopt).

## What it changes

| Without | With write-skill |
|---|---|
| A `SKILL.md` that is the whole manual | The procedure in the body, everything else in `references/` |
| "Helps with PDFs" | A description with what, when and the words the user types |
| References nobody reads, or chains of references | One level, each linked with *when* to read it |
| A 60-line script pasted in the body | The script under `scripts/`, run by the agent |
| "It feels long" | Lines, words, estimated tokens and the rule that failed, printed by the validator |
| Two skills named one letter apart | A collision check before the first line is written |

## Install

**Plugin (Claude Code):**

```text
/plugin marketplace add MarcosRamirez/SKILLS
/plugin install write-skill@marcosramirez-skills
```

**`npx skills` (any agent that reads `.agents/skills/`):**

```bash
npx skills add MarcosRamirez/SKILLS --skill write-skill -a claude-code opencode --copy
npx skills add MarcosRamirez/SKILLS#write-skill-v0.0.1-alpha.1 --skill write-skill -a claude-code opencode --copy
```

**Ask your agent:**

> Install the **write-skill** skill from https://github.com/MarcosRamirez/SKILLS, folder
> `skills/write-skill`, at its latest release tag, into this project's `.agents/skills/write-skill/`
> (copy the whole folder). If your agent does not read `.agents/skills/`, also copy it to
> `.claude/skills/write-skill/`. Ask me before installing it globally.

## Use

```
you    › create a skill that checks our OpenAPI specs before a release
claude › Name and folder, description with triggers, body under 100 lines,
         details in two references. 0 errors, 0 warnings.
         Here's skills/openapi-guard/: 4 acceptance checks…
```

Ask in any language: "crear una skill", "revisa esta skill", "split this skill", "write a SKILL.md".

## Budgets

| What | Target | Hard limit |
|---|---|---|
| `description` | 500 chars | 1024 (standard) |
| `SKILL.md` body | 100 lines / 800 words | 500 lines / ~5000 tokens (standard) |
| each reference | 150 lines, one topic | — |
| depth | `SKILL.md` → one reference | no reference-to-reference links |

The validator errors at the hard limits and warns at the targets; `--strict` turns warnings into
errors. The numbers and the reasoning are in
[references/budget.md](references/budget.md).

## Files

- `SKILL.md` — the procedure, from "does it deserve a skill?" to publishing
- `references/standard.md` — frontmatter fields and limits, directories, progressive disclosure
- `references/description.md` — how to write triggers, with good and bad examples
- `references/budget.md` — the three costs, where a sentence goes, what to cut
- `references/checklist.md` — what to check before publishing
- `scripts/validate-skill.py` — the budgets and the structure, standard library only
- `CHANGELOG.md` — what changed in each version

## Run the validator

```bash
python3 skills/write-skill/scripts/validate-skill.py <skill-folder> [--strict] [--json]
npx skills-ref validate <skill-folder>    # the standard's own validator
```

Both should pass. See [references/checklist.md](references/checklist.md) for what neither can judge.
