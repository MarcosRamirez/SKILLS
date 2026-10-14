# SPEC-0016 tasks

One branch per task, stacked PRs. Executed through PLAN-0016.

- [x] T-1 Rule in `SKILL.md` always-on rules + `references/questions.md` (AC-1)
- [x] T-2 Interactive and headless tests (AC-2, AC-3)
- [x] T-3 Release (minor), docs, changelogs; last PR carries `Closes-Spec: SPEC-0016`

## Test results (T-2, 2026-10-14)

Scratch repo (master + `feat/greeting` adding `greeting.py`, a `CLAUDE.md` with an
"Engineering conventions" section), `claude -p ... --plugin-dir skills/senior-mindset
--output-format stream-json --verbose` (Claude Code 2.1.296).

- **The CLI does not expose `AskUserQuestion` in headless mode.** It is missing from the
  `tools` list of the init event with `-p`, with `--tools ...,AskUserQuestion`, and with
  `--input-format stream-json`. So AC-2 cannot be run against the real tool headless.
- **AC-2 (verified by proxy, not in a UI).** A stub MCP server exposing a tool named
  `AskUserQuestion` with the real schema and description was added with `--mcp-config`. In the
  English and Spanish runs the agent called it with a well-formed closed question: 1 question,
  3 options, recommended option first and marked "(Recommended)", concrete labels, a one-line
  description per option. Rendering the buttons and the free-text field is the client's job and
  was not observed; the interactive check stays with the user (see PLAN-0016 Verification).
  Caveat: in the Spanish run the marker stayed "(Recommended)" instead of "(Recomendado)".
- **AC-3 (passes).** With the tool absent (run with `--plugin-dir` only), and with the tool
  failing ("no UI available"), the agent wrote numbered options with the recommended one first,
  said the failed question is no answer, and decided nothing: `git log master` unchanged,
  `feat/greeting` not merged, working tree clean.
- **Finding, not fixed here:** when the prompt does not load senior-mindset (the plain
  "should we merge?" prompts loaded only `git-workflow`), the rule is not in context. With the
  tool available but the skill not loaded, the agent merged on its own in two of two Spanish
  runs. The skill's description does not trigger on merge-only requests.
