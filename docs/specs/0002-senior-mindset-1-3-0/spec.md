# SPEC-0002: senior-mindset 1.3.0 — collision check, pull-request flow, dated changelog

Status: Approved
Date: 2026-10-13
Approved by: the user, 2026-10-13, approving the plan in conversation.

## Problem

1. Other installed skills (e.g. a git workflow skill) can contradict senior-mindset, and today
   the skill silently yields to any git skill without asking.
2. Work reaches the default branch through local merges, with no review step.
3. The changelog has no dates: nothing was ever tagged, so every entry sits in `[Unreleased]`.

## Requirements

- R-1 On first use per user, detect overlapping skills and conventions, ask which one wins per area, and store the answer.
- R-2 Everything reaches the default branch through a pull request that the user merges. Dependent tasks are stacked PRs.
- R-3 No remote → offer to create one; if declined, merge locally.
- R-4 Every changelog entry has a date; released versions have dated sections.

## Acceptance criteria

- AC-1 `references/setup.md` describes the inventory, the areas, the questions, the `~/.claude/senior-mindset.md` format, re-checks, and headless behavior.
- AC-2 `SKILL.md` Step 0a runs the setup when `~/.claude/senior-mindset.md` is missing; Step 0b follows its decisions instead of "any git skill wins".
- AC-3 `git.md` and `SKILL.md` define the PR flow: push branch, `gh pr create`, stop, user merges; stacked PRs for dependent tasks; never push to or merge into the default branch.
- AC-4 No-remote handling: offer `gh repo create` / `glab repo create` / a URL, with local merge as fallback.
- AC-5 Release and changelog references follow the PR flow.
- AC-6 The `cliff.toml` template dates every `[Unreleased]` entry; this repo has per-skill changelogs with dated version sections and retroactive tags.
- AC-7 The repo `CLAUDE.md` uses the PR flow and the per-skill tag-and-changelog rule.
- AC-8 senior-mindset 1.3.0 and save-image 1.0.1; READMEs and inventory updated.
- AC-9 The setup run in this session writes `~/.claude/senior-mindset.md`. A headless run without the file uses defaults with no push or PR, and does not write the file.
- AC-10 After the PRs are merged, `claude plugin update` moves the install to 1.3.0.

## Out of scope

- CI pipelines and branch protection rules on GitHub.
- A SessionStart hook for the setup.
