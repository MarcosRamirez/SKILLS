# Roadmap

Order of the features: the next one to run is the first row that is not Implemented and whose
dependencies are. "Run plan NNNN" executes a feature. The bot sets Implemented on merge; keep the
table format.

| Spec | Title | Tier | Status | Depends on |
|---|---|---|---|---|
| SPEC-0001 | senior-mindset 1.2.0: app versioning, branch per change, test findings | — | Implemented | — |
| SPEC-0002 | senior-mindset 1.3.0: collision check, PR flow, dated changelog | — | Implemented | — |
| SPEC-0003 | Approval gate that holds in headless runs | — | Implemented | — |
| SPEC-0004 | Defensive programming by default | — | Implemented | — |
| SPEC-0005 | Specs close on merge, releases tag themselves | — | Implemented | — |
| SPEC-0006 | Welcome message on install and update | — | Implemented | — |
| SPEC-0007 | A plan per spec with the recommended agent and model | medium | Implemented | — |
| SPEC-0017 | SDD layout under spec/ with a constitution | high | Implemented | — |
| SPEC-0018 | Ask where the code goes | low | Implemented | SPEC-0017 |
| SPEC-0022 | Spec types: features and fixes | medium | Implemented | — |
| SPEC-0023 | Versions go up only when something is implemented | low | Implemented | SPEC-0022 |
| SPEC-0016 | Closed questions with clickable answers | low | Implemented | — |
| SPEC-0026 | Postmortem for every bug and a register of lessons | medium | Implemented | SPEC-0022 |
| SPEC-0024 | Docs follow the current ADRs | medium | Implemented | SPEC-0026 |
| SPEC-0025 | Propagate every decision to what it touches | medium | Implemented | SPEC-0024 |
| SPEC-0027 | Git requests skip senior-mindset's rules | medium | Implemented | SPEC-0016 |
| SPEC-0019 | AGENTS.md as the single source of project instructions | medium | Implemented | SPEC-0016, SPEC-0025 |
| SPEC-0028 | Committed headless suite, run before every release | high | Implemented | SPEC-0027 |
| SPEC-0029 | Committed tests for the release scripts, run in CI | medium | Implemented | SPEC-0024 |
| SPEC-0030 | Update the docs when what a file does changes | low | Implemented | SPEC-0025 |
| SPEC-0008 | Work safely on existing projects | high | Implemented | SPEC-0019 |
| SPEC-0014 | Documented commands, help and status | medium | Implemented | SPEC-0022 |
| SPEC-0021 | Install in the project, standard locations first | high | Implemented | SPEC-0008, SPEC-0014, SPEC-0023 |
| SPEC-0009 | Analyse existing projects and normalise them | high | Implemented | SPEC-0021 |
| SPEC-0011 | Curated catalog of skills and MCPs, skill management | high | Implemented | SPEC-0021 |
| SPEC-0012 | MCP management from the curated catalog | medium | Approved | SPEC-0011 |
| SPEC-0020 | Enable and disable MCPs as the work needs them | medium | Draft | SPEC-0012, SPEC-0014 |
| SPEC-0010 | Environments: local, preview, staging, production | medium | Draft | — |
| SPEC-0013 | Portable to other agents and open models | high | Draft | SPEC-0016, SPEC-0021 |
| SPEC-0015 | Optional sync of specs and tasks to GitHub issues | high | Draft | SPEC-0022, SPEC-0014 |
| SPEC-0031 | Rules that must always hold live where they are not always read | high | Draft | SPEC-0028 |
| SPEC-0032 | write-skill: create skills within the standard's budgets | low | Approved | — |
