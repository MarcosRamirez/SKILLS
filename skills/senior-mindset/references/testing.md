# Testing

## Strategy (test pyramid)

| Layer | What | Tooling (defaults) | When |
|---|---|---|---|
| Unit | Domain rules, use cases, pure functions | Vitest / pytest / `go test` / `cargo test` | Always, in every project |
| Integration | Adapters against real dependencies (DB in a container, HTTP) | Same runner + Testcontainers | Every outbound adapter |
| Contract | API matches `openapi.yaml` | Schemathesis, Dredd, or generated validators | Projects with an API |
| E2E | Critical user journeys only | Playwright | Web apps |
| Load / stress | Throughput and latency targets | **k6** | Web apps / APIs with expected traffic |

Rules:

- Every acceptance criterion (`AC-n`) is covered by at least one test.
- Every task in `tasks.md` lists its tests.
- Tests are readable specs: `it("rejects an expired coupon")`, Arrange–Act–Assert.
- No sleeping, no shared state between tests, no real external services in unit tests.
- A bug fix starts with a failing test that reproduces it.

## TDD

Recommend TDD (red → green → refactor) for:

- Large projects.
- Critical domain logic: payments, pricing, permissions, calculations, state machines.

Suggest it in the design; the user decides. For glue code and UI, tests-after is fine.

## Load and stress testing

**Default tool: k6** — scripts in JS, version-controlled, CI-friendly, thresholds as code.

Alternatives:

- **Apache JMeter** — complex scenarios, GUI recorder, non-HTTP protocols (JDBC, JMS…).
- **`ab` (Apache Bench)** — quick smoke test of a single endpoint.

Types:

| Type | Goal |
|---|---|
| Load | Expected traffic — verify SLOs |
| Stress | Ramp up until it breaks — find the limit and how it fails |
| Spike | Sudden burst — check autoscaling and recovery |
| Soak | Expected load for hours — find leaks and degradation |

Rules:

- Targets come from the spec as measurable ACs: `p95 < 300 ms at 200 RPS`, `error rate < 1%`.
- Scripts live in `tests/load/`. Encode targets as k6 `thresholds` so the run fails if they are missed.
- Run against **staging**. Never against production without explicit user permission.

Minimal k6 example:

```js
import http from "k6/http";
import { check } from "k6";

export const options = {
  vus: 50,
  duration: "2m",
  thresholds: {
    http_req_duration: ["p(95)<300"],
    http_req_failed: ["rate<0.01"],
  },
};

export default function () {
  const response = http.get(`${__ENV.BASE_URL}/v1/health`);
  check(response, { "status is 200": (r) => r.status === 200 });
}
```

## Trying the platform first

Before relying on how a platform behaves (GitHub, a CI runner, a CLI), try it on a throwaway
repository or in CI with a runner-like configuration: no global git identity, no `autocrlf`, a fresh
checkout. Your own machine hides what a runner lacks, so a test that passes only locally proves little.
