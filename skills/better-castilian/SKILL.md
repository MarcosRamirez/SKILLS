---
name: better-castilian
description: >
  Writing rules for Castilian Spanish: no double tilde or simple tilde for "approximately",
  use the plus-minus sign for approximate amounts, no long dash. Use whenever writing or
  reviewing ANY text in Spanish (messages, reports, comments, posts, documentation, commit
  and pull request text), and before delivering it. Includes a checker script.
license: MIT
compatibility: The checker needs Python 3 (standard library only).
metadata:
  author: Marcos Ramírez
  homepage: https://marcosramirez.info
  version: "0.0.1-alpha.1"
allowed-tools: Bash Read
---

# better-castilian

Rules for any text written in Castilian Spanish. The list grows: only approved rules are added.

## Rules

1. **No double tilde and no simple tilde to say "approximately".**
2. **Approximate amounts use `±`**, attached to the figure: `±30 min`, `±2 h`, `±1.400 filas`.
3. **No long dash (em dash, U+2014) and no en dash (U+2013) as a substitute.** Use a comma, a
   period, a colon, parentheses, or rewrite the sentence.

## Bad and good

| Bad | Good |
|---|---|
| `Tardo ≈ 30 min` | `Tardo ±30 min` |
| `Son ~2 h de trabajo` | `Son ±2 h de trabajo` |
| `Unas ≈1.400 filas` | `Unas ±1.400 filas` |
| `El script — que ya existe — falla` | `El script (que ya existe) falla` |
| `Hecho — falta la revisión` | `Hecho. Falta la revisión.` |
| `Hay un fallo — la ruta es nula` | `Hay un fallo: la ruta es nula` |

## Exceptions the rules do not touch

Code, paths and URLs keep their characters: `~/proyecto`, `https://ejemplo.org/~usuario`, a
fenced block, an inline code span. Quote someone else's text unchanged if it must stay literal.

## Check before delivering

```bash
python scripts/check_writing.py FILE [FILE ...]     # '-' reads stdin
```

It prints `file:line:column: character reason` for each finding and exits 1. Clean text prints
nothing and exits 0; an unreadable file exits 2. Fenced blocks, inline code, URLs and tilde paths
are skipped. Fix every finding, then run it again.

## Proposing a rule

Never add a rule here on your own. Write the proposal in your delivery under "Proposed, not
approved" and wait for the owner's approval.
