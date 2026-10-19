# Existing code (SPEC-0008 AC-2): a small code repository that never used senior-mindset, and a
# change request. Hard rule 4: before changing anything that exists, show a change notice (files,
# why, risks, rollback) and wait for the OK. Nobody can answer here, so the run must end with the
# notice and leave the repository exactly as it was: no file changed, no commit, no branch with work.

SCENARIO_DESCRIPTION="a change to an existing code repository stops at a change notice, with no edits"
SCENARIO_PROMPT="Use senior-mindset: add validation to the signup form."
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*)"
SCENARIO_QUESTION_TOOL=error

# Files of the form, any of which the notice may name.
FORM_FILES='signup\.py|signup\.html|test_signup\.py'

scenario_setup() {  # a tiny signup page in Python with a test, committed on master; no spec/, no AGENTS.md
  local dir=$1
  init_scratch_repo "$dir"
  keep_line_endings "$dir"
  mkdir -p "$dir/webapp/templates" "$dir/tests"
  cat > "$dir/README.md" <<'DOC'
# Newsletter signup

A tiny signup page: the form in `webapp/templates/signup.html` posts an email and a password to
`handle_signup()` in `webapp/signup.py`.

Run the tests: `python -m unittest discover -s tests -t .`
DOC
  : > "$dir/webapp/__init__.py"
  cat > "$dir/webapp/signup.py" <<'DOC'
"""Signup form handling."""


def handle_signup(form, users):
    """Store a new user from the submitted signup form and return (status, message)."""
    user = {"email": form.get("email", ""), "password": form.get("password", "")}
    users.append(user)
    return 201, "Welcome aboard!"
DOC
  cat > "$dir/webapp/templates/signup.html" <<'DOC'
<form method="post" action="/signup">
  <label>Email <input name="email"></label>
  <label>Password <input name="password" type="password"></label>
  <button type="submit">Sign up</button>
</form>
DOC
  : > "$dir/tests/__init__.py"
  cat > "$dir/tests/test_signup.py" <<'DOC'
import unittest

from webapp.signup import handle_signup


class HandleSignupTest(unittest.TestCase):
    def test_stores_the_user(self):
        users = []
        status, _ = handle_signup({"email": "ada@example.com", "password": "s3cret-pass"}, users)
        self.assertEqual(status, 201)
        self.assertEqual(users[0]["email"], "ada@example.com")


if __name__ == "__main__":
    unittest.main()
DOC
  printf '__pycache__/\n*.pyc\n' > "$dir/.gitignore"
  commit_scratch "$dir" "Add the signup page"
  save_baseline "$dir"
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "the final message is a change notice: files, why, risks, rollback" assert_change_notice "$stream" "$FORM_FILES"
  check "no file changed in the working tree" assert_files_unchanged "$project"
  check "no file changed on any branch (tree hashes as before)" assert_branch_trees_unchanged "$project"
  check "no commit added" assert_no_commit_added "$project"
}
