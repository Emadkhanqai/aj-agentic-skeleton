# Standard: SQL Server (MSSQL) — Code-First Pro Practices

Loaded when `/architect` records MSSQL as the relational store. All schema comes from EF Core
code-first migrations (`standards/efcore-migrations.md`); this file covers the SQL Server-
specific decisions that code-first makes easy to get wrong.

## Environments & auth

- Local dev: SQL Server Developer/Express, LocalDB, or a container per the repo's
  `project-constraints.md`. Cloud: Azure SQL / managed SQL per constraints.
- Connection strings are configuration, never code: `dotnet user-secrets` locally, Key Vault +
  Managed Identity in cloud. Prefer AAD/Managed Identity auth over SQL logins.

## Modeling (code-first configuration, not defaults)

- **Never ship EF's guessed types.** Every string gets `HasMaxLength()` (default is
  `nvarchar(max)` — kills index/memory-grant efficiency); every decimal gets
  `HasPrecision()` (default truncates silently). Enforce via a model-finalizing convention
  that *fails* on unconfigured strings/decimals.
- Money/rates: `decimal(18,4)` · percentages: `decimal(9,4)` · UTC timestamps: `datetime2`
  (never `datetime`) · text: `nvarchar` (Unicode — multilingual-safe from day one).
- **Keys:** `int`/`bigint` IDENTITY for internal surrogate keys. If GUIDs are required, use
  **sequential** GUIDs (`NEWSEQUENTIALID()` / `Guid.CreateVersion7()`) for clustered keys —
  random GUID clustered PKs fragment the index badly.
- Durable business keys (e.g. `ORD-YYYY-NNNN`) are `nvarchar` with a **unique index**,
  separate from the surrogate PK.
- **Concurrency:** `rowversion` token on every aggregate root
  (`IsRowVersion()`); handle `DbUpdateConcurrencyException` → 409 with the standard envelope.
- Enums persist as `int` by default; string conversion only with a documented reason + length.

## Indexing (declare in the model, review in the migration)

- Every FK gets an explicit index (EF adds most — verify in the generated migration, don't trust).
- Hot query paths get **covering indexes** with `IncludeProperties()`; filtered indexes
  (`HasFilter("[IsDeleted] = 0")`) for soft-delete tables.
- Unique constraints are business rules — model them (`IsUnique()`), never enforce only in C#.
- Review every migration's generated SQL (`dotnet ef migrations script`) for: missing indexes,
  unintended data loss, implicit cascade deletes that could destroy audit history.

## Query performance rules

- `AsNoTracking()` for every read path; projections (`Select` into DTOs) over entity loads.
- **No N+1:** eager-load deliberately or project; `AsSplitQuery()` when a single JOIN explodes
  rows (cartesian bloat).
- Watch parameter sniffing on skewed data; `OPTION (RECOMPILE)`/query hints only with a
  measured justification recorded in the PR.
- Pagination is keyset (`WHERE key > @last ORDER BY key`) for large sets; `Skip/Take` only for
  small, bounded pages.
- Bulk operations use `ExecuteUpdate`/`ExecuteDelete` — never load-modify-save loops.
- Prove it: any query touching >10K rows gets an execution-plan check before merge.

## Operational

- All timestamps UTC in the database; convert at the edge.
- Soft deletes via global query filters where audit/history matters; hard deletes need approval.
- No implicit cascade deletes on audit/history tables — configure `DeleteBehavior.Restrict`.

Related: `efcore-migrations.md` · `ef-core.md` · `security.md`
