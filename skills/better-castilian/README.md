# better-castilian

Writing rules for Castilian Spanish, for agents that write in it. Loaded when a text in Spanish
is written or reviewed. Current rules:

1. No `≈` or `~` for "approximately".
2. Approximate amounts use words (`unas`, `aproximadamente`, `cerca de`); `±` only for a tolerance or compact notation (`30 min ±5`).
3. No long dash (`—`) and no en dash (`–`) as a substitute.
4. Angular quotes « » to quote.
5. Avoid needless anglicisms when a common Spanish term exists.
6. Numbers and units: `1.400`, `2,5`, `30 min`.
7. Only the first letter in titles and headings, proper nouns keep their capital; months and days lowercase.
8. Acronyms take no plural s (`las ONG`).

The checker enforces rules 1 to 3 (the mechanical ones); the others are for the writer.

`scripts/check_writing.py` finds the offending characters in a file and says where, skipping code
blocks, inline code, URLs and paths such as `~/dir`:

```bash
python skills/better-castilian/scripts/check_writing.py text.md
```

Exit codes: 0 clean, 1 findings, 2 usage or unreadable file. Python 3, no dependencies.

## Install

```bash
npx skills add MarcosRamirez/SKILLS --skill better-castilian -a claude-code codex --copy
```

or as a plugin: `/plugin marketplace add MarcosRamirez/SKILLS` then
`/plugin install better-castilian@marcosramirez-skills`.

New rules are added only when the owner approves them. See [SKILL.md](SKILL.md).
