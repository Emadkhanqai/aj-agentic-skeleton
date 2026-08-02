# Standard: Security

Security requirements are driven by the BRD and by baseline enterprise practice.

## Authentication & identity

- **Internal users:** corporate SSO via Entra ID (Azure AD). The portal does **not**
  store internal credentials (BRD 3.2.1). No SSO session → no access beyond sign-in.
- **External vendors:** never SSO users. Access is a **single-purpose, time-bound,
  revocable secure link** scoped to exactly one Order Form (BRD 3.7.3). In
  production this is a signed, server-validated token — not a guessable URL. Expired
  or revoked links grant nothing and the attempt is logged.
- **Roles:** exactly one system role per user, combined with channel/entity scope
  (BRD 3.3). Permissions enforced **server-side**, never trusted from the client.

## Authorization — critical BRD constraints

- **Price-list raw values** are visible only to BA Admin, BA Operator, BA Manager, and
  DG. They must **never** be returned to Requester, Focal Point, DOP, MD/ED, external
  vendors, or across the CAD interface (BRD 3.1.4, 3.1.5, 3.10.2). Enforce this in the
  **API/Application layer** — client-side hiding is not sufficient and is treated as a
  vulnerability. A test must assert the API never leaks raw rates to disallowed roles.
- Validation **indicators** (within/below/above) may go to indicator-eligible roles but
  must never encode the underlying value (not even via colour alone).

## Secrets & data

- No secrets in source. Key Vault + Managed Identity in Azure; `user-secrets` locally.
- All text stored as Unicode (`nvarchar`) for bilingual support.
- Timestamps in UTC.

## API & transport

- HTTPS only. HSTS in production.
- Errors as ProblemDetails **without** leaking stack traces or internal detail
  (see [`api-design.md`](api-design.md)).
- Input validated server-side (FluentValidation); never trust client input.
- Parameterised queries only (EF Core handles this) — no string-built SQL.

## Audit

- Append-only audit log of every Order Form action, including external-vendor
  activity, with actor, timestamp, action type, and prior→new values (BRD 3.11).
  Audit entries are never updated or deleted.

## SonarQube

- Security Hotspots and vulnerabilities surfaced by SonarQube at Blocker/Critical/
  Major severity **block the push** (see [`sonarqube.md`](sonarqube.md)).

## Related

- [`api-design.md`](api-design.md) · [`gcp.md`](gcp.md) · [`sonarqube.md`](sonarqube.md)
