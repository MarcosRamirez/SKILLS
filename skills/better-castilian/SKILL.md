---
name: better-castilian
description: >
  Writing rules for Castilian Spanish: no tilde for "approximately" (use words), plus-minus
  only for tolerances, no long dash, angular quotes, numbers and units, capitals, no needless anglicisms. Use whenever writing or
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
2. **Approximate amounts use words**: `unas`, `unos`, `aproximadamente`, `alrededor de`, `cerca de`.
   `±` only for a tolerance or in compact notation where a word does not fit (tables, estimates
   such as `30 min ±5`). In running text, "son unas 1.400 filas" carries no symbol.
3. **No long dash (em dash, U+2014) and no en dash (U+2013) as a substitute.** Use a comma, a
   period, a colon, parentheses, or rewrite the sentence.
4. **Angular quotes « » to quote**, not English double quotes.
5. **Avoid needless anglicisms** when a common Spanish term exists (despliegue, tarea o
   incidencia, revisión). Technical terms with no settled equivalent stay.
6. **Numbers and units**: thousands separator point (`1.400`), decimal comma (`2,5`), a space
   between figure and unit (`30 min`), unit symbols without a final period.
7. **Capitals**: only the first letter in titles and headings, but proper nouns keep their
   capital (people, places, brands, organisations, products). Months and days of the week are
   lowercase.
8. **Acronyms take no plural s**: `las ONG`, `los PDF`.

## Bad and good

| Bad | Good |
|---|---|
| `Tardo ≈ 30 min` | `Tardo unos 30 min` |
| `Son ~2 h de trabajo` | `Son aproximadamente 2 h de trabajo` |
| `Unas ≈1.400 filas` | `Son unas 1.400 filas` |
| `El script — que ya existe — falla` | `El script (que ya existe) falla` |
| `Hecho — falta la revisión` | `Hecho. Falta la revisión.` |
| `Hay un fallo — la ruta es nula` | `Hay un fallo: la ruta es nula` |
| `Dijo "no hay prisa"` | `Dijo «no hay prisa»` |
| `Hicimos el deploy ayer` | `Hicimos el despliegue ayer` |
| `1400 filas, 2.5 s, 30min` | `1.400 filas, 2,5 s, 30 min` |
| `El Plan De Trabajo De Marzo` | `El plan de trabajo de marzo` |
| `Hablé con maría en madrid` | `Hablé con María en Madrid` |
| `Los PDFs y las ONGs` | `Los PDF y las ONG` |

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
