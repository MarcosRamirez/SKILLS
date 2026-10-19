# Help in any language (SPEC-0014 AC-2, AC-2b): asking what the skill can do, in an empty folder,
# in Spanish, English and French, gets the list of commands and a configuration summary in the
# language of the question, and does nothing else: no kickoff, no question, no file written.
#
# Run 3 times: run 1 asks in Spanish, run 2 in English, run 3 in French. The language check counts
# function words that belong to only one of the three languages (see LANGUAGE_WORDS).

SCENARIO_DESCRIPTION="'what can you do?' in Spanish, English and French lists the commands in that language and changes nothing"
SCENARIO_RUNS=3
SCENARIO_ALLOWED_TOOLS="Bash(git:*),Bash(ls:*),Bash(cat:*)"
SCENARIO_QUESTION_TOOL=error

case ${HEADLESS_RUN:-1} in
  1) HELP_LANGUAGE=es; SCENARIO_PROMPT="¿qué puedes hacer?" ;;
  2) HELP_LANGUAGE=en; SCENARIO_PROMPT="what can you do?" ;;
  *) HELP_LANGUAGE=fr; SCENARIO_PROMPT="qu'est-ce que tu sais faire ?" ;;
esac

# Words that exist in one language only (among es, en, fr). Shared ones (la, un, plan, de) are left out.
LANGUAGE_WORDS_es='los|las|para|con|por|puedo|puedes|también|está|estás|proyecto|ayuda|una|del|según|más'
LANGUAGE_WORDS_en='the|and|with|for|you|your|can|this|that|what|is|are|will|when'
LANGUAGE_WORDS_fr='les|des|pour|avec|une|est|vous|peux|dans|sur|aussi|je|mes|tes|ton|votre'

# One pattern per command, in the three languages: the answer must mention every one of them.
COMMAND_GROUPS=(
  "help=help|ayuda|aide|ay[uú]d"
  "status=status|estado|[ée]tat|statut"
  "list plans=planes|plans|plan"
  "run plan=run plan|ejecut|lance|ex[ée]cut"
  "release=release|versi[oó]n|publi|lanz"
  "reconfigure=reconfigur"
  "automations=automati|automat"
)
CONFIG_WORDS='configur|convention|AGENTS|kickoff|setup|ajustes|param[eè]tr|senior-mindset\.md'
WRITE_COMMAND="${COMMAND_START}(mkdir|touch|rm|mv|cp|tee|sed[[:space:]]+-i|git[[:space:]]+(init|add|commit|switch|checkout|branch|tag|stash|merge|push))([[:space:]\"]|\\\\n|\$)"

scenario_setup() {  # an empty folder, not even a repository
  local dir=$1
  save_baseline "$dir"
}

count_words() {  # count_words ERE: words of stdin that match ERE (whole words, case-insensitive)
  grep -Eio "[[:alpha:]À-ÿ']+" | grep -Eic -- "^($1)\$"
}

assert_answer_language() {  # assert_answer_language STREAM LANG
  local text lang counts best=0 best_lang="" mine=0 pattern
  text="$(stream_py result "$1")"
  for lang in es en fr; do
    eval "pattern=\$LANGUAGE_WORDS_$lang"
    counts="$(printf '%s\n' "$text" | count_words "$pattern")"
    echo "$lang marker words: $counts"
    if [[ $lang == "$2" ]]; then mine=$counts; fi
    if (( counts > best )); then best=$counts best_lang=$lang; fi
  done
  [[ $best_lang == "$2" && $mine -ge 5 ]] || { echo "expected $2 (at least 5 markers and the most), best is ${best_lang:-none}"; return 1; }
}

assert_lists_commands() {  # assert_lists_commands STREAM
  local text group name pattern missing=0
  text="$(stream_py result "$1")"
  for group in "${COMMAND_GROUPS[@]}"; do
    name=${group%%=*} pattern=${group#*=}
    if printf '%s\n' "$text" | grep -Eiq -- "$pattern"; then echo "$name: mentioned"; else echo "$name: NOT mentioned"; missing=1; fi
  done
  return $missing
}

assert_mentions_configuration() {  # assert_mentions_configuration STREAM
  local hit
  hit="$(stream_py result "$1" | grep -Ei -m1 -- "$CONFIG_WORDS")"
  if [[ -n $hit ]]; then echo "$(printf '%s' "$hit" | cut -c1-150)"; else echo "no line about the configuration (/$CONFIG_WORDS/)"; return 1; fi
}

assert_no_edit_tools() {  # assert_no_edit_tools STREAM: no Write, Edit or NotebookEdit call
  local used
  used="$(stream_py tools "$1" | grep -E '^(Write|Edit|NotebookEdit)$' | sort | uniq -c)"
  if [[ -n $used ]]; then echo "$used"; return 1; fi
  echo "tools used: $(stream_py tools "$1" | sort | uniq -c | tr '\n' ' ')"
}

assert_no_question_calls() {  # assert_no_question_calls STREAM
  local calls
  calls="$(question_calls "$1" | grep -c .)"
  echo "question tool calls: $calls"
  [[ $calls -eq 0 ]]
}

assert_nothing_created() {  # assert_nothing_created PROJECT: no file and no repository
  assert_files_unchanged "$1" || return 1
  if [[ -e $1/.git ]]; then echo ".git was created"; return 1; fi
  echo "no .git, no file"
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  info "prompt ($HELP_LANGUAGE): $SCENARIO_PROMPT"
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "the answer lists the commands" assert_lists_commands "$stream"
  check "the answer summarises the configuration" assert_mentions_configuration "$stream"
  check "the answer is in the language of the question ($HELP_LANGUAGE)" assert_answer_language "$stream" "$HELP_LANGUAGE"
  check "no question tool call (no kickoff, no interview)" assert_no_question_calls "$stream"
  check "no write command and no Write or Edit call" assert_no_edit_tools "$stream"
  check "no command that changes anything" assert_no_command "$stream" "$WRITE_COMMAND"
  check "nothing created: no file, no repository" assert_nothing_created "$project"
}
