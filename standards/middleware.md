# Standard: Middleware Pipeline

A clean, ordered, production-grade middleware pipeline. **Order matters** — it is documented
here and reviewed on every backend architecture review, because incorrect order causes
security and authorization bugs. Microsoft explicitly notes middleware order matters, and
**endpoint-specific rate limiting must run after routing** so the endpoint is known.

---

## Canonical order (authoritative)

This is the exact `Program.cs` order. Do not reshuffle without a reviewed reason.

1. **Global Exception Handling** — outermost.
2. **Forwarded Headers** — honor `X-Forwarded-*` from the Azure load balancer/App Service so
   scheme/host/client-IP are correct before HTTPS/HSTS/rate-limit decisions.
3. **HTTPS Redirection.**
4. **HSTS** — non-Development only.
5. **Security Headers.**
6. **Correlation ID / Trace ID.**
7. **Request/Response Logging.**
8. **Routing** (`UseRouting`) — must precede CORS, rate limiting, auth (endpoint metadata).
9. **CORS.**
10. **Rate Limiting** — global + endpoint-specific policies (after routing).
11. **Request Timeout.**
12. **Authentication.**
13. **Authorization.**
14. **Anti-CSRF** — only if cookie-based auth is used.
15. **Validation filters** — action/endpoint filters returning the standard envelope.
16. **Output Caching** — safe GET endpoints only.
17. **Response Compression.**
18. **Endpoints / Controllers** (`MapControllers`).
19. **Health Checks** (`/health/live`, `/health/ready`).

Cross-cutting boundaries that are not ordered middleware but are enforced at the Application
edge: **input validation/sanitization**, **audit logging**, **idempotency**, **concurrency
(ETag/rowversion)**, and the **vendor secure-link** and **CAD machine-to-machine** guards
(applied as endpoint filters/handlers on their specific routes).

---

## 1. Correlation ID Middleware
- Accept `X-Correlation-ID` from trusted callers; **generate one if missing**.
- Return it in response headers.
- Include it in every log scope and in `ApiResponse.traceId` (source:
  `Activity.Current?.Id ?? HttpContext.TraceIdentifier`). See [`observability-tracing.md`](observability-tracing.md).

## 2. Request/Response Logging Middleware
- Log method, path, status code, duration, user id, role, correlation id.
- **Never log** passwords, tokens, secure vendor links, connection strings, or full request
  bodies by default. Never log price-list raw values.

## 3. Security Headers Middleware
Add: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: no-referrer`,
`Permissions-Policy`, `Content-Security-Policy` where applicable, and
`Strict-Transport-Security` (non-Development). Strip `Server`.

## 4. Rate Limiting Middleware
- Stricter limits on: **login/auth callbacks**, **external vendor secure-link endpoints**,
  **PDF/export endpoints**, **CAD integration endpoints**.
- Use endpoint-specific policies (`RequireRateLimiting("policy")`); runs **after routing**.
- Return `429` in the standard `ApiResponse` envelope.

## 5. Request Timeout Middleware
- Timeout policy for long-running requests.
- **Order export/PDF generation gets its own, longer timeout policy.**

## 6. Request Body Size Limit Middleware
- Prevent oversized payloads (tight default).
- **Order import/upload/export endpoints have explicit, per-endpoint limits.**

## 7. CORS Middleware
- Strict allow-list only. **No wildcard origins in staging/production. No wildcard with
  credentials.**

## 8. Global Exception Middleware
- Convert **all** exceptions to the standard `ApiResponse`.
- **Never expose** stack traces or SQL/EF exception details.
- Always include `traceId`. See [`error-handling.md`](error-handling.md).

## 9. Validation Middleware / Filter
- Return validation errors in `ApiResponse.errors` with stable `code` values
  (e.g. `VALIDATION_FAILED`). See [`input-validation-sanitization.md`](input-validation-sanitization.md).

## 10. Anti-XSS Output / Sanitization Boundary
- Sanitize or encode free-text fields when displayed/exported (titles, notes, comments,
  vendor text, disclaimers, templates).
- **Never trust** comments/notes/vendor text. Store raw, encode on output; the frontend also
  escapes (see the loaded frontend playbook).

## 11. Anti-CSRF Standard
- **Required if cookie-based auth is used.**
- Not required for pure bearer-token APIs — but the decision is documented here: this portal
  uses **bearer tokens (Entra ID)**, so CSRF middleware is **off unless cookie auth is
  introduced**. Any cookie use flips this on.

## 12. Authentication + Authorization Middleware
- Backend enforces **role + channel scope** on every operation.
- **Protect against IDOR/BOLA** — validate object ownership after loading the resource.
- **Never trust frontend-only permission checks.** See [`owasp-security.md`](owasp-security.md),
  [`dotnet-security.md`](dotnet-security.md).

## 13. Audit Logging Middleware / Service Boundary
- Audit business actions: **order create/edit/complete; vendor invite/revoke/submit/revision;
  price-list changes; BA configuration changes; CAD linkage.**
- **Append-only** and hash-chained (BRD §3.11). Implemented at the Application/domain boundary
  (the aggregate records entries), not as raw HTTP middleware, so business context is captured.

## 14. Health Check Middleware
- `/health/live`, `/health/ready`, a **database readiness check**, and an **optional downstream
  CAD/email service check**. Used by the Cloud Run health/readiness warmup path (see [`gcp.md`](gcp.md)).

## 15. Response Compression Middleware
- Use for JSON responses where beneficial.
- **Do not compress sensitive responses** if a BREACH-style risk applies (e.g. responses mixing
  secrets/CSRF tokens with attacker-influenced input).

## 16. Output Caching Middleware
- **Safe GET endpoints only.**
- **Never cache user-specific order data** unless explicitly varied by user/role/channel.
- **Never cache vendor secure-link responses.**

## 17. Localization Middleware
- Readiness for **English now, Arabic later**. Culture must be resolved **before**
  validation/messages if/when messages are localized (BRD bilingual-ready).

## 18. API Deprecation Header Middleware
- For old API versions, return `Deprecation` / `Sunset` headers (and
  `api-deprecated-versions`). See [`api-versioning.md`](api-versioning.md).

## 19. Maintenance Mode Middleware
- Optional: admin-controlled downtime during migrations/releases. Returns `503` with a
  maintenance `ApiResponse` while enabled.

## 20. Idempotency Middleware / Filter
- Recommended for critical POSTs: **complete order, vendor submit, CAD linkage confirmation.**
- Honor an `Idempotency-Key` header; store the first result and replay it for retries/
  double-clicks — prevents duplicate submissions and duplicate Reference-ID issuance.

## 21. ETag / Concurrency Headers
- Useful for order edit flows. Emit `ETag`; require `If-Match` on updates.
- **Pair with SQL `rowversion`** (see [`efcore-migrations.md`](efcore-migrations.md)) to prevent
  silent overwrite when two users edit the same Draft; return `412`/`409` on mismatch.

## 22. Secure Link Middleware for External Vendors
- Validate **token hash, expiry, revocation, form scope, and submitted/locked status** on
  every vendor-route request.
- **Never store the raw token** — store a hash; compare hashes.
- Log expired/revoked/invalid access attempts as security events (BRD §3.7.3).

## 23. API Key / Machine-to-Machine Middleware for CAD Integration
- If CAD uses service-to-service access, protect it **separately from user SSO**.
- Use Azure Managed Identity / client-credentials / API key per the final integration decision.
- **Scope CAD access to Order Reference lookup only** — no rate data, no internal content
  (BRD §3.10.2).

## 24. PDF Export Protection
- **Authorize every export.**
- Watermark or metadata-stamp with generated timestamp/user where required.
- **Do not expose price-list raw values in exported PDFs** unless the caller's role allows it
  (role-scoped rendering, same rule as the API).

## 25. Middleware Ordering Documentation & Review Rule
- The canonical order above is the authoritative record.
- **Rule: middleware order must be reviewed during every backend architecture review** —
  incorrect order can cause security or authorization bugs. Endpoint-specific rate limiting
  runs after routing (Microsoft guidance).

---

## Rules

- Middleware contains **no business logic** — cross-cutting only. Business rules live in
  Domain/Application; audit/idempotency/concurrency are enforced at that boundary.
- Keep `AddProblemDetails()` for framework-level faults; ensure `traceId` appears in both the
  `ApiResponse` and `ProblemDetails` outputs.
- Any reorder of the pipeline is a reviewed change with a documented reason.

## Related
[`error-handling.md`](error-handling.md) · [`dotnet-security.md`](dotnet-security.md) · [`owasp-security.md`](owasp-security.md) · [`observability-tracing.md`](observability-tracing.md) · [`api-response-format.md`](api-response-format.md) · [`efcore-migrations.md`](efcore-migrations.md)
