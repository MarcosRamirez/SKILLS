# SPEC-0006 design

- **Hook point:** the first-use setup already runs once per user and writes
  `~/.claude/senior-mindset.md`. The welcome message is printed right after the file is written,
  so it shows exactly once per install.
- **Update detection:** compare the skill's own version (frontmatter `metadata.version`) with
  `senior-mindset version:` in the config file. Newer → print the update line, then rewrite the
  version field. Equal → print nothing.
- **Restraint:** credit once per install or update. Shown on every use, it would be noise, and
  noise gets skills uninstalled.
- **Headless:** the setup does not write the file without answers, so no welcome is printed,
  and it is not repeated on every headless run.
- MINOR bump: 1.7.0.
