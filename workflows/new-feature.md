# Workflow: New Feature

> **Model routing (do first):** classify the task and recommend a model — see [`../model-routing.md`](../model-routing.md). New-capability *design* → **Opus/Fable**; the *build/tests* that follow → **Sonnet**. Warn the user if the current model is too expensive before continuing.

End-to-end flow for a new capability across the stack. Supersedes/extends
[`feature-development.md`](feature-development.md) with the 2026-grade standards.

## 1. Understand & plan
- Identify the **slice** (1–6) and read the design spec + `docs/knowledge-graph/` (invariants).
- Read the relevant BRD section(s) in `/docs` and the applicable [`../standards/`](../standards/).
- Trace which invariants the feature must honour (Ref-ID-once, completion gating, price-list
  no-leak, vendor scope, dual currency, WHT, audit).

## 2. Branch
- `git checkout -b feature/<short-desc>`. Never work on `main` directly.

## 3. Backend (if applicable)
1. **Domain** — entities/invariants, persistence-ignorant. Guard rules in the aggregate.
2. **Application** — commands/queries + handlers, ports, **FluentValidation** on every request
   ([`../standards/input-validation-sanitization.md`](../standards/input-validation-sanitization.md)).
   Enforce role + channel scope + object ownership ([`../standards/owasp-security.md`](../standards/owasp-security.md)).
3. **Infrastructure** — EF config + repositories; schema change → migration
   ([`database-change.md`](database-change.md)).
4. **Contracts** — DTOs; **`ApiResponse<T>`** envelope. **Never bind EF entities.**
5. **Api** — thin **versioned** controllers (`/api/v1/...`); errors via central handler with
   `traceId`; document in OpenAPI. Respect the middleware order ([`../standards/middleware.md`](../standards/middleware.md)).
6. **Tests** — Unit + Integration + Architecture (incl. the price-list no-leak assertion).

## 4. Sync contracts
- Update Swagger/OpenAPI; regenerate frontend types (`/sync`) into
  `frontend/src/shared/api/generated`. See [`api-change.md`](api-change.md).

## 5. Frontend (if applicable)
1. Feature module under `src/features/<feature>`; centralized API in `src/shared/api` using
   generated types; consume **versioned** endpoints.
2. Forms validated (Zod/RHF); TanStack Query for server state; handle
   loading/error/empty/success; surface `traceId` on errors.
3. **Role-aware UI, never trusted as security.** No XSS; no `dangerouslySetInnerHTML` unless reviewed.

## 6. Verify locally
- `dotnet build && dotnet test`; `npm run typecheck && npm run build`.

## 7. Review & gate
- `/review` (architecture, standards, BRD correctness, OWASP, middleware order).
- Pre-push quality gate ([`pre-push-quality-gate.md`](pre-push-quality-gate.md)) — fix all
  Blocker/Critical/Major. **Do not push without explicit approval.**
