# Standard: OWASP Security (2026-grade)

Align to **OWASP Top 10 (2025)**, **OWASP API Security Top 10 (2023)**, and **Microsoft
ASP.NET Core security guidance**. Broken Access Control is the highest risk for this portal.

## Highest risk — Broken Access Control / BOLA / IDOR

- **Enforce role-based AND channel-scoped authorization** on every operation. The 8 BRD roles
  and channel scope are authoritative — see [`security.md`](security.md) and
  [`dotnet-security.md`](dotnet-security.md).
- **Never rely on frontend authorization.** Role-aware UI is UX only; the backend re-checks
  every time.
- **Validate object ownership on every order-form operation.** A Requester may act only on
  orders they own or are a Contributor on; a Focal Point only within their channel. Load the
  resource, then assert the caller is entitled to it — do not trust an id from the client
  (protects against **IDOR / BOLA**, OWASP API #1).
- **Broken Object Property Level Authorization (API #3):** price-list raw values are returned
  only to privileged roles. Enforce by **projecting DTOs per role** so a
  disallowed role's payload cannot structurally contain the value — never by client hiding,
  never by colour-coding alone (BRD §3.1.4–3.1.5, §3.10.2). A test asserts no leak.

## Mapped controls

**OWASP Top 10 (2025)**
- *Broken Access Control* → per-operation role/scope/ownership checks; deny by default.
- *Security Misconfiguration* → security headers, strict CORS, HSTS, Swagger not public in
  prod, no verbose errors (see [`middleware.md`](middleware.md), [`dotnet-security.md`](dotnet-security.md)).
- *Software Supply Chain Failures* → pin dependencies, review transitive packages, no
  unvetted packages; SonarQube + dependency review in the gate.
- *Cryptographic Failures* → HTTPS/TLS only; secrets in Key Vault; hash-chained audit; no
  home-grown crypto.
- *Injection* → parameterized EF Core only; no string-built SQL; validate/encode all input.
- *Insecure Design* → threat-model vendor links, CAD retrieval, exports during design.
- *Authentication Failures* → Entra ID SSO; no local credentials; vendor links single-purpose,
  time-bound, revocable.
- *Software/Data Integrity Failures* → signed vendor tokens; append-only hash-chained audit;
  reviewed migrations.
- *Security Logging & Alerting Failures* → log security events (authn/authz failures, expired/
  revoked link use, config changes) with `traceId`, without leaking secrets/PII/rates.
- *Mishandling Exceptional Conditions* → central error handling, no leakage, correct status
  codes (see [`error-handling.md`](error-handling.md)).

**OWASP API Security Top 10 (2023)**
- #1 BOLA, #2 Broken Auth, #3 Broken Object Property Level Auth, #4 Unrestricted Resource
  Consumption (rate limiting, body-size limits, pagination), #5 Broken Function Level Auth
  (policy per endpoint), #6 Unrestricted Access to Sensitive Business Flows (guard vendor
  invite/submit, completion, CAD retrieval), #7 SSRF (validate/deny outbound URLs; the vendor
  path sends links, it does not fetch arbitrary URLs), #8 Security Misconfiguration, #9
  Improper Inventory Management (versioned, documented APIs — see [`api-versioning.md`](api-versioning.md)),
  #10 Unsafe Consumption of APIs (validate CAD/IdP responses).

## Operational rules

- **Use DTOs. Never bind EF entities directly** from API requests — prevents mass assignment.
- **Validate commands/requests** with FluentValidation (see [`input-validation-sanitization.md`](input-validation-sanitization.md)).
- **Parameterized EF Core queries only.** No raw SQL unless justified, reviewed, and
  parameterized.
- **No secrets in the repo.** Key Vault / secure Azure App Settings only.
- **HTTPS enforced; CORS strict; security headers on.**
- **Limit file/PDF/export endpoints** — authorize, rate-limit, cap size, stream, and never
  include data the caller may not see.
- **Sanitize free-text fields where displayed** (defense in depth against stored XSS).
- **Audit all business-critical actions** (append-only, BRD §3.11).
- **Review OWASP risks during code review** ([`../commands/review.md`](../commands/review.md)),
  and **fix all SonarQube Blocker/Critical/Major before push** ([`sonarqube.md`](sonarqube.md)).

## Related
[`security.md`](security.md) · [`dotnet-security.md`](dotnet-security.md) · [`input-validation-sanitization.md`](input-validation-sanitization.md) · [`error-handling.md`](error-handling.md)
