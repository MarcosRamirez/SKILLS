# SPEC-0025 tasks

One branch per task. Executed through PLAN-0025.

- [x] T-1 `## Impact` section and sweep in `references/adr.md`, rule in `SKILL.md`, sweep rule in this repo's `CLAUDE.md` (AC-1, AC-2, AC-5)
- [x] T-2 `docs-check` automation template and catalog entry (AC-4)
- [x] T-3 Headless sweep test (AC-3)
- [x] T-4 Minor release with `Closes-Spec: SPEC-0025`

## Test results (T-3, 2026-10-14)

Scratch project: a git repo (`master`) for "Tasklog", a one-user Flask app already managed by the
skill. It has a `CLAUDE.md` whose `## Engineering conventions` say the database is PostgreSQL and
link ADR-0001. It also has `spec/adr/0001-use-postgresql.md` (Accepted) and the ADR index. The
README's "Run locally" section needs PostgreSQL (`docker run ... postgres:16`,
`export DATABASE_URL=postgres://...`). `tech-stack.md` has the database row linking ADR-0001, and
there is an `INVENTORY.md`. SPEC-0002 is a Draft spec ("R-2 Store sessions in PostgreSQL ...
JSONB"), SPEC-0001 an Implemented one ("R-1 Store tasks in a `tasks` table in PostgreSQL"), and
`tasklog/db.py` holds a `postgres://` default URL. Run once with the working copy of the skill
(2.4.1), Claude Code 2.1.296, model `claude-opus-5-5`. No wording fix was needed:

```text
claude -p "We decided to move from PostgreSQL to SQLite for this project: it is single-user
  and local-first. I approve the decision. Record it as an ADR following the senior-mindset
  rules and do everything those rules require in the same change. Do not change application
  code yet." --plugin-dir D:/Code/Projects/SKILLS/skills/senior-mindset --output-format
  stream-json --verbose --permission-mode acceptEdits --allowedTools "Bash"
```

The skill loaded (`senior-mindset:senior-mindset`, path of the working copy). The run exited 0
after 33 turns and asked nothing. It read `references/adr.md` and searched as step 1 of the sweep
says: `git grep -n -i -E "ADR-0001|0001-use-postgresql|postgres|psycopg|DATABASE_URL|JSONB|docker|database"`.
Everything landed in one commit on `docs/adr-0002-use-sqlite`. `master` is unchanged and was not
merged: there is no remote, so the agent asked before merging.

```text
 CLAUDE.md                                    |  2 +-
 README.md                                    |  3 +-
 spec/INVENTORY.md                            |  4 +-
 spec/adr/0001-use-postgresql.md              |  2 +-
 spec/adr/0002-use-sqlite.md                  | 56 +++++++++++++++++++++
 spec/adr/README.md                           |  3 +-
 spec/constitution/roadmap.md                 |  1 +
 spec/constitution/tech-stack.md              |  2 +-
 spec/features/0002-sessions.md               |  8 ++-
 spec/features/0003-move-storage-to-sqlite.md | 75 ++++++++++++++++++++++++++++
 10 files changed, 148 insertions(+), 8 deletions(-)
```

| Check | Result | Evidence |
|---|---|---|
| ADR-0002 with Options, Decision, Consequences and `## Impact` | pass | Three options (keep PostgreSQL, SQLite, JSON files). `Replaces terms: PostgreSQL → SQLite, psycopg → sqlite3, DATABASE_URL → a database file path (named in SPEC-0003), JSONB → JSON stored as TEXT`. A Document/Action table with 11 rows, one per hit of the search, plus `mission.md`: "no change: already says one person, own machine, no cloud". `Existing projects/data:` points to the one-off migration in SPEC-0003 |
| ADR-0001: status line only | pass | Its diff is one line: `Status: Accepted` → `Status: Superseded by ADR-0002` |
| README "Run locally", conventions, ADR index and tech-stack in the same change | pass | All in the one commit. README: "Tasklog needs a PostgreSQL 16 server for now. It is changing to SQLite, with no server to run, in SPEC-0003 (why SQLite)", with the link moved from ADR-0001 to ADR-0002. CLAUDE.md, `tech-stack.md` and `INVENTORY.md` say "changing to SQLite in SPEC-0003" and link ADR-0002. The index lists 0001 as `Superseded by ADR-0002` and 0002 as `Accepted`. The `docker run` and `DATABASE_URL` commands stay because the code still uses PostgreSQL (sweep step 4: never claimed early) |
| Draft spec updated, Implemented spec untouched | pass | SPEC-0002 R-2 now reads "Store sessions in SQLite ... (id, data as JSON text, expires_at)", with `## Changelog`: "2026-10-14: R-2 stores sessions in SQLite instead of PostgreSQL, with JSON as text instead of JSONB (ADR-0002). Now depends on SPEC-0003." `git diff` on SPEC-0001 is empty |
| Implementation work as a Draft follow-up, code unchanged | pass | New SPEC-0003 "Move storage to SQLite" (Draft, `Approved by:` empty): R-1 to R-4, AC-1 to AC-5, plan, tasks, and a roadmap row. Impact row: "`tasklog/db.py`, `requirements.txt`, tests, README setup commands: follow-up: SPEC-0003 (Draft)". `git diff` on `tasklog/` and `requirements.txt` is empty |
| docs-check template (optional) | pass | `templates/docs-check/check-docs.py` copied into a clone of the branch: exit 0. It was also exit 0 on the starting project |

AC-3: met.

- `postgres://` is not listed in `Replaces terms` word for word. `DATABASE_URL → a database file
  path` covers it, and the case-insensitive `postgres` in the search found the URL in the README
  and in `db.py`.
- Finding, not fixed here: when `spec/adr/README.md` or ADR-0002 is passed to `check-docs.py`
  (as an argument or through `DOCS_CHECK_FILES`), it flags their links to ADR-0001: the index row
  and the new ADR's `Supersedes:` line. Those links are correct. The default file set leaves
  `spec/adr/` out, so the default run is clean. The agent reported the same thing.
- The agent also noticed that the README runs `tasklog.app`, which the scratch project does not
  have. That is a gap in the test fixture, not in the skill.

Limits: one run, one model (Opus, the high tier), one scenario. The prompt named the rules ("do
everything those rules require"), so the run shows that the procedure can be followed, not that
it fires on a terse request. In headless mode, `Grep` on the skill's own `references/` folder was
denied as outside the project. `Read` worked, and the run finished.

File protection (PM-0012): `~/.claude/senior-mindset.md` was copied to the scratch folder before
the run. The skill's update notice (2.2.1 to 2.4.1) tried to write the new version into it, and
headless `acceptEdits` denied the `Edit` because the file is outside the project. The denial is in
the result's `permission_denials`. The file's SHA-256 was `e2245cbe...905941` before and after the
run. The backup was restored over it anyway and `cmp` reported the two identical. Nothing else
under `~/.claude/` was touched on purpose. The raw output (`0025-t3-run1.jsonl`) stays in the
scratch folder.
