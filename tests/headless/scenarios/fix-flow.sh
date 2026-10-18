# Fix flow (SPEC-0026): an approved bug fix gets a fix spec with a blameless postmortem, a row in
# the register spec/POSTMORTEMS.md, and a regression test. The bug is the empty-cart one of the
# SPEC-0026 T-3 run: total() divides by len(prices).

SCENARIO_DESCRIPTION="an approved bug fix leaves a fix spec with a postmortem, a register row and a regression test"
SCENARIO_PROMPT="Bug: total() in shop/cart.py raises ZeroDivisionError for an empty cart. I approve the fix: use the senior-mindset fix flow, write the fix spec, fix it, and do everything the skill requires after a fix. Do not ask questions."
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*),Bash(python:*),Bash(python3:*)"
SCENARIO_QUESTION_TOOL=error

scenario_setup() {  # a managed project: conventions, the spec/ layout, a small package with two tests
  local dir=$1
  init_scratch_repo "$dir"
  mkdir -p "$dir/shop" "$dir/tests" "$dir/spec/constitution" "$dir/spec/adr" "$dir/spec/features" "$dir/spec/fixes"
  cat > "$dir/CLAUDE.md" <<DOC
# Shop

A small shopping-cart library.

## Engineering conventions

- Language: Python 3. Tests: unittest (run: \`python -m unittest discover -s tests -t .\`).
- Code folder: \`shop/\`. Linter and formatter: none yet.
- Decisions: [spec/adr/README.md](spec/adr/README.md). Inventory: [spec/INVENTORY.md](spec/INVENTORY.md).

$(git_rules_block)

Features: spec/features/ · Fixes: spec/fixes/
DOC
  printf '# Mission\n\nA small cart library for one shop.\n\nStatus: Approved\n' > "$dir/spec/constitution/mission.md"
  printf '# Tech stack\n\n- Language: Python 3\n- Tests: unittest\n' > "$dir/spec/constitution/tech-stack.md"
  printf '# Roadmap\n\n| Spec | Feature | Status |\n|---|---|---|\n' > "$dir/spec/constitution/roadmap.md"
  printf '# Architecture decision records\n\n| ADR | Title | Status |\n|---|---|---|\n' > "$dir/spec/adr/README.md"
  printf '# Inventory\n\n- `shop/cart.py` - cart arithmetic: `total(prices)`\n' > "$dir/spec/INVENTORY.md"
  : > "$dir/shop/__init__.py"
  : > "$dir/tests/__init__.py"
  cat > "$dir/shop/cart.py" <<'DOC'
def total(prices):
    """Return the average price of the items in the cart."""
    return sum(prices) / len(prices)
DOC
  cat > "$dir/tests/test_cart.py" <<'DOC'
import unittest

from shop.cart import total


class TotalTest(unittest.TestCase):
    def test_two_items(self):
        self.assertEqual(total([2, 4]), 3)

    def test_other_two_items(self):
        self.assertEqual(total([10, 20]), 15)


if __name__ == "__main__":
    unittest.main()
DOC
  printf '__pycache__/\n*.pyc\n' > "$dir/.gitignore"
  commit_scratch "$dir" "Add the cart"
  git -C "$dir" rev-parse master > "$dir/.git/baseline-master"
}

FIX_SPEC_PATH='^spec/fixes/[0-9]{4}-.*\.md$'

assert_fix_spec_with_postmortem() {  # assert_fix_spec_with_postmortem PROJECT
  local hit ref file part status=0
  hit="$(find_file "$1" "$FIX_SPEC_PATH" '^## Postmortem')" || { echo "no spec/fixes/NNNN-*.md with a '## Postmortem' section"; return 1; }
  ref="${hit%% *}" file="${hit#* }"
  echo "$file on $ref"
  for part in 'Impact' '5 Whys' 'not caught' 'Corrective action' 'Preventive action'; do
    if file_at "$1" "$ref" "$file" | grep -Eiq -- "$part"; then :; else echo "postmortem part missing: $part"; status=1; fi
  done
  return $status
}

assert_register_one_row() {  # assert_register_one_row PROJECT
  local hit ref file rows
  hit="$(find_file "$1" '^spec/POSTMORTEMS\.md$')" || { echo "spec/POSTMORTEMS.md is missing"; return 1; }
  ref="${hit%% *}" file="${hit#* }"
  rows="$(file_at "$1" "$ref" "$file" | grep -E '^\|[[:space:]]*PM-[0-9]+[[:space:]]*\|')"
  echo "$file on $ref: $(printf '%s\n' "$rows" | grep -c .) row(s)"
  printf '%s\n' "$rows" | cut -c1-160
  [[ $(printf '%s\n' "$rows" | grep -c .) -eq 1 ]]
}

# The branch holding the fix spec is the fix: its tree gets the project's tests and a probe.
fix_ref() {  # fix_ref PROJECT -> ref of the fix
  find_file "$1" "$FIX_SPEC_PATH" | cut -d' ' -f1
}

assert_regression_test() {  # assert_regression_test PROJECT: a new test calls total() with no items
  local ref hits
  ref="$(fix_ref "$1")"; [[ -n $ref ]] || { echo "no fix found"; return 1; }
  hits="$(files_at "$1" "$ref" | grep -E '^tests/.*\.py$' | while IFS= read -r file; do
    file_at "$1" "$ref" "$file" | grep -En 'total\(\s*(\[\s*\]|\(\s*\)|list\(\s*\)|empty\w*|\w*_empty\w*)\s*\)|def test\w*empty' | sed "s|^|$file:|"
  done)"
  if [[ -n $hits ]]; then printf '%s\n' "$hits" | head -4; return 0; fi
  echo "no test under tests/ calls total() with an empty cart"
  return 1
}

assert_suite_passes() {  # assert_suite_passes PROJECT: unittest, with more tests than the two at the start
  local ref dir out tests
  ref="$(fix_ref "$1")"; [[ -n $ref ]] || { echo "no fix found"; return 1; }
  dir="$(new_temp_dir headless-fixflow-export)"
  export_ref "$1" "$ref" "$dir"
  out="$(cd "$dir" && PYTHONDONTWRITEBYTECODE=1 "$PYTHON" -m unittest discover -s tests -t . 2>&1)"
  local code=$?
  rm -rf "$dir"
  printf '%s\n' "$out" | tail -4
  tests="$(printf '%s\n' "$out" | sed -n 's/^Ran \([0-9]*\) test.*/\1/p')"
  [[ $code -eq 0 && ${tests:-0} -ge 3 ]]
}

assert_empty_cart_does_not_raise() {  # assert_empty_cart_does_not_raise PROJECT
  local ref dir out
  ref="$(fix_ref "$1")"; [[ -n $ref ]] || { echo "no fix found"; return 1; }
  dir="$(new_temp_dir headless-fixflow-probe)"
  export_ref "$1" "$ref" "$dir"
  out="$(cd "$dir" && PYTHONDONTWRITEBYTECODE=1 "$PYTHON" -c 'from shop.cart import total; print("total([]) =", total([]))' 2>&1)"
  local code=$?
  rm -rf "$dir"
  printf '%s\n' "$out" | tail -3
  return $code
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "fix spec in spec/fixes/ with a Postmortem and its parts" assert_fix_spec_with_postmortem "$project"
  check "spec/POSTMORTEMS.md with exactly one row" assert_register_one_row "$project"
  check "a regression test calls total() with an empty cart" assert_regression_test "$project"
  check "the test suite passes (unittest, more than the original two tests)" assert_suite_passes "$project"
  check "total([]) no longer raises" assert_empty_cart_does_not_raise "$project"
  check "master did not move (the fix is on a branch)" assert_master_untouched "$project"
}
