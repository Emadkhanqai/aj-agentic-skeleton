# Standard: Swagger / OpenAPI

OpenAPI is a first-class deliverable: it documents the API for humans and is the source of
truth for frontend type generation.

## Rules

- **Enable Swagger UI for Development and Test** (and internal Staging if useful). Do **not**
  expose Swagger UI publicly in Production; the OpenAPI JSON may still be generated for the
  build/type-gen pipeline.
- **Document every endpoint:** summary, description, parameters, auth requirement, and every
  response status it can return.
- **Document request and response models** — including the `ApiResponse<T>` envelope
  (see [`api-response-format.md`](api-response-format.md)) and error shapes.
- **Document error responses** (400/401/403/404/409/422/429/500) with their `code` values.
- **Document auth requirements** — add the Entra ID (OAuth2/OIDC bearer) security scheme and
  mark protected endpoints; document the vendor scoped-link scheme separately.
- **Document API versions** as separate OpenAPI groups (`v1`, `v2`) — see
  [`api-versioning.md`](api-versioning.md).
- **Enable XML comments** where they add value: set `<GenerateDocumentationFile>true</GenerateDocumentationFile>`
  and feed the XML into `AddSwaggerGen(c => c.IncludeXmlComments(...))`. Suppress CS1591 only
  for generated/trivial members, not as a blanket.
- **The OpenAPI document must be clean enough for client generation** — every schema named,
  no anonymous/duplicated types, nullability accurate, enums as named strings.

## Frontend type generation

- Frontend generated types come from OpenAPI wherever possible
  (`openapi-typescript` → `frontend/src/shared/api/generated`).
- Never hand-duplicate a backend DTO on the frontend when a generated type exists
  (see [`../workflows/api-change.md`](../workflows/api-change.md) and the `/sync` command).

## Setup checklist

- `AddEndpointsApiExplorer()` + `AddSwaggerGen()`.
- One `SwaggerDoc` per API version via the versioned API explorer group names.
- Security definitions: `oauth2` (Entra ID authority + scopes) and the vendor link scheme.
- `[ProducesResponseType(typeof(ApiResponse<T>), 200)]` and error variants on actions.
- Enable annotations (`Swashbuckle.AspNetCore.Annotations`) if used for richer metadata.

## Related
[`api-versioning.md`](api-versioning.md) · [`api-response-format.md`](api-response-format.md) · [`../commands/sync.md`](../commands/sync.md)
