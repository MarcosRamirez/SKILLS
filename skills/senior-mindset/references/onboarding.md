# Onboarding an existing project

A project that already has code or documentation, but no `## Engineering conventions`, is analysed
before the kickoff. The analysis records what exists, built from the files and never from
assumptions, and proposes adopting senior-mindset's layout as a spec of its own. Hard rule 4 applies
throughout: until the user approves, nothing that exists is changed.

## When it runs

- Step 1 finds no `## Engineering conventions` (in AGENTS.md or CLAUDE.md) and the folder is not
  empty. The analysis runs before the kickoff interview.
- The user asks for it ("analyse this project", "adopt senior-mindset", "analiza el proyecto").
- Not for an empty folder (normal kickoff), and not for senior-mindset's own 1.x layout
  (`docs/specs/`…): that one follows the migration in [project-layout.md](project-layout.md).
- Not a git repository → propose `git init` and a snapshot commit first
  ([existing-projects.md](existing-projects.md)).

## 1. Detect the state

```bash
git ls-files | sed -n 's/.*\.\([A-Za-z0-9]*\)$/\1/p' | sort | uniq -c | sort -rn | head -15
git ls-files | cut -d/ -f1 | sort | uniq -c | sort -rn | head -20
```

| State | Signals | What runs |
|---|---|---|
| Empty | only `.git`, a stub README or a licence | normal kickoff, no onboarding |
| Docs only | Markdown, text or wiki files; no manifest and no source files | section 4 (docs mapping) |
| Code | a manifest (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`…) or source files; no specs or ADRs | section 3 (code pipeline) |
| Code + docs | both | section 3, then section 4 |

## 2. Ground rules

- **Facts first, interpretation second.** Every claim in the assessment, the inventory and the
  ADRs cites its evidence (`path` or `path:line`). What cannot be cited goes to "To confirm".
- **Read-only until the OK.** Read, list and grep. Do not install dependencies, run build or
  migration scripts, or start services. Running the test suite executes project code: ask first,
  and otherwise count the tests by grep.
- **Cheap reads.** Manifests, configs, `head` of files and grep results, not whole files. In a
  large repository or a monorepo, split the analysis by package or top-level folder (one subagent
  each, when available) and merge the results.
- **Committed secrets** (keys, tokens, private keys, passwords, tracked `.env` files): say so at
  the top of your answer, at once, with the file, the line and the kind of secret, **never the
  value**. They are never copied into any document; the assessment names the location only.
  Removing and rotating them is the user's call, proposed as its own fix spec. Use `gitleaks`
  or `trufflehog` if installed; otherwise grep:

  ```bash
  git ls-files | grep -E '(^|/)\.env($|\.)' | grep -v -E '\.example$|\.sample$'
  git grep -n -I -E 'AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{36}|xox[baprs]-[A-Za-z0-9-]{10,}|sk-[A-Za-z0-9_-]{20,}|(password|passwd|secret|api_?key|token)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"'$<{]{8,}' | cut -d: -f1,2
  ```

  The `cut` keeps the file and the line only, so the value never reaches your context or a log.
- **The project's conventions win.** What the code does is recorded as it is, even where it
  differs from the skill's defaults. A deviation is noted, never imposed.
- **Health problems are not fixed here.** Each one becomes a Draft spec, or a line in the
  assessment.

## 3. Code: the analysis pipeline

Six stages, in order. Each feeds a part of the result.

1. **Map** → assessment "Structure". `git ls-files` (it already skips what `.gitignore` skips;
   outside git, exclude `node_modules`, `dist`, `build`, `.venv`, `vendor`, `target`). Languages and
   sizes, top-level folders, where the code lives (`src/`, `app/`, `apps/*`…), and monorepo signals:
   `workspaces` in `package.json`, `pnpm-workspace.yaml`, `go.work`, a Cargo `[workspace]`, several
   manifests.
2. **Manifests and configuration** → assessment "Stack", conventions. Language and runtime
   versions, framework, dependencies, scripts (`package.json` scripts, `Makefile` targets,
   `[project.scripts]`). Tooling from config files: linter and formatter (`eslint.config.*`, `biome.json`,
   `.prettierrc*`, `ruff.toml` or `[tool.ruff]`, `.editorconfig`), tests (`vitest`, `jest`, `pytest`
   config), CI (`.github/workflows/`, `.gitlab-ci.yml`), containers (`Dockerfile`, `compose.yaml`),
   platform (`wrangler.toml`, `vercel.json`, `netlify.toml`, `fly.toml`).
3. **Inventory facts** → `spec/INVENTORY.md`. With ast-grep or the language server when available,
   grep otherwise:

   | Kind | Where to look (examples) |
   |---|---|
   | Modules and exported functions | `^export (async )?(function\|const\|class)`, `module.exports`, public `def`/`class` outside tests |
   | Endpoints and routes | `app.(get\|post\|put\|delete)(`, `router.`, `@app.route`, `@(Get\|Post)Mapping`, `app/**/route.ts`, `pages/api/` |
   | Tables and models | `migrations/`, `CREATE TABLE`, `schema.prisma` `model`, `pgTable(`, `models.Model`, `@Entity` |
   | Queues and events | `queue`, `publish(`, `emit(`, `consumer`, Cloudflare `[[queues]]` |
   | Scripts and CLIs | `scripts/`, `bin/`, manifest scripts, `if __name__ == "__main__"` |
   | External integrations | SDK imports (`stripe`, `@aws-sdk/*`, `openai`, `@anthropic-ai/sdk`…), base URLs |
   | Environment variables | `process.env.X`, `import.meta.env.X`, `os.environ`, `os.getenv`, `env::var`: **names only, never values** |

   One line per item, in the inventory format (`name — path — purpose — usage`), where `name` is
   the identifier exactly as the code writes it, so the verification can grep it.
4. **Conventions found** → `## Engineering conventions`. Naming (from a sample of files), folder
   structure, error handling, logging library, test layout. Style rules come from the linter and
   formatter config, and each one cites its config line. Where the code has no rule, say "not
   enforced" instead of guessing.
5. **Retroactive ADRs** → `spec/adr/`. One per decision that reaches the whole project and is
   visible in the code (language, framework, database, platform, architecture, test runner),
   using the template in [adr.md](adr.md) with `Status: Accepted`, a Context that starts "Found in
   the code on <date>: decided before senior-mindset", and an **Evidence** list of files. Never
   invent the reasons: what the code does not show goes to "To confirm" in the ADR.
6. **Health** → assessment "Health". Tests (how many, and whether CI runs them), CI status (last
   run with `gh run list --limit 5` when available), dependencies (`npm outdated`, `npm audit`,
   `pip list --outdated`, `cargo outdated`, whichever exists; they only read), committed secrets
   (rules above), `TODO`/`FIXME` count (`git grep -c -E 'TODO|FIXME'`), and dead code only when it is
   obvious (a file nothing imports), marked "to confirm".

### The verification gate

Every inventory line is checked before it is written: the path exists and the name is found in it.
A line that fails is dropped, or kept with "(to confirm)" and listed in the assessment.

```bash
grep -E '^- `' spec/INVENTORY.md | while IFS= read -r line; do
  name=$(printf '%s\n' "$line" | sed -E 's/^- `([^`]+)`.*/\1/')
  path=$(printf '%s\n' "$line" | awk -F' — ' '{ print $2 }')
  if [ ! -e "$path" ]; then echo "MISSING PATH  $path ($name)"; continue; fi
  git grep -q -w -F -- "$name" -- "$path" || echo "NO SYMBOL     $name in $path"
done
```

Endpoints are checked by their route string, tables by their name in the migration or schema. The
gate passes when it prints nothing.

## 4. Documentation: map it onto the standard layout

Recognise the pattern before mapping:

| Pattern | Signals | Maps to |
|---|---|---|
| spec-kit | `.specify/`, `specs/NNN-name/{spec,plan,tasks}.md`, `memory/constitution.md` | `spec/features/NNNN-slug/{spec.md, plan.<tier>.md, tasks.md}`; constitution → `spec/constitution/` |
| Kiro | `.kiro/specs/<name>/{requirements,design,tasks}.md`, `.kiro/steering/` | requirements → `spec.md`, design → the plan's `## Design`, tasks → `tasks.md`; steering → conventions or constitution |
| ADR folders (MADR, Nygard) | `docs/adr/`, `doc/adr/`, `docs/decisions/`, `NNNN-title.md` | `spec/adr/`, numbers kept, a `Status:` line added if missing |
| Bug notes, incident reports | `bugs/`, `incidents/`, postmortems | `spec/fixes/` (and rows in `spec/POSTMORTEMS.md` when they hold a root cause) |
| Loose documents | PRDs, RFCs, `notes/`, `docs/*.md`, long README sections | per document: mission, feature spec, ADR, or archive |
| Wikis and vaults | `wiki/`, `.obsidian/`, Notion or Confluence exports | per page, as loose documents; links rewritten |
| Agent instructions | `CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md` | merged into AGENTS.md per [agents-md.md](agents-md.md) |

The mapping is a table in the adoption spec, one row per existing file:

| Source | Target | Action | Notes |
|---|---|---|---|
| `docs/prd.md` | `spec/constitution/mission.md`, `spec/features/0002-export/spec.md` | split | original archived |
| `docs/decisions/0001-db.md` | `spec/adr/0001-db.md` | move | `Status:` added |
| `notes/ideas.md` | `spec/archive/notes/ideas.md` | archive | no target fits |

- **Actions:** move, split, merge, archive, keep. Moves use `git mv`, so history follows the file.
- **Nothing is deleted.** A split or merged original goes to `spec/archive/` (same relative path),
  and what fits nowhere goes there too, listed in `spec/archive/README.md` with its old path.
- **States are never invented.** A mapped spec is `Implemented` only when the code exists (cite
  it), otherwise `Draft`. Numbers follow the documents' dates when known.
- Relative links are rewritten in the same commit as the move.
- **No-deletion check** on the migration branch, before the PR: it prints nothing.

  ```bash
  git diff -M --diff-filter=D --name-only "$(git merge-base HEAD <default-branch>)" HEAD
  ```

## 5. `spec/ASSESSMENT.md`

```markdown
# Assessment: <project>

Date: <date> · Commit analysed: <sha> · senior-mindset <version>

## Summary
<five lines at most: what the project is, its state, the biggest gaps and risks>

## State
Docs only | Code | Code + docs. Pattern found: <spec-kit / loose documents / none…>

## What exists
### Stack
| Area | Found | Evidence |
|---|---|---|
### Structure
### Documentation

## Gaps against the standard
| Area | Standard | Here | Proposal |
|---|---|---|---|

## Health
- Tests: · CI: · Dependencies: · Secrets: <locations only, or "none found"> · TODO/FIXME: · Dead code (to confirm):

## Risks

## To confirm
<every claim the analysis could not verify>

## Next step
SPEC-NNNN "Adopt senior-mindset" (Draft)
```

## 6. The flow

1. **Analyse**, read-only (sections 1 to 4). Committed secrets go first in the answer.
2. **Change notice for the documents:** `+ spec/ASSESSMENT.md` and
   `+ spec/features/NNNN-adopt-senior-mindset/{spec.md, plan.<tier>.md, tasks.md}` (Draft), on
   the branch `docs/NNNN-adopt-senior-mindset`. They only add files. With the OK, write and commit
   them, and summarise the assessment in your answer. In a headless run, show the summary and the
   notice, and stop.
3. **The adoption spec** ("Adopt senior-mindset", the next free SPEC number, `0001` if none):
   conventions found (stage 4), the verified inventory (stage 3), the retroactive ADRs (stage 5),
   the docs mapping table (section 4), the constitution (the mission is asked and approved, as in
   the kickoff), the "Git rules that always hold" block, and the automations offer. Health
   problems are listed as follow-up Draft specs, not fixed.
4. **The user approves the spec** (closed question). Then it runs as a plan: one branch per task,
   stacked PRs, a change notice per task. The migration PR passes the no-deletion check, and its
   body carries the mapping table.
5. **Kickoff after adoption** asks only what the analysis could not answer. What the code already
   decided is recorded, with its evidence, and not asked again.
