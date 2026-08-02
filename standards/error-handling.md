# Standard: Error Handling

Errors are handled centrally, returned in the standard envelope, and never leak internals.

## Principles

- **Central handling.** A global exception-handling middleware is the single place that turns
  an unhandled exception into a client response. Controllers do not build error envelopes by
  hand (see [`middleware.md`](middleware.md)).
- **Standard envelope.** Every error returns `ApiResponse`/`ApiResponse<T>` with `success=false`,
  a human `message`, a machine-readable `code`, optional `errors[]`, `statusCode`, and
  `traceId` (see [`api-response-format.md`](api-response-format.md)).
- **No leakage.** Never return stack traces, SQL errors, EF exception text, or internal
  exception messages to the client. In Production the client gets a generic message + `code`
  + `traceId`; the full detail is logged with that same `traceId`.

## Exception → response mapping

| Condition | Status | `code` (example) |
|---|---|---|
| FluentValidation failure | 400 | `VALIDATION_FAILED` (messages in `errors[]`) |
| Unauthenticated | 401 | `UNAUTHENTICATED` |
| Forbidden (role/scope/ownership) | 403 | `FORBIDDEN` |
| Resource not found | 404 | `NOT_FOUND` (e.g. `BUDGET_NOT_FOUND`) |
| Domain rule / invalid state | 409 or 422 | e.g. `BUDGET_LOCKED`, `COMPLETION_BLOCKED` |
| Rate limited | 429 | `RATE_LIMITED` |
| Unexpected | 500 | `INTERNAL_ERROR` (generic message only) |

- **Domain exceptions** (`DomainException`) map to 409/422 with a specific `code` and the
  domain message (these are safe, business-meaningful messages — not internal detail).
- **Validation exceptions** map to 400 with per-field messages in `errors[]`.
- Distinguish "expected" business failures (safe to surface) from "unexpected" faults
  (generic message + logged detail).

## Logging & telemetry

- Log every handled 5xx and every unexpected exception at `Error` with the `traceId`, actor
  id/role, route, and correlation id. Do not log price-list values, secrets, or full PII.
- Business-rule 4xx are logged at `Information`/`Warning` — they are not system faults.
- Correlate logs, traces, and the client `traceId` (see [`observability-tracing.md`](observability-tracing.md)).

## Rules

- No empty catch blocks; no swallowing exceptions silently.
- No `catch (Exception) { return generic 200 }` — surface the correct status.
- Cancellation (`OperationCanceledException` from a client abort) is not an error — do not log
  it as one.
- Security-relevant failures (auth, forbidden, expired/revoked vendor link) are audited/logged
  as security events without leaking sensitive data (see [`owasp-security.md`](owasp-security.md)).

## Related
[`api-response-format.md`](api-response-format.md) · [`middleware.md`](middleware.md) · [`observability-tracing.md`](observability-tracing.md) · [`security.md`](security.md)
