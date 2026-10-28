# Checklist before publishing a skill

Run the two validators first; this list is what they cannot judge.

```bash
python3 scripts/validate-skill.py <skill-folder>
npx skills-ref validate <skill-folder>
```

## The job

- [ ] The procedure is repeated, not a one-off, and no installed skill already does it.
- [ ] The name is the job, in kebab-case, equal to the folder, and collides with nothing installed.
- [ ] The description says what, when and the user's words, in every language you receive requests in.
- [ ] Reading the description alone, you can name three prompts that must load it and three that must not.

## The body

- [ ] Every step is in the order the work happens.
- [ ] Every rule changes behaviour; nothing explains the topic for its own sake.
- [ ] Every example is the shortest that shows the shape, and appears once.
- [ ] Under the target (100 lines, 800 words) or the excess is deliberate and justified.
- [ ] No long code block: the code is a file under `scripts/`.

## The structure

- [ ] Each reference covers one topic, is linked from the body with "read this when", and is under
  150 lines.
- [ ] No reference links to another reference, and no folder inside `references/`.
- [ ] No content duplicated between the body and a reference.
- [ ] `assets/` holds templates and data, not prose.
- [ ] Every relative link resolves from the file that contains it.

## The release

- [ ] `metadata.version` is SemVer: `0.0.1-alpha.1` for a new skill.
- [ ] The project's manifest repeats that version, when the project has one.
- [ ] The READMEs, the inventory and the roadmap are updated in the same change.
- [ ] The description in the manifest matches the one in `SKILL.md`.
- [ ] Licence, author and links are set.
- [ ] The PR carries the checks that ran and, when the project has one, the behaviour test.
