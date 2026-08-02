---
description: Review the current diff against architecture, standards, BRD correctness, OWASP, middleware order, and API contracts. Reports findings; does not push.
---

# /review

Review the working changes before proposing a push.

## Do this
1. `git diff` (and `git diff --staged`) to see the change.
2. Walk the checklist in [`../workflows/code-review.md`](../workflows/code-review.md):
   architecture boundaries, standards, BRD correctness, security (**price-list leakage!**),
   forbidden patterns (Docker / non-MSSQL / `EnsureCreated` / duplicated DTOs), tests.
3. Cross-check against the relevant [`../standards/`](../standards/) files, specifically:
   - **Access control / OWASP** — role + channel scope + object ownership (IDOR/BOLA); price-list
     raw values only to allowed roles via role-scoped DTO projection
     ([`../standards/owasp-security.md`](../standards/owasp-security.md),
     [`../standards/security.md`](../standards/security.md)).
   - **API** — versioned routes, `ApiResponse<T>` envelope with `traceId`, OpenAPI documented,
     no EF entity binding, no silent contract break
     ([`../standards/api-versioning.md`](../standards/api-versioning.md),
     [`../standards/api-response-format.md`](../standards/api-response-format.md)).
   - **Middleware order** — reviewed on every backend architecture review; wrong order causes
     security/authorization bugs ([`../standards/middleware.md`](../standards/middleware.md)).
   - **Error handling** — no stack/SQL/internal leakage; correct status + `code`
     ([`../standards/error-handling.md`](../standards/error-handling.md)).
   - **EF/DB** — migration present + business-named + reviewed; `decimal` money; append-only
     audit; `AsNoTracking`/pagination; concurrency token
     ([`../standards/efcore-migrations.md`](../standards/efcore-migrations.md)).

## Output
Prioritized findings, most severe first, each with `file:line`, marked blocker vs nit.
Do not approve a push while any correctness/security/architecture blocker is open.
The final Blocker/Critical/Major decision still defers to the SonarQube gate
([`quality-gate.md`](quality-gate.md)).
