# Standard: Clean Architecture (.NET)

**Applies to:** the `{{ProjectName}}.*` backend solution.

## Layers & dependency rule

Dependencies point **inward only**. Nothing inner knows about anything outer.

```
        ┌─────────────────────────────────────────┐
        │                  Api                     │  (host, DI, controllers, middleware)
        │  depends on → Application, Infrastructure,│
        │               Contracts                   │
        └───────────────────┬──────────────────────┘
                            │
     ┌──────────────────────┴───────────────────────┐
     │              Infrastructure                   │  (EF Core, MSSQL, external services)
     │      depends on → Application, Domain          │
     └──────────────────────┬───────────────────────┘
                            │
             ┌──────────────┴──────────────┐
             │          Application         │  (use cases, CQRS handlers, ports)
             │      depends on → Domain      │
             └──────────────┬──────────────┘
                            │
                    ┌───────┴────────┐
                    │     Domain      │  (entities, value objects, domain rules)
                    │  depends on NOTHING │
                    └────────────────┘

   Contracts  (DTOs only, no business logic) — referenced by Api (and consumers)
```

## The rules (enforced by ArchitectureTests)

| Project | May depend on | Must NOT depend on |
|---|---|---|
| `{{ProjectName}}.Domain` | *(nothing — no EF, no ASP.NET, no external packages beyond base)* | Everything else |
| `{{ProjectName}}.Application` | Domain | Infrastructure, Api |
| `{{ProjectName}}.Infrastructure` | Application, Domain | Api |
| `{{ProjectName}}.Api` | Application, Infrastructure, Contracts | *(is the composition root)* |
| `{{ProjectName}}.Contracts` | *(nothing — pure DTOs)* | Domain, Application, Infrastructure |

## Responsibilities

- **Domain** — entities (Order, OrderLine, RateCard, VendorInvite, AuditEntry…),
  value objects, enums, domain events, and invariants. Persistence-ignorant. No
  attributes from EF/ASP.NET.
- **Application** — use cases (commands/queries + handlers), orchestration,
  validation (FluentValidation), and **ports** (interfaces like `IOrderRepository`,
  `IClock`, `ICadIntegrationGateway`) that Infrastructure implements.
- **Infrastructure** — EF Core `DbContext`, MSSQL provider, migrations, repository
  implementations, external gateways (CAD, email), and other adapters.
- **Contracts** — request/response **DTOs only**. Shared with the frontend via
  OpenAPI. No logic, no domain types, no EF types.
- **Api** — thin controllers, DI wiring (composition root), middleware
  (ProblemDetails, auth), Swagger. Maps Contracts ↔ Application.

## Conventions

- Application uses **CQRS-style** handlers. Mediator pattern is acceptable; keep it
  simple if a plain handler suffices.
- Controllers are thin: validate input shape, dispatch to Application, map result to
  a Contracts DTO, return. **No business logic in controllers.**
- Domain never returns Contracts DTOs; mapping happens in Api/Application.
- No Docker anywhere. MSSQL only. EF Core migration-based (see [`ef-core.md`](../standards/ef-core.md)).

## Related

- [`dotnet.md`](../standards/dotnet.md) · [`ef-core.md`](../standards/ef-core.md) · [`api-design.md`](../standards/api-design.md) · [`testing.md`](../standards/testing.md)
