# Standard: API Versioning

All public APIs are versioned. Contracts never break silently.

## Rules

- **Every public API endpoint is versioned.** No unversioned public route ships.
- **URL-based versioning is the default:**
  ```
  /api/v1/order-forms
  /api/v1/sources
  /api/v1/vendors
  /api/v1/price-lists
  ```
- **Breaking changes go to a new major version** (`/api/v2/...`). A breaking change is any
  change that could make an existing, compliant client fail: removing/renaming a field,
  tightening validation, changing a type, changing status-code semantics, or changing auth.
- **Never break an existing contract silently.** Additive, backward-compatible changes
  (new optional field, new endpoint) may stay within the current version.
- **Swagger/OpenAPI exposes versioned API groups** — one document group per version
  (`v1`, `v2`), so clients and the frontend generator target a specific version.
- **The frontend consumes versioned endpoints only.** No calls to unversioned paths.
- **Deprecation, not deletion:** a superseded version is marked deprecated in OpenAPI
  (`deprecated: true`) and kept for an agreed window before removal, announced via
  [`../workflows/api-change.md`](../workflows/api-change.md).

## Implementation (ASP.NET Core)

- Use `Asp.Versioning.Mvc` + `Asp.Versioning.Mvc.ApiExplorer`.
- Controllers declare their version and route:
  ```csharp
  [ApiController]
  [ApiVersion("1.0")]
  [Route("api/v{version:apiVersion}/order-forms")]
  public sealed class OrderFormsController : ControllerBase { /* ... */ }
  ```
- Configure `AddApiVersioning(o => { o.DefaultApiVersion = new ApiVersion(1,0); o.ReportApiVersions = true; })`
  and `AddApiExplorer(o => { o.GroupNameFormat = "'v'VVV"; o.SubstituteApiVersionInUrl = true; })`.
- `ReportApiVersions = true` emits `api-supported-versions` / `api-deprecated-versions` headers.

## {{PROJECT_NAME}} specifics

- Reference-ID resolution for the CAD Portal (`GET /api/v1/order-forms/by-reference/{referenceId}`)
  is a **published integration contract** — treat any change to it as breaking (bump version,
  coordinate with the MEP/CAD team per BRD §3.10).
- Resource names are plural, kebab-case: `order-forms`, `price-lists`, `sources`, `vendors`.

## Related
[`api-response-format.md`](api-response-format.md) · [`swagger-openapi.md`](swagger-openapi.md) · [`../workflows/api-change.md`](../workflows/api-change.md)
