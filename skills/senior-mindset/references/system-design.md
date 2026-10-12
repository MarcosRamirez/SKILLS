# System design

## Monolith vs microservices

**Default: modular monolith.** One deployable, modules with clear boundaries
(each module owns its data and exposes use cases). It can be split later along
those boundaries if needed.

Propose microservices only when at least one of these signals is real (not hypothetical):

- Parts with very different scaling or resource profiles (e.g. API vs. video encoding).
- Independent teams that need to deploy independently.
- Fault isolation is a hard requirement (one part failing must not take down the rest).
- Different runtime/language is clearly better for one part (see [languages.md](languages.md)).

Costs to state honestly in the design: network latency and failures, distributed
transactions, observability across services, more infrastructure, more CI/CD.

If you choose the monolith, write one line on why microservices were not needed.

## Event-driven design

Use events/queues when:

- Work is slow or bursty and should not block the request (emails, image processing, reports).
- Several consumers react to the same fact (fan-out: `OrderPlaced` → invoice, email, analytics).
- Integrations should be decoupled (a downstream outage must not fail the user request).

Requirements whenever you use it:

- **Idempotent consumers** — the same event can arrive twice.
- **Retries with backoff** and a **dead-letter queue**.
- Decide whether **ordering** matters; if it does, partition by key.
- Events are named in past tense (`InvoicePaid`), versioned, and carry an id + `traceId`.
- Outbox pattern when a DB write and an event must both happen or neither.

Platform options: Cloudflare Queues, AWS SQS/SNS/EventBridge, RabbitMQ, NATS,
Kafka (only for high-throughput streaming).

## Other questions to answer in design.md when relevant

- Sync vs async for each interaction.
- Consistency: strong vs eventual, and what the user sees meanwhile.
- Failure modes: what happens when each dependency is down.
- Data ownership: which module is the source of truth for each entity.
