#!/usr/bin/env bash
# Headless suite for senior-mindset (SPEC-0028): runs `claude -p` on scratch projects with the
# working copy of the skill and makes deterministic checks on files, git state and the stream.
#
# Usage: bash tests/headless/run.sh [--only NAME] [--runs N] [--isolated-home] [--list]
#   --only NAME       run one scenario (file name in scenarios/ without .sh)
#   --runs N          runs per scenario (default: each scenario's SCENARIO_RUNS)
#   --isolated-home   point HOME/USERPROFILE at an empty temp folder (needs credentials in the
#                     environment: ANTHROPIC_API_KEY or CLAUDE_CODE_OAUTH_TOKEN; used
#                     automatically when one of them is set)
#   --list            list the scenarios and exit
#
# Environment: HEADLESS_MODEL, HEADLESS_MAX_BUDGET_USD (default 10, per run), HEADLESS_TIMEOUT
# (seconds, default 1800), HEADLESS_SKILL_DIR (test another copy of the skill), CLAUDE_BIN, PYTHON.
#
# Exit: 0 all passed; 1 any check failed, a run errored or a user file changed; 2 nothing failed
# but some runs were skipped (usage limit). Raw streams and scratch projects stay in temp folders.
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

only="" runs_override="" isolated_home=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --only) only=${2:?--only needs a scenario name}; shift 2 ;;
    --runs) runs_override=${2:?--runs needs a number}; shift 2 ;;
    --isolated-home) isolated_home=true; shift ;;
    --list)
      for file in "$HEADLESS_DIR"/scenarios/*.sh; do basename "$file" .sh; done
      exit 0 ;;
    -h|--help) awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown option: $1 (see --help)" >&2; exit 64 ;;
  esac
done
if [[ -n $runs_override && ! $runs_override =~ ^[1-9][0-9]*$ ]]; then
  echo "--runs must be a positive number" >&2; exit 64
fi

find_python || exit 1
command -v "${CLAUDE_BIN:-claude}" >/dev/null 2>&1 || { echo "error: claude not found" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "error: git not found" >&2; exit 1; }
[[ -f $SKILL_SOURCE/SKILL.md ]] || { echo "error: no SKILL.md in $SKILL_SOURCE" >&2; exit 1; }

scenario_files=()
for file in "$HEADLESS_DIR"/scenarios/*.sh; do
  if [[ -z $only || $(basename "$file" .sh) == "$only" ]]; then scenario_files+=("$file"); fi
done
if [[ ${#scenario_files[@]} -eq 0 ]]; then echo "error: no scenario named '$only' (see --list)" >&2; exit 64; fi

export HEADLESS_MAX_BUDGET_USD="${HEADLESS_MAX_BUDGET_USD:-10}"
REPORT_DIR="$(new_temp_dir skills-headless)"
if [[ $isolated_home == true || -n ${ANTHROPIC_API_KEY:-} || -n ${CLAUDE_CODE_OAUTH_TOKEN:-} ]]; then
  export HEADLESS_HOME="$REPORT_DIR/home"
  mkdir -p "$HEADLESS_HOME"
  home_mode="isolated ($HEADLESS_HOME)"
else
  home_mode="real home, edits limited by acceptEdits, user files hashed"
fi

skill_version="$(tr -d '\r' < "$SKILL_SOURCE/SKILL.md" | sed -n 's/^ *version: *"\{0,1\}\([^"]*\)"\{0,1\} *$/\1/p' | head -1)"
echo "Headless suite: senior-mindset $skill_version from $SKILL_SOURCE"
echo "Claude Code:    $("${CLAUDE_BIN:-claude}" --version 2>/dev/null | head -1)"
echo "Home:           $home_mode"
echo "Reports:        $REPORT_DIR"
echo

snapshot_user_files "$REPORT_DIR/user-files.before"

# Runs one scenario once, in a subshell so scenario functions never leak between scenarios.
# Writes outcome, cost, model and version files into RUN_DIR.
run_scenario_once() {  # run_scenario_once SCENARIO_FILE RUN_DIR
  (
    local scenario_file=$1 run_dir=$2 project outcome
    source "$scenario_file"
    export CHECKS_FILE="$run_dir/checks.tsv"
    : > "$CHECKS_FILE"
    project="$(new_temp_dir "headless-$(basename "$scenario_file" .sh)")"
    echo "$project" > "$run_dir/project-path"
    scenario_setup "$project"
    snapshot_user_files "$run_dir/user-files.before"

    run_claude "$project" "$run_dir" "$SCENARIO_PROMPT"
    local stream="$run_dir/stream.jsonl"
    stream_py info "$stream" > "$run_dir/info"
    outcome="$(sed -n 's/^outcome=//p' "$run_dir/info")"
    if [[ $outcome == no_result ]] && grep -Eiq 'usage limit|rate.?limit|429' "$run_dir/stderr.txt"; then
      outcome=usage_limit
    fi
    sed -n 's/^cost=//p' "$run_dir/info" > "$run_dir/cost"
    sed -n 's/^model=//p' "$run_dir/info" > "$run_dir/model"
    sed -n 's/^version=//p' "$run_dir/info" > "$run_dir/version"

    echo "    project: $project"
    local turns
    turns="$(sed -n 's/^num_turns=//p' "$run_dir/info")"
    echo "    stream:  $stream (exit $(cat "$run_dir/exit-code"), ${turns:-?} turns, $(cat "$run_dir/cost") USD)"
    case $outcome in
      usage_limit)
        echo "SKIPPED: usage limit" > "$run_dir/outcome"
        echo "    SKIPPED: usage limit ($(stream_py result "$stream" | head -1))"
        return 0 ;;
      not_logged_in)
        echo "ERROR: not logged in" > "$run_dir/outcome"
        echo "    ERROR: not logged in ($(stream_py result "$stream" | head -1))"
        return 0 ;;
      no_result)
        echo "ERROR: no result event" > "$run_dir/outcome"
        echo "    ERROR: no result event (timeout or crash; see stderr.txt)" ;;
      error)
        echo "ERROR: $(sed -n 's/^subtype=//p' "$run_dir/info")" > "$run_dir/outcome"
        echo "    ERROR: the run ended with an error: $(stream_py result "$stream" | head -1)" ;;
    esac

    check "senior-mindset loaded from the working copy" assert_plugin_from "$stream" "$run_dir/plugin/senior-mindset"
    scenario_checks "$project" "$stream"
    snapshot_user_files "$run_dir/user-files.after"
    check "user-level files unchanged" compare_snapshots "$run_dir/user-files.before" "$run_dir/user-files.after"

    info "skills invoked: $(stream_py skills "$stream" | tr '\n' ' ')"
    info "question tool calls: $(stream_py tool-inputs "$stream" AskUserQuestion | wc -l | tr -d ' ') (answered by the stub: $(cat "$run_dir/stub-calls.log" 2>/dev/null | wc -l | tr -d ' '))"
    info "permission denials: $(stream_py denials "$stream" | wc -l | tr -d ' ')"
    stream_py denials "$stream" | cut -c1-160 | sed 's/^/            /'
    info "other plugins: $(stream_py plugins "$stream" | awk -F'\t' '$1 != "senior-mindset" && $3 != "builtin" { printf "%s ", $1 }')"

    if [[ ! -s $run_dir/outcome ]]; then
      if grep -q '^FAIL' "$CHECKS_FILE"; then echo FAIL > "$run_dir/outcome"; else echo PASS > "$run_dir/outcome"; fi
    fi
  )
}

rows=()
for scenario_file in "${scenario_files[@]}"; do
  name="$(basename "$scenario_file" .sh)"
  runs="$runs_override"
  if [[ -z $runs ]]; then runs="$(source "$scenario_file"; echo "${SCENARIO_RUNS:-1}")"; fi
  echo "== $name: $(source "$scenario_file"; echo "$SCENARIO_DESCRIPTION")"
  for ((run = 1; run <= runs; run++)); do
    run_dir="$REPORT_DIR/$name/run-$run"
    mkdir -p "$run_dir"
    echo "  run $run/$runs"
    run_scenario_once "$scenario_file" "$run_dir"
    rows+=("$name|$run/$runs|$run_dir")
  done
  echo
done

snapshot_user_files "$REPORT_DIR/user-files.after"
if hash_report="$(compare_snapshots "$REPORT_DIR/user-files.before" "$REPORT_DIR/user-files.after")"; then
  hash_ok=true
else
  hash_ok=false
fi

passed=0 failed=0 skipped=0 total_cost=0 models="" versions=""
printf '%-22s %-6s %-22s %-8s %s\n' scenario run outcome checks "cost (USD)"
for row in "${rows[@]}"; do
  IFS='|' read -r name run run_dir <<< "$row"
  outcome="$(cat "$run_dir/outcome" 2>/dev/null || echo "ERROR: runner")"
  checks_passed="$(grep -c '^PASS' "$run_dir/checks.tsv" 2>/dev/null)"
  checks_total="$(grep -c . "$run_dir/checks.tsv" 2>/dev/null)"
  cost="$(cat "$run_dir/cost" 2>/dev/null || echo 0)"
  total_cost="$(awk -v a="$total_cost" -v b="${cost:-0}" 'BEGIN { printf "%.4f", a + b }')"
  models+="$(cat "$run_dir/model" 2>/dev/null) "
  versions+="$(cat "$run_dir/version" 2>/dev/null) "
  case $outcome in
    PASS) passed=$((passed + 1)) ;;
    SKIPPED*) skipped=$((skipped + 1)) ;;
    *) failed=$((failed + 1)) ;;
  esac
  printf '%-22s %-6s %-22s %-8s %.2f\n' "$name" "$run" "$outcome" "${checks_passed:-0}/${checks_total:-0}" "${cost:-0}"
done
echo
echo "Runs: ${#rows[@]} · passed $passed · failed $failed · skipped $skipped · cost $(printf '%.2f' "$total_cost") USD"
models="$(printf '%s\n' $models | sort -u | tr '\n' ' ' | sed 's/ *$//')"
versions="$(printf '%s\n' $versions | sort -u | tr '\n' ' ' | sed 's/ *$//')"
echo "Model: ${models:-unknown} · Claude Code ${versions:-unknown}"
if [[ $hash_ok == true ]]; then
  echo "User-level files unchanged over the whole run (sha256 before = after):"
else
  echo "FAIL: user-level files changed during the run:"
fi
printf '%s\n' "$hash_report" | sed 's/^/  /'
echo "Reports: $REPORT_DIR"

if [[ $failed -gt 0 || $hash_ok != true ]]; then exit 1; fi
if [[ $skipped -gt 0 ]]; then exit 2; fi
exit 0
