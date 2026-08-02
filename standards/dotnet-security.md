# Standard: .NET / ASP.NET Core Security

Microsoft-aligned hardening for the backend. Complements [`owasp-security.md`](owasp-security.md)
and [`security.md`](security.md).

## Identity: authentication and authorization are separate concerns

- **Authentication — internal staff: your SSO IdP** (OIDC — e.g. Entra ID, Okta). Validate the IdP JWT with
  `Microsoft.Identity.Web` / JwtBearer against the IdP authority + audience. The portal holds
  **no local credentials** (BRD §3.2.1). De-provisioning at the IdP removes access on the next
  session refresh.
- **Authorization — everyone: a dedicated authorization source** (e.g. Keycloak, app policies) is the source of truth for roles, resource
  scope, and permissions, and it mints the **scoped, time-bound, revocable** tokens behind
  external-vendor links. External parties never receive internal SSO accounts.
- Map roles/permissions into ASP.NET **authorization policies**; cache permission
  lookups (Redis) with a short TTL. Enforce **deny-by-default**.

## Authorization enforcement

- Policy per endpoint (function-level authorization). No anonymous business endpoint.
- **Object-ownership / channel-scope check** inside the handler after loading the resource —
  never trust the client's id (IDOR/BOLA).
- **Role-scoped DTO projection** for price-list values; a disallowed role's response type cannot
  carry the value. Covered by an architecture/integration test.

## Input & data safety

- **DTOs only at the boundary; never bind EF entities** (prevents mass assignment / over-posting).
- **FluentValidation** on every command/request (see [`input-validation-sanitization.md`](input-validation-sanitization.md)).
- **Parameterized EF Core only.** No `FromSqlRaw` with interpolation; if raw SQL is truly
  needed, use `FromSqlInterpolated`/parameters and justify it in review.
- Money is `decimal` with explicit precision; never `float`/`double` (see [`efcore-migrations.md`](efcore-migrations.md)).

## Transport & configuration

- **HTTPS only; HSTS** in non-Development.
- **Security headers** via middleware: `X-Content-Type-Options: nosniff`,
  `X-Frame-Options: DENY`, `Referrer-Policy: no-referrer`, strict `Content-Security-Policy`,
  `Permissions-Policy`; strip `Server`.
- **CORS**: explicit per-environment origin allow-list; never `*` with credentials.
- **Rate limiting** and **request body-size limits** (see [`middleware.md`](middleware.md)).
- **Antiforgery** where cookie auth applies; bearer APIs are CSRF-resistant but must still set
  `SameSite`/secure cookies if any are used.

## Secrets

- **No secrets in source or committed config.** Azure Key Vault + Managed Identity in cloud;
  `dotnet user-secrets` locally. Never log secrets, connection strings, or tokens.

## CAD machine-to-machine auth — PENDING INFRA

The service-to-service auth method for CAD integration (Azure Managed Identity vs
client-credentials vs API key) is **NOT yet confirmed by the INFRA team** (as of 2026-07-08).
Hold it behind `ICadIntegrationGateway`; keep CAD access scoped to Order Reference lookup only
(no rate data, BRD §3.10.2). Do not hard-wire a choice until INFRA confirms.

## Vendor secure link

- Signed, server-validated, single-purpose token scoped to exactly one Order Form; expiring
  and revocable. An expired/revoked link grants nothing and the attempt is audited (BRD §3.7.3).

## Related
[`owasp-security.md`](owasp-security.md) · [`security.md`](security.md) · [`middleware.md`](middleware.md) · [`gcp.md`](gcp.md)
