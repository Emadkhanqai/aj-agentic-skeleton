---
name: fullstack-standards
description: >
  Engineering standards and architecture derivation for frontend, backend, and full-stack
  projects — .NET/ASP.NET Core/C#/EF Core on the backend, Angular + PrimeNG + TypeScript on
  the frontend, MSSQL and/or Cosmos DB for data. Use this skill whenever writing, reviewing,
  refactoring, or architecting code on any of these stacks; when starting a new frontend,
  backend, or full-stack project; when the user asks about project structure, architecture
  choice, API design, UI standards, error handling, testing, migrations, database design,
  security, or quality gates; or when the user runs /architect.
---

# fullstack-standards — portable engineering brain (frontend + backend + full stack)

Two layers, loaded differently:

1. **Invariants — ALWAYS apply.** Read [`invariants.md`](invariants.md) in every session where
   this skill triggers. Architecture-agnostic, stack-agnostic, non-negotiable. (For
   frontend-only scope, API-producer invariants apply to the backend you consume — hold the
   contract; the process, quality, and security invariants apply in full.)
2. **Playbooks & conditional standards — load ON DEMAND**, per the project's recorded scope.

## Scope decides everything — determine it first

- **Existing project:** the repo's `CLAUDE.md` + `docs/adr/` record scope, playbooks, and data
  stores (written by `/architect`). Follow them; do not re-derive.
- **New / undecided:** run [`/architect`](commands/architect.md). Its first question is scope:
  **frontend-only, backend-only, or full-stack.** Never assume.

## Routing by scope

| Scope | Load |
|---|---|
| **Backend** or **Full-stack** | ONE backend playbook (table below) + data standards per stack |
| **Frontend** or **Full-stack** | the frontend playbook: [`playbooks/frontend-angular-primeng.md`](playbooks/frontend-angular-primeng.md) |
| **Frontend-only** | Also read `standards/api-response-format.md` + `standards/api-design.md` — the consumed contract shape |

## Backend playbook table

| Situation | Load |
|---|---|
| Small team (≤6), one deployable, unclear future scale | [`playbooks/modular-monolith.md`](playbooks/modular-monolith.md) — **default** |
| Complex domain, long-lived, heavy business rules | [`playbooks/clean-architecture.md`](playbooks/clean-architecture.md) |
| *Proven* independent deploy/scale need | [`playbooks/microservices.md`](playbooks/microservices.md) |
| Small tool / POC / single-purpose API | [`playbooks/minimal-api.md`](playbooks/minimal-api.md) |

**Opinionated default:** under ~6 engineers, modular monolith until proven otherwise.
Microservices require a named, concrete constraint — "scalability" without numbers is not one.

## Data standards — conditional, per recorded stack

| Recorded in project | Load | Else |
|---|---|---|
| MSSQL / Azure SQL | [`standards/mssql.md`](standards/mssql.md) (code-first pro practices) + `standards/efcore-migrations.md` | skip |
| Cosmos DB | [`standards/cosmosdb.md`](standards/cosmosdb.md) (partitioning, RUs, ETag, change feed) | **skip entirely** |
| Both (dual-store) | Both files + the sync rule: cross-store consistency via outbox/change feed, never dual writes |

## Topic index (load per task)

| Working on | Read |
|---|---|
| API surface, endpoints, DTOs | `standards/api-design.md` · `api-versioning.md` · `api-response-format.md` · `swagger-openapi.md` |
| Errors & middleware | `standards/error-handling.md` · `middleware.md` |
| Data access & migrations | `standards/ef-core.md` · `efcore-migrations.md` + conditional data standards above |
| Frontend build/UI | the loaded frontend playbook + `standards/typescript.md` |
| Tests | `standards/testing.md` |
| Security | `standards/owasp-security.md` · `dotnet-security.md` · `input-validation-sanitization.md` · `security.md` |
| Observability | `standards/observability-tracing.md` |
| Quality gate & git | `standards/sonarqube.md` · `git-approval-policy.md` · `commands/pre-push.md` |
| Model/cost routing | `model-routing.md` |
| New feature end-to-end | `workflows/new-feature.md` + matching `templates/` |

## Agents

[`agents/`](agents/): `orchestrator`, `backend-engineer`, `frontend-engineer`, `code-reviewer`,
`security-auditor`, `test-engineer`, `quality-gate`. Dispatch per [`model-routing.md`](model-routing.md).

## Enforcement — words become walls

After `/architect` records scope + playbooks + data stores, it MUST write the matching
deterministic guardrails from [`enforcement/`](enforcement/) into the repo: build props,
hooks, architecture tests (backend scopes), lint/format config (frontend scopes). A standard
that can be forgotten is a suggestion; these fail the build.

## Tokens

`{{PROJECT_NAME}}` / `{{ProjectName}}` are replaced by `/architect`. Found at task time →
project not initialized → offer `/architect`.
