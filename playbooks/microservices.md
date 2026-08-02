# Playbook: Microservices

Only for a *proven* need: independent deploy/scale of parts, multiple teams owning services,
or hard fault-isolation requirements. This playbook assumes the org accepts the distributed-
systems tax: eventual consistency, observability investment, and contract governance.

## Structure (per service repo or monorepo folder)

Each service is internally a small clean-layered app (Api / Application / Domain /
Infrastructure) and owns its database exclusively. No shared databases, ever.

## Rules (enforced by architecture tests + contract tests)

1. **Database per service.** Another service's data is reached via its API or its events —
   never its tables.
2. **Contracts are versioned artifacts.** OpenAPI (sync) and event schemas (async) live in a
   contracts repo/package; consumer-driven contract tests gate every publish. Breaking change
   → new version, deprecation window, never silent.
3. **Async-first between services** (message bus + outbox); sync calls only for genuine
   request/response needs, always with timeout, retry policy, and circuit breaker (Polly).
4. **Every request carries a correlation ID** across all hops; distributed tracing
   (OpenTelemetry) is mandatory from day one, not "later".
5. **Idempotent consumers.** Every event handler tolerates redelivery.
6. **Each service ships its own CI pipeline** running the shared gate (invariants #2-#3) plus
   contract tests.
7. **No distributed transactions.** Sagas/process managers with compensating actions.

## Anti-rules

- No entity sharing via NuGet "common domain" packages — that's a distributed monolith.
- No service calling more than ~2 other services synchronously in one request path.
- Fewer, larger services beat many nano-services. Start from the modular monolith's module
  map; one module = one service candidate.
