# SPEC-0016: closed questions with clickable answers

Status: Implemented
Implemented: 2026-10-14, PR #51
Date: 2026-10-13
Approved by: the user, 2026-10-13, "implementa todas las fases, una a una, con subagentes"

## Problem

The skill asks many yes/no and pick-one questions ("Merge it?", "Approve the spec?"). Asked as
plain text, they force the user to type or dictate an answer. Claude Code can show clickable
options plus a free-text field in the same question, but the skill never requires it.

## Requirements

- R-1 **Every closed question** (yes/no, pick one of 2–4 options, confirm a step) is asked with
  `AskUserQuestion`, never as a plain-text question. For example: confirming a merge or a push,
  approving a spec or a change notice, choosing a branch or a release stage.
- R-1b **Question, buttons and a free-text field together:** the question on top, the options as
  buttons below (2 for yes/no, up to 4), and below them the "Other" field, where the user can
  type their own answer instead of clicking. `AskUserQuestion` always adds that field, and that is
  the point: click **or** type, in the same question. A typed answer is read like a chat reply.
- R-2 **Format:**
  - the recommended option comes first, marked "(Recommended)" in the user's language;
  - each option has a one-line consequence;
  - yes/no options are concrete actions ("Yes, merge" / "No, not yet"), not a bare "Yes" / "No";
  - everything is in the user's language.
- R-3 **Open questions** (a name, a URL, a description) stay as text: no forced buttons.
- R-4 **Several closed questions at once** go in a single call (max 4), not one after another.
- R-5 **Fallback** in agents without the tool (see SPEC-0013): numbered options in text
  ("1) Yes, merge · 2) No, not yet"); answering with the number or in words both work.
- R-6 **Unchanged:** plan approval in plan mode keeps its own (also clickable) mechanism, and the
  approval hard rule stands: a failed or skipped question is not approval (SPEC-0003).

## Acceptance criteria

- AC-1 `SKILL.md` has the rule among the always-on rules, with the format and the fallback.
- AC-2 Interactive test: a task ending in "merge it?" shows the question, buttons and the free-text field.
- AC-3 Headless test: with no question tool available, the numbered fallback appears and no decision is taken for the user.

## Out of scope

- Changing how plan mode asks for plan approval.
