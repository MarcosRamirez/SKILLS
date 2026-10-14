# Closed questions with clickable answers

A **closed question** has a fixed set of answers: yes or no, one of 2–4 options, or "confirm
this step". Ask it with the question tool (`AskUserQuestion` in Claude Code). The user then
clicks an answer or types their own. Plain text is for open questions (and for the numbered
fallback below). Plan-mode approval has its own mechanism, see "What does not change".

## The rule

| # | Rule |
|---|---|
| 1 | Every closed question is asked with the question tool, never as plain text. The question sits on top, the options are buttons below, and the free-text field is below them: the user clicks **or** types. |
| 2 | Format: the recommended option comes first, marked "(Recommended)" in the user's language; each option has a one-line consequence; labels are concrete actions, not a bare "Yes" or "No". |
| 3 | Open questions (a name, a URL, a description) stay as text. No forced buttons. |
| 4 | Several closed questions go in one call, up to 4, never one after another. |
| 5 | Without the question tool, the options are numbered in text. |
| 6 | Unchanged: plan approval in plan mode keeps its own mechanism. A failed or skipped question is not approval. |

Closed questions include confirming a merge or a push, approving a spec or a change notice,
and choosing a branch or a release stage.

## Click or type

The question tool shows the question on top, the options as buttons below, and a free-text
field (**Other**) under them. The tool always adds that field, so the user can click an option
or type an answer to the same question.

A typed answer is read like a chat reply. "Other: first update the README" is an answer, not
one of the options. If a typed answer is unclear, ask again.

## Format

| Part | Rule | Example |
|---|---|---|
| Question | A short question, with the facts the answer depends on | "PR #30 is green. Merge it?" |
| Options | 2 for yes/no; 2 to 4 in general | Yes and no; three release stages |
| Order | The recommended option comes first | First button |
| Recommended mark | "(Recommended)" at the end of its label, in the user's language | "Yes, merge (Recommended)" |
| Label | A concrete action, never a bare "Yes", "No" or "OK" | "Yes, merge" / "No, not yet" |
| Consequence | One line per option: what happens next | "merge commit, branch deleted" |
| Language | The user's language, whatever language the files are in | Spanish: "Sí, fusionar (Recomendado)" |

The question tool allows 1 to 4 questions per call and 2 to 4 options per question.

## Open questions stay as text

A name, a URL, a number or a description has no fixed answers, so it gets no buttons. Ask it in
plain text and wait for the reply. Do not invent options ("Name it A or B?") just to look
interactive.

## Several closed questions at once

Closed questions that come up together go in one call, each with its own options. Up to 4 per
call. Do not ask them one after another. A fifth question goes in the next call.

## Without the question tool

Agents without a question tool write the options as a numbered list in text, with the
recommended one first, and wait for the answer:

```text
PR #30 is green. Merge it?
1) Yes, merge (Recommended): merge commit, branch deleted
2) No, not yet: leave it open for review
```

The user answers with the number or in words ("1", "yes, merge"). Both work. A numbered question
is still a question: nothing happens until an answer comes back. A headless run has nobody to
answer, so it stops after the drafts, as hard rule 3 in SKILL.md says.

## What does not change

- **Plan approval in plan mode** keeps its own approval mechanism. This rule does not replace it.
- **A failed or skipped question is not approval** (SPEC-0003). A question that fails, is
  skipped, times out or cannot be shown is no answer. No answer means no decision, and no
  decision means no code. Never pick "sensible defaults" to get past the approval gate
  (hard rules 1 and 2 in SKILL.md).

## Examples

The examples are shown as text. In Claude Code the options appear as buttons, with the
free-text field below them.

### Merge confirmation

Good:

```text
PR #30 is green. Merge it?
  [Yes, merge (Recommended)]  merge commit, branch deleted
  [No, not yet]               leave it open for review
  Other: ______
```

Bad:

```text
Should I merge it? (y/n)
```

### Approving a spec

Good:

```text
The spec for 0001-bookings is ready. Approve it so implementation can start?
  [Yes, approve the spec (Recommended)]  implementation starts on its own branch
  [No, I want changes first]             the spec stays Draft; tell me what to change
  Other: ______
```

Bad:

```text
Do you approve the spec? Reply yes or no.
```

### Choosing a release stage

Good:

```text
Features for 0.4.0 are done. Which release stage do you want?
  [Beta 0.4.0-beta.1 (Recommended)]  external testers; bugs expected, no stability promise
  [Keep alpha 0.4.0-alpha.3]         internal use only; testers get nothing yet
  [Release candidate 0.4.0-rc.1]     only blocker fixes from now on
  Other: ______
```

Bad:

```text
Which version should I release: beta, stable or alpha?
```
