---
description: Implement a feature/slice task-by-task following the standards, TDD, and the non-negotiable rules. Builds and tests; never pushes.
---

# /implement

Implement a scoped piece of work (a plan task, a feature, a slice step) for the {{PROJECT_NAME}}
Gateway.

## Before writing code
1. Identify the **slice** and read the design spec + `docs/knowledge-graph/` (invariants).
2. Read the applicable [`../standards/`](../standards/) files and the matching
   [`../workflows/`](../workflows/) doc ([`new-feature.md`](../workflows/new-feature.md),
   [`api-change.md`](../workflows/api-change.md), [`database-change.md`](../workflows/database-change.md)).
3. If there is an implementation plan under `docs/superpowers/plans/`, follow it task-by-task.

## While implementing
- Work on a branch, never `main`. TDD: failing test → minimal code → green → commit.
- Respect Clean Architecture boundaries; **DTOs only, never bind EF entities**; FluentValidation
  on every request; **`ApiResponse<T>`** with `traceId`; **versioned** routes; role + channel +
  ownership authorization; price-list no-leak via role-scoped projection.
- Schema change → EF migration (reviewed, business-intent name); money `decimal`; audit
  append-only + hash-chained.
- **No Docker. MSSQL only. No `EnsureCreated`/manual DDL.**

## Finish
- `dotnet build && dotnet test`; `npm run typecheck && npm run build` where frontend changed.
- Update OpenAPI + regenerate frontend types (`/sync`) if the API surface changed.
- Run `/review`, then the pre-push quality gate.
- **Do not push.** Summarize results and wait for explicit approval.
