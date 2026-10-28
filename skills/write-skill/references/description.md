# A description that triggers

The description is the only text loaded before the agent decides. It does two jobs: it makes the
agent pick the skill, and it keeps the agent from picking it when it should not.

## The formula

**What it does + when to use it + the words the user will type.**

```yaml
description: >
  Extracts text and tables from PDF files, fills PDF forms and merges PDFs.
  Use when working with PDF documents, filling a form, or extracting a table
  from a scanned file. Triggers: "PDF", "form", "extract table", "unir PDF",
  "rellenar formulario".
```

```yaml
description: Helps with PDFs.
```

The first one matches "merge these two PDFs" and "unir dos PDF" and refuses nothing that matters.
The second matches everything and tells the agent nothing.

## Checklist for the sentence

- **Verb first**: creates, reviews, extracts, converts, answers. Not "a skill about…".
- **Domain nouns** the user is likely to type: PDF, Helm, OWASP, OpenAPI, migration.
- **The moment**: "use when the user pastes an image", "before writing a single line of code",
  "when a file does not fit in its budget".
- **Negatives only when they prevent a wrong activation**: "does not run tests", "not for
  reviewing prose".
- **Length**: 1–1024 characters; stay under 500 here. It is loaded on every request.

## Triggers in the user's language

Write the triggers in the languages you actually receive requests in, with the words people use,
not the words you wish they used:

- English: "create a skill", "write a skill", "review this skill"
- Spanish: "crear una skill", "hazme una skill", "revisa esta skill"
- The artefact: "SKILL.md", "agents skill", "skill folder"

Do not translate the whole description unless the skill is only used in that language. Keywords in
one language plus an English description is usually enough.

## Do not

- **Do not list the table of contents.** "Covers naming, structure, validation and publishing" only
  repeats the body.
- **Do not use vague helpers.** "Helps with code", "improves quality", "assists developers".
- **Do not describe the implementation.** "Uses a Python script to parse YAML" is not a trigger.
- **Do not repeat the name.** `name: write-skill` plus "writes skills" wastes characters.
- **Do not promise what the body does not do.** A description that overreaches gets the skill
  loaded for work it cannot finish.

## Check the collision

Before writing, list what is installed:

```bash
ls ~/.claude/skills ~/.agents/skills .claude/skills .agents/skills ~/.config/opencode/skills 2>/dev/null
```

Two skills with the same name, or names one letter apart, make the agent choose at random. If a
skill already covers the job, extend it instead of shadowing it; if the name is taken and the job is
different, say so in the description ("unlike `x`, this one…") or rename.

## Test it

Read the description alone, without the body, and answer: for which three prompts should this load?
For which three should it not? If you cannot name them, the description is not finished. Put those
prompts in the PR or in the headless suite; the skill's own tests are the only proof that the
trigger works.
