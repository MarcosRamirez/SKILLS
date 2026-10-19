# Architecture principles

Principles are tools, not goals. Apply them where they reduce cost of change;
skip them where they only add ceremony.

## When to use what

| Project | Architecture |
|---|---|
| Script, landing page, content site | Framework-native structure. No layers. |
| CRUD app with little logic | Framework-native + a thin service layer |
| App with real business rules (pricing, workflows, permissions, integrations) | **Hexagonal** (ports & adapters) |

## Hexagonal (ports & adapters)

```
src/
  domain/            entities, value objects, domain rules — no framework, no I/O
  application/       use cases; defines ports (interfaces) it needs
  adapters/
    inbound/         HTTP controllers, CLI, UI, queue consumers → call use cases
    outbound/        DB repositories, external APIs, email, logger → implement ports
```

- Dependencies point **inward**: adapters → application → domain. Never the reverse.
- The domain is testable without a database, network or framework.
- Swapping Postgres for another store, or Sentry for another tool, touches only an adapter.

## SOLID (in practice)

- **S**ingle responsibility: one reason to change per module.
- **O**pen/closed: extend by adding code (new adapter, new strategy), not by editing stable code.
- **L**iskov: implementations of a port are interchangeable.
- **I**nterface segregation: small ports (`InvoiceRepository`), not god interfaces.
- **D**ependency inversion: use cases depend on ports; adapters are injected.

## DRY, KISS, YAGNI

- **KISS** wins ties. The simplest design that meets the spec is the right one.
- **DRY — rule of three:** duplicate once, abstract on the third occurrence. A wrong
  abstraction costs more than duplication. DRY is about knowledge, not similar-looking code.
- **YAGNI:** do not build for hypothetical requirements. Leave seams (ports), not features.

## Smells that call for refactoring

- A change requires touching many unrelated files (shotgun surgery).
- Business rules inside controllers, SQL or UI components.
- Circular dependencies between modules.
- Functions longer than a screen or with more than 3 levels of nesting.
