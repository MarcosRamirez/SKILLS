# Default stack

Defaults to propose in the kickoff interview. The user can override any of them;
the final choice is recorded as an ADR. Edit this table to change your defaults.

| Use case | Default | Notes |
|---|---|---|
| Simple / content website | **Astro** | Static-first, islands for interactivity |
| Complex web app | **Next.js** | SSR/RSC, auth, dashboards |
| Database | **PostgreSQL** | Relational by default; justify anything else |
| Hosting / deploy | **Cloudflare** | Cheapest in practice; see [platforms.md](platforms.md) |
| Lint + format (TS/JS) | **ESLint + Prettier** or **Biome** | Biome = one fast tool |
| Lint + format (Python) | **Ruff** | Replaces flake8, isort, black |
| Package manager (JS) | **pnpm** | |
| Package manager (Python) | **uv** | |
| Unit tests (TS/JS) | **Vitest** | |
| Unit tests (Python) | **pytest** | |
| E2E tests (web) | **Playwright** | |
| Load tests | **k6** | See [testing.md](testing.md) |
| Logging (TS/Node) | **pino** | See [observability.md](observability.md) |
| API contract | **OpenAPI 3.1** | See [api-design.md](api-design.md) |
| Changelog | **git-cliff** | Generated from commits; see [changelog.md](changelog.md) |
| ORM / query builder | TODO | |
| Auth provider | TODO | |
| Mobile | TODO | |
| Desktop | TODO | |
| Queue / jobs | TODO | Cloudflare Queues if on Cloudflare |
| Cache | TODO | |

`TODO` = no default yet → ask the user and suggest 2–3 options with pros/cons.
