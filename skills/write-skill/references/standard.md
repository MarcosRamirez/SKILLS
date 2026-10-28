# The Agent Skills standard

The format is small and open ([agentskills.io](https://agentskills.io/specification)). This file is
the part that changes what you write; the validator checks it.

## Directory

```text
skill-name/
  SKILL.md          required: YAML frontmatter + instructions
  references/       optional: documentation read on demand
  scripts/          optional: executable code
  assets/           optional: templates, images, data
```

The folder name is the skill name. Anything else in the folder is yours; `references/`, `scripts/`
and `assets/` are conventions, not requirements.

## Frontmatter

| Field | Required | Limits |
|---|---|---|
| `name` | yes | 1–64 chars, `a-z`, `0-9` and `-`, no leading or trailing `-`, no `--`, equal to the folder name |
| `description` | yes | 1–1024 chars; what it does and when to use it, with the words a user would type |
| `license` | no | a licence name, or a file shipped with the skill |
| `compatibility` | no | 1–500 chars; environment needs only (tools, packages, network) |
| `metadata` | no | map of string to string; this repo keeps `version`, `author`, links |
| `allowed-tools` | no | experimental; space-separated pre-approved tools, support varies by agent |

Supported tools vary. `allowed-tools: Read Write Edit Bash Glob Grep` is a ceiling, not a grant: the
agent still asks for permission where the client requires it.

## Progressive disclosure

Three stages, three costs:

1. **Discovery**: every installed skill's `name` and `description`, always loaded. In practice about
   100 tokens per skill; the size of your `description` is a cost paid on every request.
2. **Activation**: the whole `SKILL.md` body, once the description matches the task. The standard
   suggests staying under 5000 tokens and under 500 lines.
3. **Resources**: `references/`, `scripts/`, `assets/`, only when the agent decides it needs them.

This is why the body carries the procedure and the references carry the exceptions, the long
examples and the tables. A file the agent never opens costs nothing; a file it opens on every run
should have been in the body.

## Relative references

Link with paths relative to the skill folder: `references/api.md`, `scripts/extract.py`. Keep them
one level deep from `SKILL.md`. Do not chain: `SKILL.md` → `references/a.md` → `references/b.md`
hides half the content behind two reads and is hard to audit.

## Validation

Two tools, complementary:

```bash
npx skills-ref validate <skill-folder>
python3 scripts/validate-skill.py <skill-folder>
```

`skills-ref` is the reference implementation: name rules, frontmatter shape, description length.
`validate-skill.py` adds this repo's budgets, the relative-link check, the depth rule and the
reference hygiene. A skill ships when both pass.

## Versioning

The standard stores no version. This repo reads `metadata.version` (SemVer 2.0) and repeats it in
`.claude-plugin/marketplace.json`, because `claude plugin update` compares that copy. New skills
start at `0.0.1-alpha.1` and reach `1.0.0` when tested and stable.

## What the standard does not decide

- How long the body should be in your project. This repo sets its own target.
- Whether a skill needs scripts, references or neither.
- The wording of the description, and whether it covers more than one language.
- How a skill is distributed: `npx skills`, a plugin marketplace, a git submodule.

Those are project conventions. Write them down where the agent reads them.
