# SPEC-0010 design

| Environment | What it is | Data | How code gets there |
|---|---|---|---|
| local | Developer machine | Seed / test data | Own branch |
| preview | Ephemeral deploy per PR (Cloudflare, Vercel); gone after merge | Test data | Every PR, automatic |
| staging (pre-production) | Faithful copy of production; last check before release | Production-like, anonymised | Merge to default branch |
| production | Real users | Real | Release tag `vX.Y.Z` |

- Platform notes: Cloudflare (Workers environments, preview URLs), Vercel (preview deployments),
  VPS (separate compose files / hosts).
- Secrets: platform secret stores per environment; never shared between staging and production.
