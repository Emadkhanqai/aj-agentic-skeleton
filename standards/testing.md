# Standard: Testing

Testing is required, not optional. Verification precedes any claim of "done" and any
push.

## Backend test projects

| Project | Scope |
|---|---|
| `{{ProjectName}}.UnitTests` | Domain rules & Application handlers in isolation (no DB, no I/O). Fast. |
| `{{ProjectName}}.IntegrationTests` | Application + Infrastructure against a **real database** per the recorded stack (e.g. local/Azure SQL). EF migrations applied. |
| `{{ProjectName}}.ArchitectureTests` | Enforces the Clean Architecture dependency rules (e.g. via NetArchTest). Fails the build if a layer imports the wrong direction. |

- Frameworks: xUnit + FluentAssertions; NSubstitute/Moq for doubles.
- Integration tests hit MSSQL (native), never an in-memory substitute for
  MSSQL-specific behaviour.
- Architecture tests encode [`clean-architecture.md`](clean-architecture.md):
  Domain depends on nothing; Application→Domain; Infrastructure→Application,Domain;
  Contracts has no business logic; Api is the composition root.

## Frontend tests

- Unit/component: Vitest + React Testing Library.
- Test behaviour and accessibility, not implementation details.
- Type safety (`npm run typecheck`) is part of the test surface.

## What must be covered

- Every domain invariant and business rule from the BRD (Order Ref ID uniqueness,
  completeness gating, price-list visibility restrictions, WHT/PHF math, amendment
  types, audit-append behaviour).
- Price-list raw values must be **provably** hidden from DOP/MD-ED at the API layer —
  there must be a test asserting the API never returns raw rates to those roles
  (BRD 3.1.4/3.1.5).

## Commands

```bash
dotnet test                    # all backend test projects
npm run typecheck              # frontend types
npm run test                   # frontend unit/component tests (if present)
```

## Gate

Tests must pass before the SonarQube scan and before a push is proposed. See
[`../workflows/pre-push-quality-gate.md`](../workflows/pre-push-quality-gate.md).
