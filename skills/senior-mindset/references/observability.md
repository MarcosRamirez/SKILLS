# Observability (logs, traces, errors)

Set it up **before the first feature**. Debugging production without logs is guessing.

## Rule: do not build a logger from scratch

Recommend an existing library (pros/cons, user chooses, record as ADR). Then write
only a **thin wrapper** — in hexagonal projects a `Logger` port with one adapter —
so the code does not depend on the library. Register the wrapper in `docs/INVENTORY.md`.

## Scope (ask in the kickoff interview)

1. Logs only (small projects)
2. Logs + error tracking
3. Logs + error tracking + distributed traces (multiple services, queues)

## Candidates

| Need | TS / Node | Python | Go | Rust |
|---|---|---|---|---|
| Structured logs | **pino** | **structlog** (or stdlib `logging` + JSON formatter) | **log/slog** (stdlib) | **tracing** |
| Traces / metrics | **OpenTelemetry** SDK | OpenTelemetry | OpenTelemetry | OpenTelemetry (`tracing-opentelemetry`) |
| Error tracking | **Sentry** | Sentry | Sentry | Sentry |

## Destinations (by platform)

| Platform | Options |
|---|---|
| Cloudflare | Workers Logs, Logpush (to R2 or a vendor), Workers Observability |
| AWS | CloudWatch Logs, X-Ray (or OTel collector) |
| Self-hosted (Hetzner, DigitalOcean) | Grafana Loki + Tempo, or a vendor agent |
| Vendor (any) | Better Stack, Grafana Cloud, Axiom, Datadog |

## Rules

- **Structured JSON**, one event per line: `{ "level": "info", "msg": "invoice created", "invoiceId": "...", "traceId": "..." }`.
- **Levels:** `debug` (dev only), `info` (business events), `warn` (recoverable anomaly), `error` (needs attention).
- Level configurable per environment (`LOG_LEVEL`).
- **Correlation:** generate or accept a `requestId` / `traceId` at the edge and propagate it
  through services, queues and events (W3C `traceparent` header).
- **What to log:** request start/end with status and latency, auth events (login,
  logout, failures, permission denials), state changes in the domain, external
  calls with latency and result, every handled error (once, at the boundary).
- **Never log:** passwords, tokens, API keys, secrets, full card numbers, or personal
  data (emails, phone numbers, addresses) unless masked. Configure the library's
  redaction (`pino` `redact`, structlog processors). This is OWASP A09.
- Messages are constant strings; variable data goes in fields (searchable).
