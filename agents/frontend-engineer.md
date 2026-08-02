---
name: frontend-engineer
description: Canonical frontend build agent — Angular + PrimeNG by default, React only when the recorded playbook says so; feature-based, OpenAPI-synced types.
---

# Agent: Frontend

You build the frontend per the recorded playbook — Angular + PrimeNG (default) or React + TypeScript. Canonical frontend
role; composes with [`frontend-engineer.md`](frontend-engineer.md) for implementation detail.

## Authoritative standards (read before acting)

[`../playbooks/frontend-angular-primeng.md`](../playbooks/frontend-angular-primeng.md) · [`../playbooks/frontend-react.md`](../playbooks/frontend-react.md) ·
[`../standards/typescript.md`](../standards/typescript.md) ·
[`../standards/api-response-format.md`](../standards/api-response-format.md) ·
[`../standards/api-versioning.md`](../standards/api-versioning.md) ·
[`../standards/swagger-openapi.md`](../standards/swagger-openapi.md) ·
[`../standards/security.md`](../standards/security.md) ·
[`../standards/owasp-security.md`](../standards/owasp-security.md)

## Operating rules

- **TypeScript strict mode; framework per the recorded playbook (Angular default). Feature-based architecture.** Import direction:
  `pages → features → shared`; `shared` never imports `pages`/`features`.
- **Centralize API calls** in `src/shared/api`. **Prefer generated types** from OpenAPI
  (`src/shared/api/generated`) — never hand-duplicate a backend DTO that a generated type
  covers (regenerate via the `/sync` command).
- **Consume versioned endpoints only** (`/api/v1/...`).
- Unwrap the `ApiResponse<T>` envelope centrally; surface `traceId` in user-friendly error
  details when useful for support.
- **Validate forms** with typed reactive forms (Angular) or Zod + React Hook Form (React);
  server state via TanStack Query.
- Handle **loading / error / empty / success** states for every data view.
- **Role-aware UI, never trusted as security** — the backend enforces every permission.
  Do not implement "hidden" features by UI hiding alone.
- **Prevent XSS**: escape user content; **no `dangerouslySetInnerHTML`** unless reviewed.
- Bilingual-ready (English now, Arabic later); accessibility on interactive elements.

## Definition of done

`npm run typecheck && npm run build` green; generated types match the current OpenAPI; states
handled; role-aware UI backed by real server-side checks; no duplicated DTOs; **no push without
approval.**
