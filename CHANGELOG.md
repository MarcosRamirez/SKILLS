# Changelog

All notable changes to this project are documented here, newest first.
Generated from the commit history with git-cliff: do not edit by hand.

## [Unreleased]

### Added

- **senior-mindset:** Update the installed skill by pull request (2026-10-19)
- **senior-mindset:** Detect global, project and duplicate installs (2026-10-19)

### Fixed

- **senior-mindset:** Say nothing when only the project copy loads (2026-10-19)

### Changed

- **marketplace:** Keep each skill's version only in SKILL.md (2026-10-19)

### Documentation

- **repo:** Record PM-0014 and PM-0015 in the register (2026-10-19)
- **repo:** Tick the SPEC-0021 release task (2026-10-19)
- **repo:** Record the SPEC-0021 T-5 checks (2026-10-19)
- **repo:** Record the SPEC-0021 T-4 update check (2026-10-19)
- **repo:** Record the SPEC-0021 T-2 install checks (2026-10-19)
- **senior-mindset:** Install from the latest release tag (2026-10-19)
- **repo:** Approve SPEC-0021 and start its plan (2026-10-19)
- **repo:** Mark SPEC-0008,SPEC-0014 implemented (#89) (2026-10-19)

## [senior-mindset-v2.8.0] - 2026-10-19

### Added

- **senior-mindset:** Add a what-I-can-do summary to the welcome
- **senior-mindset:** Make help, status and list plans read-only
- **senior-mindset:** Document the commands in one reference
- **senior-mindset:** Add the existing-projects reference
- **senior-mindset:** Ask before changing an existing project

### Fixed

- **senior-mindset:** Rule out working around uncommitted changes
- **senior-mindset:** Ask about uncommitted changes in hard rule 4

### Documentation

- **senior-mindset:** Tick the release tasks of specs 0008 and 0014
- **repo:** Record T-1 to T-3 of SPEC-0014 and the alias decision
- **repo:** Approve SPEC-0014 and start its plan
- **repo:** Tick T-3 of SPEC-0008 with its run results
- **repo:** Document the SPEC-0008 scenarios in the suite
- **repo:** Approve SPEC-0008 and start its plan
- **repo:** Mark SPEC-0029,SPEC-0030 implemented (#84)

## [senior-mindset-v2.7.0] - 2026-10-19

### Added

- **senior-mindset:** Update the docs when what a file does changes

### Documentation

- **repo:** Mark the suite and CI preventive actions done
- **senior-mindset:** Tick the release tasks of specs 0029 and 0030
- **repo:** Tick T-2 of SPEC-0029 with its results
- **senior-mindset:** Try the platform before relying on it
- **repo:** Document the scripts job and the suite-with-script rule
- **repo:** Document tests/ci and tick T-1
- **repo:** Start PLAN-0029 (T-1 in progress)
- **repo:** Mark SPEC-0028 implemented (#79)
- **repo:** Run the headless suite before every release
- **repo:** Tick T-2 of SPEC-0028 with its run results
- **repo:** Document the T-2 scenarios in the suite README
- **repo:** Document the headless suite and tick T-1
- **repo:** Start plan 0028 with task T-1
- **repo:** Mark SPEC-0019 implemented (#75)

## [senior-mindset-v2.6.0] - 2026-10-18

### Added

- **senior-mindset:** Add the CLAUDE.md and AGENTS.md merge procedure
- **senior-mindset:** Make AGENTS.md the conventions file

### Fixed

- **senior-mindset:** Read agents-md.md before proposing a change
- **senior-mindset:** Put the instruction-file check first in Step 1
- **senior-mindset:** Check the instruction files every session

### Changed

- **repo:** Rename CLAUDE.md to AGENTS.md

### Documentation

- **senior-mindset:** Tick task T-4 of spec 0019
- **repo:** Tick SPEC-0019 T-3 with migration results
- **repo:** Point conventions references to AGENTS.md
- **repo:** Add CLAUDE.md import of AGENTS.md
- **repo:** Sweep Draft specs and tick T-1 of SPEC-0019
- **repo:** Approve SPEC-0019 and start its plan
- **repo:** Mark SPEC-0027 implemented (#70)

## [senior-mindset-v2.5.1] - 2026-10-18

### Fixed

- **senior-mindset:** Load for git-only requests, keep git rules

### Documentation

- **senior-mindset:** Tick task T-4 of fix 0027
- **repo:** Write the postmortem of fix 0027
- **senior-mindset:** Record the reproduction of fix 0027
- **senior-mindset:** Add specs 0027-0030 against the bug patterns
- **repo:** Mark SPEC-0025 implemented (#65)

## [senior-mindset-v2.5.0] - 2026-10-14

### Added

- **senior-mindset:** Allow superseded-ADR links inside adr folders
- **senior-mindset:** Add docs-check automation template
- **senior-mindset:** Add ADR impact section and sweep

### Documentation

- **repo:** Mark the impact sweep done for PM-0013
- **senior-mindset:** Tick task T-4 of spec 0025
- **repo:** Add impact sweep rule to CLAUDE.md
- **repo:** Start plan 0025 and tick task T-1
- **repo:** Mark SPEC-0024 implemented (#60)

## [senior-mindset-v2.4.1] - 2026-10-14

### Fixed

- **repo:** Check docs for broken and superseded links on PRs

### Documentation

- **senior-mindset:** Tick task T-4 of fix 0024
- **repo:** Write the postmortem of fix 0024
- **repo:** Align Draft specs 0009, 0012, 0015 with ADRs
- **repo:** State the standard-first identity and ADRs
- **senior-mindset:** Install with npx skills first
- **senior-mindset:** Record the npx skills checks for fix 0024
- **repo:** Mark SPEC-0026 implemented (#56)

## [senior-mindset-v2.4.0] - 2026-10-14

### Added

- **senior-mindset:** Add postmortem method and templates

### Documentation

- **senior-mindset:** Tick task T-4 of spec 0026
- **repo:** Add the postmortem of fix 0023 and tick T-2
- **repo:** Start the postmortem register with past bugs
- **senior-mindset:** Start plan 0026 and tick T-1
- **senior-mindset:** Add spec and plan 0025 for the impact sweep
- **senior-mindset:** Add fix spec 0024 for docs behind the ADRs
- **senior-mindset:** Add spec and plan 0026 for postmortems
- **repo:** Mark SPEC-0016 implemented (#51)

## [senior-mindset-v2.3.0] - 2026-10-14

### Added

- **senior-mindset:** Ask closed questions with clickable options

### Documentation

- **senior-mindset:** Tick task T-3 of spec 0016
- **repo:** Approve spec 0016 and start its plan
- **repo:** Mark SPEC-0023 implemented (#48)

## [senior-mindset-v2.2.1] - 2026-10-14

### Fixed

- **repo:** Refuse to tag a version with nothing new in the skill
- **repo:** Close specs even when the tag step fails
- **senior-mindset:** Never propose the unchanged version
- **senior-mindset:** Check for implementation before a release

### Documentation

- **senior-mindset:** Tick task T-4 of fix 0023
- **repo:** Tick task T-3 of fix 0023
- **senior-mindset:** Tick task T-2 of fix 0023
- **repo:** State that specs never move a version
- **senior-mindset:** Record the reproduction of fix 0023
- **repo:** Mark SPEC-0022 implemented (#44)

## [senior-mindset-v2.2.0] - 2026-10-13

### Added

- **senior-mindset:** Close fix specs with SPEC_DIRS

### Fixed

- **repo:** Keep the on-merge commit when no spec path changed

### Documentation

- **senior-mindset:** Tick task T-3 of spec 0022
- **senior-mindset:** Tick task T-2 of spec 0022
- **repo:** Say the bot closes fixes like features
- **senior-mindset:** Keep the approval gate for trivial fixes
- **senior-mindset:** Tick task T-1 of spec 0022
- **senior-mindset:** Choose the spec type in step 3
- **senior-mindset:** Add fix specs next to feature specs
- **senior-mindset:** Approve spec 0022 and start its plan
- **repo:** Order the roadmap for implementation
- **senior-mindset:** Add spec and plan 0021 for standard installs
- **repo:** Version skills in SKILL.md, keep Claude files out
- **senior-mindset:** Put standard locations first for installs
- **senior-mindset:** Add fix spec 0023 for version bumps
- **senior-mindset:** Add spec and plan 0022 for fix specs
- **senior-mindset:** Add Context7 and MCP directories to spec 0012
- **senior-mindset:** Install skills and MCPs at project scope
- **senior-mindset:** Add spec and plan 0020 for toggling MCPs
- **senior-mindset:** Add spec and plan 0019 for AGENTS.md first
- **repo:** Mark SPEC-0018 implemented (#35)

## [senior-mindset-v2.1.0] - 2026-10-13

### Added

- **senior-mindset:** Ask at kickoff where the code goes

### Documentation

- **senior-mindset:** Add single-file feature 0018 for the code folder choice
- **repo:** Mark SPEC-0017 implemented (#34)

## [senior-mindset-v2.0.0] - 2026-10-13

### Added

- **senior-mindset:** Add a constitution with mission, tech stack and roadmap
- **senior-mindset:** Move the SDD layout under spec/ with colocated plans

### Documentation

- **repo:** Migrate the repo to the spec/ layout
- **senior-mindset:** Add spec 0017 for the spec/ layout
- **senior-mindset:** Add spec and plan 0016 for clickable answers
- **senior-mindset:** Help on install and commands in any language
- **senior-mindset:** Add spec and plan 0015 for optional issue sync
- **senior-mindset:** Add spec and plan 0014 for commands and help
- **senior-mindset:** Build the curated catalogs with the user
- **repo:** Mark SPEC-0007 implemented (#25)

## [senior-mindset-v1.8.0] - 2026-10-13

### Added

- **senior-mindset:** Add a Draft state for plans whose spec is not approved
- **senior-mindset:** Write a plan per spec with the recommended model

### Documentation

- **senior-mindset:** Write draft specs and plans for the roadmap
- **senior-mindset:** Add spec 0007 for a plan per spec
- **repo:** Mark SPEC-0006 implemented (#22)

## [senior-mindset-v1.7.0] - 2026-10-13

### Added

- **senior-mindset:** Greet once on install and on each update

### Documentation

- **senior-mindset:** Add spec 0006 for the welcome message
- **repo:** Mark SPEC-0005 implemented (#21)

## [senior-mindset-v1.6.0] - 2026-10-13

### Added

- **senior-mindset:** Ask which automations to install at kickoff

### Fixed

- **senior-mindset:** Set the git identity before tagging in on-merge

## [senior-mindset-v1.5.0] - 2026-10-13

### Added

- **senior-mindset:** Install release automation by default with github
- **senior-mindset:** Ship release automation templates for apps
- **repo:** Close specs and tag releases automatically on merge

### Changed

- **repo:** Rename tag-releases.sh to tag-skill-releases.sh

### Documentation

- **senior-mindset:** Add spec 0005 for closing specs on merge
- **senior-mindset:** Close spec 0004 as implemented

## [senior-mindset-v1.4.0] - 2026-10-13

### Added

- **senior-mindset:** Apply defensive programming by default

### Documentation

- **repo:** Fix stale git.md line in the inventory
- **senior-mindset:** Add spec 0004 for defensive programming
- **senior-mindset:** Close spec 0003 as implemented
- **senior-mindset:** Close spec 0002 as implemented

## [senior-mindset-v1.3.1] - 2026-10-12

### Fixed

- **senior-mindset:** Hold the approval gate when questions fail

### Documentation

- **senior-mindset:** Add spec 0003 for the headless approval gate

## [senior-mindset-v1.3.0] - 2026-10-12

### Added

- **senior-mindset:** Integrate through pull requests the user merges
- **senior-mindset:** Check for colliding skills on first use
- **senior-mindset:** Date every changelog entry

### Fixed

- **senior-mindset:** Retarget stacked prs before deleting the base

### Documentation

- **repo:** Switch repo rules to pull requests and tag per skill
- **senior-mindset:** Add spec 0002 for release 1.3.0
- **senior-mindset:** Close spec 0001 as implemented

## [senior-mindset-v1.2.0] - 2026-10-12

### Added

- **senior-mindset:** One branch per change, never on master
- **senior-mindset:** Version apps from 0.0.1-alpha.1 to stable

### Fixed

- **senior-mindset:** Load the skill for scripts too
- **senior-mindset:** Verify the kickoff checklist before features
- **senior-mindset:** Never implement without explicit approval

### Documentation

- **senior-mindset:** Add spec 0001 for release 1.2.0
- **repo:** Add inventory of skills, references and hooks
- **repo:** Record versioning, changelog and distribution adrs
- **repo:** Add claude.md with repo conventions and rules

## [senior-mindset-v1.1.0] - 2026-10-12

### Added

- **senior-mindset:** Keep a changelog generated by git-cliff
- **senior-mindset:** Commit after every significant change

### Documentation

- Lead readme with senior-mindset and what it does

## [senior-mindset-v1.0.0] - 2026-10-12

### Added

- **save-image:** Install skills as claude code plugins
- **senior-mindset:** Add skill for senior engineering defaults
- Initial publish — save-image skill

### Documentation

- Rewrite readme with install paths and examples
- README con vidilla y contexto real de save-image

