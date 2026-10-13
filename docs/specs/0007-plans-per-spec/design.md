# SPEC-0007 design

- **Spec = what and why; tasks = the list; plan = how to execute it.** One plan per spec,
  same number and slug, so "plan 0008" and "SPEC-0008" are the same thing.
- **Tier in the filename** (`.high.md`, `.medium.md`, `.low.md`) so plans can be filtered at a glance;
  it is repeated inside the file. If the overall tier changes, `git mv` the file and fix the links.
- **Tiers, not model names, in plans.** `references/models.md` is the only place with concrete
  names, dated and sourced, so a new model release means editing one table.
- **Plan lifecycle:** `Ready` → `In progress` → `Done`. `Done` is set by the same bot that closes the spec
  (`close-specs.sh` looks for `docs/plans/NNNN-*.md`), keeping "never mark it by hand".
- **Status lines** are separate lines (`Spec:`, `Status:`, `Recommended overall:`), so the script can
  edit `Status:` safely.
- **Workflows:** commit-message ids are computed only from `spec.md` paths; plan paths are
  committed in the same bot commit.
