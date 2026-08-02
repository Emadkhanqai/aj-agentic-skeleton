# Standard: API Design

**Style:** RESTful HTTP JSON API, ASP.NET Core. Contracts shared with the frontend via
OpenAPI.

## Contracts & DTOs

- All request/response bodies are **DTOs in `{{ProjectName}}.Contracts`** — pure data, no
  business logic, no domain or EF types.
- The API's **OpenAPI/Swagger** document is the single source of truth for the
  frontend. The frontend generates its types from it into
  `src/shared/api/generated/` — **no hand-duplicated models** (see the loaded frontend playbook).
- Swagger UI is enabled at least in Development for frontend sync.

## Errors — ProblemDetails (RFC 7807)

- All error responses use **`ProblemDetails`** / `ValidationProblemDetails`.
- Validation failures (FluentValidation) → `400` with a `ValidationProblemDetails`
  listing field errors.
- Map domain/application failures to appropriate status codes via middleware; never
  leak stack traces or internal messages to clients.
- Include a stable `type`/`title` and a `traceId` for correlation.

## Conventions

- Resource-oriented routes: `/api/orders`, `/api/orders/{id}`,
  `/api/orders/{id}/lines`, `/api/price-lists`, etc.
- Verbs via HTTP methods; use sub-resources/commands for lifecycle actions
  (`POST /api/orders/{id}/complete`).
- Plural nouns, kebab-case paths, camelCase JSON.
- Pagination, filtering, and sorting via query params; return total counts.
- Versioning via URL segment or header when needed (`/api/v1/...`).
- Idempotency for completion/issuance actions (Order Ref ID issued exactly once).

## Authorization at the boundary

- Every endpoint declares its required role/scope. Authorization is enforced
  server-side. Price-list raw values are filtered per-role **before** serialization
  (see [`security.md`](security.md)).

## Documentation

- XML doc comments feed Swagger. Each endpoint documents its statuses, including the
  ProblemDetails error shapes.

## Related

- [`clean-architecture.md`](clean-architecture.md) · [`dotnet.md`](dotnet.md) · [`security.md`](security.md) · [`../playbooks/frontend-angular-primeng.md`](../playbooks/frontend-angular-primeng.md)
