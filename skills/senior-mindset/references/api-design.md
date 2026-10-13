# API design

## Contract-first

1. Write or update `spec/api/openapi.yaml` (**OpenAPI 3.1**) before any code.
2. Lint the contract with **Spectral**.
3. Generate types / clients / validators from it when the stack allows
   (openapi-typescript, orval, oapi-codegen, openapi-generator).
4. Serve browsable docs with **Swagger UI** or **Scalar**.
5. Contract tests verify the implementation matches the spec (see [testing.md](testing.md)).
6. Every endpoint gets a line in `spec/INVENTORY.md` linking to the contract.

## Ask and propose (pros/cons, then ADR)

| Decision | Options | Default |
|---|---|---|
| Style | REST · GraphQL (many clients with varied data needs) · gRPC (service-to-service, high throughput) · tRPC (TS monorepo full-stack) | **REST** |
| Versioning | URL (`/v1`) · header (`Accept-Version`) | **URL** |
| JSON field case | camelCase · snake_case | camelCase for JS clients |
| Auth | OAuth2/OIDC · JWT Bearer · API keys (machine-to-machine) · session cookies (first-party web) | depends on clients |

## Default standards (REST)

- **Resources:** plural nouns, kebab-case: `/v1/order-items`, `/v1/users/{userId}/orders`.
  No verbs in paths; actions that are not CRUD → sub-resource (`POST /v1/orders/{id}/cancellation`).
- **Methods:** GET (safe), POST (create), PUT (replace), PATCH (partial), DELETE.
- **Status codes:** 200, 201 + `Location`, 204, 400 (validation), 401, 403, 404, 409 (conflict),
  422 (semantic), 429 (rate limited), 500. Never 200 with an error body.
- **Errors:** **RFC 9457 Problem Details** (`application/problem+json`):

  ```json
  {
    "type": "https://api.example.com/problems/insufficient-funds",
    "title": "Insufficient funds",
    "status": 422,
    "detail": "Balance is 30.00, transfer requires 50.00.",
    "instance": "/v1/transfers/abc123",
    "traceId": "4bf92f3577b34da6"
  }
  ```

- **Pagination:** cursor-based (`?limit=50&cursor=...` → `nextCursor`). Always a max `limit`.
- **Filtering / sorting:** query params (`?status=paid&sort=-createdAt`).
- **Idempotency:** `Idempotency-Key` header on critical POSTs (payments, orders).
- **Rate limiting:** return 429 with `RateLimit-*` / `Retry-After` headers.
- **Dates:** ISO 8601 in UTC (`2026-10-12T09:30:00Z`).
- **IDs:** opaque (UUID v7 / ULID), never sequential integers exposed publicly.
- **Breaking changes:** new version (`/v2`) with a deprecation period; never change `/v1` in place.
- **Security:** see [security.md](security.md) — authz per resource, input validation from the schema.
