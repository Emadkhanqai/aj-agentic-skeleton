# Standard: Input Validation & Sanitization

Validate at the boundary, before any domain or persistence work. Sanitize free text where it
will be displayed. Never trust the client.

## Validation

- **Every command/request is validated with FluentValidation** before the use case runs. An
  invalid input never reaches the domain or the database.
- Validation lives in the **Application layer** (`AbstractValidator<TCommand>`), not in
  controllers and not in the domain (the domain still guards its own invariants as a last line).
- **Fail fast, fail specific:** return 400 with per-field messages in `errors[]` and
  `code = VALIDATION_FAILED` (see [`error-handling.md`](error-handling.md)).
- **Whitelist, don't blacklist.** Constrain types, lengths, ranges, formats, and allowed sets:
  - Qty / Rate / Metric → **positive integers only** (BRD §3.6.1).
  - Currency → known ISO set; Conversion Rate → positive decimal (BRD §3.6.2).
  - Email (vendor invite, contributor) → format-validated before dispatch (BRD §3.7.2).
  - Source / Sub-Source / cost codes → must exist in BA-managed reference data.
  - Reference ID lookups → match the `BG-YYYY-NNNN` shape before querying.
- **Mass-assignment safe:** requests are DTOs mapped explicitly to commands; server-owned
  fields (Id, Status, ReferenceId, OwnerId, timestamps, audit) are never bound from the client.

## Sanitization

- **Sanitize/encode free-text fields where displayed** (titles, notes, comments, vendor notes,
  disclaimers, notification templates) as defense-in-depth against stored XSS. Store raw,
  encode on output; the frontend also escapes (see [`../standards/react.md`](react.md)).
- Reject or neutralize control characters and oversized payloads.
- Treat uploaded/exported content boundaries carefully (see export rules in
  [`owasp-security.md`](owasp-security.md)).

## Boundary placement

- Validation/sanitization is a **pipeline boundary** concern: it sits at the Application entry,
  enforced before domain logic (see [`middleware.md`](middleware.md)).
- The domain re-checks its invariants regardless (positive line values, completion gating,
  lifecycle locks) — validation is not a substitute for domain guards.

## Related
[`error-handling.md`](error-handling.md) · [`owasp-security.md`](owasp-security.md) · [`dotnet-security.md`](dotnet-security.md) · [`api-response-format.md`](api-response-format.md)
