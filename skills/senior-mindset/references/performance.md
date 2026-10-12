# Computational cost

Know what your code costs. Optimize only what you have measured, but never write
the obviously expensive version by default.

## Know the complexity

- Note the Big-O in a comment when it is not obvious or not O(n).
- Nested loops over the same data (O(n²)) → use a `Map`/`Set`/dict for lookups (O(n)).
- Sorting is O(n log n); do not sort inside a loop.
- Prefer streaming/iterating over loading everything in memory for large data.

## I/O dominates

- **N+1 queries:** never query inside a loop. Use joins, `IN (...)`, or batch loaders.
- Select only the columns you need; paginate every list endpoint.
- Index columns used in `WHERE`, `JOIN` and `ORDER BY`; check with `EXPLAIN`.
- Batch external API calls; run independent calls concurrently.
- Set timeouts on every network call.

## Caching

- Cache only what is expensive and read far more than written.
- Every cache needs an invalidation strategy and a TTL — write it in `design.md`.
- HTTP caching (Cache-Control, ETag, CDN) is the cheapest cache there is.

## Cost in the cloud

- On serverless (Workers, Lambda): CPU time, cold start and requests are money.
  Keep bundles small; avoid heavy work on the request path — push it to a queue.
- Egress and DB connections are hidden costs; use connection pooling (Hyperdrive, PgBouncer).

## When to optimize

1. Make it correct and readable.
2. Measure (profiler, `EXPLAIN`, load test — see [testing.md](testing.md)).
3. Optimize the hot path only, and keep the readable version when the gain is small.
