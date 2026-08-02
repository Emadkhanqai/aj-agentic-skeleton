# Playbook: Modular Monolith (default)

One deployable, hard internal module boundaries. The default choice for teams ≤6 and any
project whose future scale is unproven. Migrates to services later far more cheaply than
premature microservices migrate back.

## Structure

```
src/
├── {{ProjectName}}.Api/               # Composition root: endpoints, middleware, DI
├── Modules/
│   ├── Orders/                        # One folder per business module
│   │   ├── {{ProjectName}}.Orders.Contracts/    # Public surface: DTOs, module interface, events
│   │   ├── {{ProjectName}}.Orders.Domain/       # Entities, rules — internal to module
│   │   ├── {{ProjectName}}.Orders.Application/  # Handlers, validators (vertical slices)
│   │   └── {{ProjectName}}.Orders.Infrastructure/ # EF Core DbContext, repositories
│   └── Catalog/ …
└── {{ProjectName}}.SharedKernel/      # ApiResponse<T>, Result<T>, base types ONLY
tests/  (unit + integration + architecture per module)
```

## Rules (enforced by architecture tests)

1. **Modules talk through Contracts only.** Module A never references B's Domain,
   Application, or Infrastructure — only `B.Contracts`. References, not reach-ins.
2. **Each module owns its data.** Own `DbContext`, own schema (or table prefix). No
   cross-module JOINs; need another module's data → call its contract or subscribe to its event.
3. **Cross-module writes are events**, handled via an in-process bus (MediatR notifications /
   channels) with the transactional outbox pattern when consistency matters.
4. **Inside a module: vertical slices.** One folder per feature
   (`Application/Features/CompleteOrder/`) containing handler + validator + tests together.
5. **SharedKernel stays tiny** — envelope, Result, base exceptions. If two modules "need" to
   share business logic, that logic belongs to one of them behind its contract.
6. Composition root (`Api`) is the only project referencing all modules.

## When to leave this playbook

A single module dominates load and needs independent scaling — extract *that module* to a
service (its Contracts project is already its API shape). Record the move in an ADR. Never
extract more than one module at a time.
