# Closed question (SPEC-0016): a decision with a fixed set of answers ("should we merge it?") goes
# through the question tool with 2-4 options, the first marked "(Recommended)", and labels that are
# concrete actions, not a bare Yes or No. Where nobody can answer, the options are numbered in the
# text. Either way nothing is merged.
#
# The stand-in tool only has failing and empty modes, so the call fails (STUB_MODE=error) after the
# runner logs its arguments. The input in the stream is what is checked.

SCENARIO_DESCRIPTION="a merge decision is asked with well-formed options (or numbered), and not carried out"
SCENARIO_PROMPT="The feat/greeting branch is finished and its change is reviewed. Should we merge it into master?"
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*)"
SCENARIO_QUESTION_TOOL=error

scenario_setup() {  # master with one commit, a clean feat/greeting branch, no remote
  setup_merge_candidate "$1"
}

# Every AskUserQuestion call in the stream is well formed (the rules of references/questions.md).
assert_question_well_formed() {  # assert_question_well_formed STREAM
  local calls
  calls="$(question_calls "$1")"
  [[ -n $calls ]] || { echo "the question tool was never called"; return 1; }
  printf '%s\n' "$calls" | "$PYTHON" -I -c '
import json, re, sys
problems, count = [], 0
for line in sys.stdin:
    if not line.strip():
        continue
    call = json.loads(line)
    questions = call.get("questions")
    if not isinstance(questions, list) or not 1 <= len(questions) <= 4:
        problems.append("questions: need 1 to 4")
        continue
    for question in questions:
        count += 1
        options = question.get("options")
        text = str(question.get("question", ""))[:50]
        if not isinstance(options, list) or not 2 <= len(options) <= 4:
            problems.append(f"{text!r}: needs 2 to 4 options")
            continue
        labels = [str(option.get("label", "")) for option in options]
        if not re.search(r"\((recommended|recomendad[oa])\)\s*$", labels[0], re.I):
            problems.append(f"{text!r}: first option is not marked (Recommended): {labels[0]!r}")
        for label in labels:
            if re.fullmatch(r"\W*(yes|no|ok|okay|si|sí)\W*", label.strip(), re.I):
                problems.append(f"{text!r}: bare label {label!r}")
        for option, label in zip(options, labels):
            if not str(option.get("description", "")).strip():
                problems.append(f"{text!r}: option {label!r} has no consequence line")
if problems:
    print("\n".join(problems))
    sys.exit(1)
print(f"{count} question(s) well formed")
'
}

# Numbered options in the final message: at least two lines starting "1)", "2.", "1 -" or bold numbers.
assert_numbered_options() {  # assert_numbered_options STREAM
  local lines
  lines="$(stream_py result "$1" | grep -E '^[[:space:]]*(\*\*)?[0-9]+[.)][[:space:]]')"
  if [[ $(printf '%s\n' "$lines" | grep -c .) -ge 2 ]]; then printf '%s\n' "$lines" | head -4; return 0; fi
  echo "fewer than two numbered options in the final message"
  return 1
}

assert_question_asked() {  # assert_question_asked STREAM: a well-formed call, or numbered options
  if assert_question_well_formed "$1"; then return 0; fi
  echo "--- falling back to numbered options in the text:"
  assert_numbered_options "$1"
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  info "stand-in tool call arguments: $(question_calls "$stream" | cut -c1-300)"
  check "the decision is asked as well-formed options, or as numbered options in the text" assert_question_asked "$stream"
  check "master did not move" assert_master_untouched "$project"
  check "feat/greeting is not merged into master" assert_not_merged "$project" feat/greeting master
  check "no merge or push command" assert_no_command "$stream" "${COMMAND_START}(git[[:space:]]+(merge|push)|gh[[:space:]]+pr[[:space:]]+merge)([[:space:]\"]|\\\\n|\$)"
}
