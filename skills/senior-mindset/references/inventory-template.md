# Inventory template

Copy to `spec/INVENTORY.md` at kickoff. Link it from AGENTS.md so every session reads it.

**Purpose:** before writing any function, helper, client, script or tool, check here
(and grep). If it exists, use or extend it. After creating or removing something,
update this file in the same commit.

Format: one line per item — `name — path — purpose — usage`.

```markdown
# Inventory

What already exists in this project. Check before creating; update after changing.

## Data access
- `invoiceRepository` — src/adapters/outbound/db/invoice-repository.ts — CRUD for invoices (Postgres) — `invoiceRepository.findById(id)`
- `db` — src/adapters/outbound/db/client.ts — pooled Postgres client — import `{ db }`

## Use cases / services
- `CreateInvoice` — src/application/create-invoice.ts — validates and persists an invoice, emits `InvoiceCreated` — `new CreateInvoice(repo, events).execute(input)`

## Utilities
- `logger` — src/adapters/outbound/logger.ts — pino wrapper with redaction and traceId — `logger.info("msg", { field })`
- `money` — src/domain/money.ts — integer-cents arithmetic and formatting — `Money.fromCents(1999)`

## Scripts / CLI
- `seed` — scripts/seed.ts — seed dev database — `pnpm seed`

## API endpoints
- `POST /v1/invoices` — src/adapters/inbound/http/invoices.ts — create invoice — contract: spec/api/openapi.yaml#/paths/~1v1~1invoices

## Events / queues
- `InvoiceCreated` — producer: CreateInvoice — consumers: send-invoice-email worker

## Database schema
- `invoices` — migrations/0003_create_invoices.sql — invoice header (id, customer_id, total_cents, status)

## External integrations
- Stripe — src/adapters/outbound/stripe/ — payments — env: `STRIPE_SECRET_KEY`
```
