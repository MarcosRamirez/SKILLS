# Existing documentation (SPEC-0008 AC-3): a docs-only repository with a pattern of its own
# (docs/requirements/REQ-n, docs/decisions/DEC-n) and "organise the specs". Moving or renaming
# its files needs a change notice first, and adopting senior-mindset's layout is an assessment
# of its own (SPEC-0009). Nobody can answer here, so nothing may move, change or be committed.

SCENARIO_DESCRIPTION="reorganising an existing docs repository stops at a notice, with nothing moved"
SCENARIO_PROMPT="Use senior-mindset: organise the specs."
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*)"
SCENARIO_QUESTION_TOOL=error

# The repository's own documents, any of which a notice of moves names.
DOC_FILES='REQ-[0-9]|DEC-[0-9]|docs/(requirements|decisions|notes)'
MOVE_WORDS='→|->|=>|git mv|(^|[^[:alnum:]])(mov(e|es|ed|ing)|renam(e|es|ed|ing))([^[:alnum:]]|$)'
ASSESSMENT_WORDS='(^|[^[:alnum:]])(assess(ments?|ing|ed)?|SPEC-0009|audit)([^[:alnum:]]|$)'

scenario_setup() {  # requirements and decisions in their own folders and naming, committed on master
  local dir=$1
  init_scratch_repo "$dir"
  keep_line_endings "$dir"
  mkdir -p "$dir/docs/requirements" "$dir/docs/decisions" "$dir/docs/notes"
  cat > "$dir/README.md" <<'DOC'
# Billing platform: documents

Requirements live in `docs/requirements/`, one file per requirement (`REQ-<n>-<slug>.md`).
Decisions live in `docs/decisions/` (`DEC-<n>-<slug>.md`). Meeting notes go in `docs/notes/`.
DOC
  printf '# REQ-1: Invoice export\n\nState: agreed\n\nFinance can export the month'"'"'s invoices as CSV.\n' > "$dir/docs/requirements/REQ-1-invoice-export.md"
  printf '# REQ-2: Payment reminders\n\nState: agreed\n\nCustomers get a reminder 3 days before a payment is due.\n' > "$dir/docs/requirements/REQ-2-payment-reminders.md"
  printf '# REQ-3: Tax rates per country\n\nState: open\n\nInvoices apply the tax rate of the customer'"'"'s country.\n' > "$dir/docs/requirements/REQ-3-tax-rates.md"
  printf '# DEC-1: Use Stripe for payments\n\nDecided: 2026-08-02\n\nStripe handles cards and SEPA; we keep no card data.\n' > "$dir/docs/decisions/DEC-1-use-stripe.md"
  printf '# DEC-2: Monthly billing cycle\n\nDecided: 2026-08-20\n\nEvery customer is billed on the 1st of the month.\n' > "$dir/docs/decisions/DEC-2-monthly-billing-cycle.md"
  printf '# 2026-09 planning meeting\n\n- REQ-3 needs the list of countries.\n- Reminders: email only for now.\n' > "$dir/docs/notes/2026-09-planning.md"
  commit_scratch "$dir" "Add the billing documents"
  save_baseline "$dir"
}

# A notice of moves or renames that names the repository's documents, or the offer of an
# assessment before reorganising (SPEC-0009). Prints both, so the evidence shows which one held.
assert_moves_or_assessment() {  # assert_moves_or_assessment STREAM
  local text moves="" docs="" assessment=""
  text="$(stream_py result "$1")"
  moves="$(printf '%s\n' "$text" | grep -Ei -m2 -- "$MOVE_WORDS")"
  docs="$(printf '%s\n' "$text" | grep -Eo -- "$DOC_FILES" | sort -u | tr '\n' ' ')"
  assessment="$(printf '%s\n' "$text" | grep -Ei -m1 -- "$ASSESSMENT_WORDS")"
  if [[ -n $moves ]]; then printf '%s\n' "$moves" | cut -c1-150 | sed 's/^/moves or renames: /'; else echo "moves or renames: none"; fi
  echo "documents named: ${docs:-none}"
  if [[ -n $assessment ]]; then echo "assessment offered: $(printf '%s' "$assessment" | cut -c1-150)"; else echo "assessment offered: no"; fi
  [[ ( -n $moves && -n $docs ) || -n $assessment ]]
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "a notice listing moves or renames, or the offer of an assessment" assert_moves_or_assessment "$stream"
  check "nothing moved or changed in the working tree" assert_files_unchanged "$project"
  check "nothing moved or changed on any branch (tree hashes as before)" assert_branch_trees_unchanged "$project"
  check "no commit added" assert_no_commit_added "$project"
}
