# SPEC-0009 design

## Code analysis pipeline (facts first, interpretation second)

1. **Map:** tree without `node_modules`, `dist`, `.venv`…; languages, size, monorepo or not.
2. **Manifests and config:** `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod` → stack,
   dependencies, scripts. Linter/formatter/test/CI/Docker/platform configs → tooling.
3. **Inventory facts**, found with grep, ast-grep or the language's LSP:
   - exported modules and functions;
   - endpoints and framework routes;
   - tables and models (migrations, ORM schema);
   - queues and events;
   - scripts and CLIs;
   - external integrations;
   - environment variables used (names only, never values).
4. **Conventions found:** naming, folder structure, error handling, logging, from code samples
   and linter config → CLAUDE.md, even when they differ from skill defaults.
5. **Retroactive ADRs** (`Accepted`, context "found in code"), each with its evidence file.
6. **Health:** tests (count, passing), CI status, outdated or vulnerable dependencies,
   **committed secrets** (alert), TODO/FIXME, obvious dead code.

- Large repos: split by package or folder (one subagent each), then merge.
- Verification: drop or mark "to confirm" any entry whose path or symbol cannot be found.

## Documentation mapping

Existing files are mapped to the standard layout in a table inside the adoption spec
(source → target → action: move / split / merge / archive). Moves use `git mv`.
