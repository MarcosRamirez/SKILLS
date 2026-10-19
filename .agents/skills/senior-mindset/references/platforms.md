# Deployment platforms

**Default: Cloudflare** — in practice the cheapest for most web projects (generous
free tier, no egress fees, global edge). The user may prefer another; record the
choice as an ADR because it shapes the stack.

| Platform | Best for | Watch out for |
|---|---|---|
| **Cloudflare** (Workers, Pages, D1, R2, KV, Queues, Hyperdrive) | Web apps, APIs, static sites, edge logic; low cost at any scale | Workers runtime ≠ Node (some npm packages fail); CPU time limits; Postgres via Hyperdrive |
| **Vercel** | Next.js with zero config, preview deployments | Cost grows fast with traffic and functions; vendor-specific features |
| **AWS** | Complex or regulated workloads, broad service catalog, enterprise | Complexity and surprise bills; needs IaC and cost alerts |
| **Hetzner** | Cheap VPS / dedicated servers, EU data residency, long-running workloads | You run everything: OS updates, backups, scaling, security |
| **DigitalOcean** | Simple VPS, managed Postgres, App Platform; middle ground | Fewer managed services than AWS; costs above Hetzner |

## How the platform shapes the stack

- **Cloudflare:** Astro / Next.js via the Cloudflare adapter; Workers for APIs (Hono);
  PostgreSQL through Hyperdrive (or D1 for SQLite-fit cases); R2 for files; Queues for async work.
- **Vercel:** Next.js native; Postgres from Neon/Supabase; background jobs need an extra service.
- **AWS:** Lambda or ECS/Fargate; RDS Postgres; SQS; IaC with Terraform/CDK.
- **Hetzner / DigitalOcean:** Docker + Compose (or Coolify / Kamal); Postgres managed or self-run;
  reverse proxy (Caddy / Traefik) with automatic TLS.

## Questions for the interview

- Expected traffic and growth? Budget?
- Data residency requirements (EU)?
- Long-running processes or heavy CPU (favours VPS/containers over serverless)?
- Who operates it? (No ops time → managed/serverless.)
