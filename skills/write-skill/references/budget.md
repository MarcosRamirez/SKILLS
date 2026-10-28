# Budgets and what to cut

A skill is cheap because of *when* each file is read, not because it is short. Use the budgets to
decide where a sentence belongs.

## The three costs

| What | When it is paid | Budget |
|---|---|---|
| `name` + `description` | every request, for every installed skill | ~100 tokens; description ≤500 chars here |
| `SKILL.md` body | every activation | 500 lines / ~5000 tokens hard; 100 lines / 800 words here |
| `references/`, `scripts/`, `assets/` | only when read | a focused file, ~150 lines each |

A description twice as long is a cost on every request, even for prompts that never load the skill.
The body is a cost on every activation. A reference is a cost only on the runs that need it, which is
why the exceptions and the long examples belong there.

## Numbers that are good enough

- **Lines**: `wc -l`. Count the whole `SKILL.md`, frontmatter included.
- **Words**: `wc -w` on the body. Counts every code line too, so it is a proxy, not a truth.
- **Tokens**: estimate `ceil(characters / 4)` for English prose. Code, tables and non-Latin text run
  higher; treat the estimate as a lower bound.
- **Measure after writing**, not before: the validator prints lines, words and estimated tokens on
  one line, so the diff shows the cost of an edit.

## Warning or error

| Rule | Here | Standard |
|---|---|---|
| `SKILL.md` lines | warn over 100 | error over 500 |
| `SKILL.md` words | warn over 800 | none |
| `SKILL.md` estimated tokens | none | error over 5000 |
| description chars | warn over 500 | error over 1024 |
| reference lines | warn over 150 | none |
| reference linked by the body | warn when missing | none |

The hard limits come from the standard; the warnings are this repo's opinion. `--strict` makes
warnings fail, which is how this skill checks itself.

## Where a sentence goes

| The sentence… | Goes to |
|---|---|
| is needed every time the skill runs | `SKILL.md` body |
| is needed for one kind of task | a reference, linked with when to read it |
| is a table or a long example | a reference |
| is code the agent runs | `scripts/` |
| is a template or sample data | `assets/` |
| explains the topic but changes nothing | nowhere: delete it |

## What to cut, in this order

1. **Prose that explains.** Turn "it is important to keep the body short because…" into "Keep the
   body short." If the reason matters, one clause, not a paragraph.
2. **Duplicates.** The same rule in the body and in a reference. Keep the body's version, delete the
   other, or move it and leave a link when it only matters for one path.
3. **Examples per rule.** One example per rule, the shortest that shows the shape. A second example
   of the same rule is usually a reader's luxury.
4. **Exhaustive tables.** Keep the rows the agent will use; move the rest to a reference nobody pays
   for until asked.
5. **History.** "We used to…", "since version 1.2…", changelog entries. Versions live in the
   changelog and in git.

## Anti-patterns

- **The doc dump.** The whole manual in `SKILL.md` "so it is all in one place". It is all in context,
  on every activation, and half of it is wrong for the current task.
- **Reference roulette.** Ten tiny references with no "read this when" line. The agent guesses, or
  reads five.
- **The chain.** `SKILL.md` → `a.md` → `b.md` → `c.md`. Two of the three reads are avoidable; flatten.
- **Copy-paste references.** The same checklist in `references/` and in `SKILL.md`. They drift.
- **Scripts as prose.** A 60-line program in a code block. Put it in `scripts/`, let the agent run it.
- **The kitchen sink.** "It also cleans your room." A second job is a second skill; two descriptions
  can both be right, one description cannot be two.

## When it does not fit

Do not split by size alone. Split by **activation**: a task that only some runs need becomes a
reference; a task that every run needs stays in the body, smaller. If the body is over the hard
limit, the skill is doing two jobs: write the second skill.

## A worked trim

Before (42 lines): the standard's field table, the naming regex, two examples per field, the
publishing steps, and a paragraph on why descriptions matter.

After (11 lines): one sentence per field with a link to the standard, the rule, one example, the
publishing commands. The table moved to a reference; the rationale was deleted; the example count went
from four to one. Same procedure, a third of the cost.
