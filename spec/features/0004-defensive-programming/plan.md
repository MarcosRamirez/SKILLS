# SPEC-0004 design

- **Validate at the boundary, assert inside.** Data crossing a trust boundary is validated
  and normalized once. Inside, code trusts the typed result and uses assertions only for
  invariants that would mean a bug. This keeps defensive code from turning into the same
  `if` repeated in every function (the pragmatism rule).
- **Checks do not replace error handling.** A free-space check before writing is a fast,
  friendly failure, but the disk can fill between the check and the write (TOCTOU). Both are
  needed: check first, then handle `ENOSPC`, and write to a temp file plus an atomic rename
  so a failed write never leaves a corrupt file.
- **Short SKILL.md, detail in the reference.** One always-on bullet and one checklist item;
  patterns and examples live in `references/defensive-programming.md`.
- MINOR bump (new rule and reference): senior-mindset 1.4.0.
