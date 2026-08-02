# Standard: EF Core + MSSQL Migrations

Schema evolves **only** through EF Core migrations (database per the recorded stack). Complements the existing
[`ef-core.md`](ef-core.md) and [`mssql.md`](mssql.md) with 2026-grade rules.

## Migrations

- **EF Core migrations only** for schema evolution. No `EnsureCreated`, no manual out-of-band
  DDL.
- **Every schema change has a migration.** No drift between the model and the database.
- **Migration name describes business intent** — `AddVendorInviteToOrder`,
  `AddRateCardVersioning`, not `Update1`.
- **Review the generated migration before applying** — inspect Up/Down, data-loss operations,
  index and constraint changes.
- **Never auto-apply migrations on production startup.** Apply as a controlled step in the
  release (see [`../workflows/database-change.md`](../workflows/database-change.md) and
  [`../workflows/release.md`](../workflows/release.md)); generate an idempotent SQL script for
  DBA-reviewed deployment.

## Money & precision

- **Use `decimal` for money — never `float`/`double`.**
- **Configure decimal precision explicitly** — e.g. `decimal(18,4)` for amounts and conversion
  rates. No implicit/default precision.
- **Store both the original-currency amount and the USD equivalent**, plus the **conversion
  rate used at submission** (BRD §3.6.2). USD is the base currency.

## Indexes & constraints

- **Add indexes** for lookup/search/filter columns (owner, status, source, reference id).
- **Unique constraint on the Order Reference ID** (filtered unique index where nullable until
  issued) — network-unique `BG-YYYY-NNNN` (BRD §3.4.2).
- **Concurrency token / `rowversion`** on critical aggregate updates (Order draft edits) to
  prevent silent overwrite; pair with ETag/`If-Match` (see [`middleware.md`](middleware.md)).

## Data lifecycle

- **Soft delete only where the business requires it** — not as a blanket pattern.
- **The audit table is append-only** — never updated or deleted; hash-chained (BRD §3.11).

## Query performance

- **Avoid lazy loading by default** — use explicit `Include`/projection.
- **Avoid N+1 queries** — project to the needed shape; batch includes.
- **`AsNoTracking` for read-only queries.**
- **Paginate large lists** — no unbounded result sets returned to the API.

## Transactions

- **Use transactions for multi-step operations** — order completion + Reference-ID issuance,
  and vendor submission roll-up — so partial state is never persisted. Reference-ID issuance
  uses a serializable transaction (Redis distributed lock added at scale).

## Sensitive reference-data protection

- **Protect price-list values with strict authorization** at the query/projection layer — a
  disallowed role's read model cannot include them (BRD §3.1.4, and [`owasp-security.md`](owasp-security.md)).

## Related
[`ef-core.md`](ef-core.md) · [`mssql.md`](mssql.md) · [`../workflows/database-change.md`](../workflows/database-change.md) · [`dotnet-security.md`](dotnet-security.md)
