# Standard: Entity Framework Core

**Provider:** Microsoft SQL Server **only**. **Approach:** migration-based, always.

## Hard rules

1. **Every schema change is an EF Core migration.** No exceptions.
2. **Never `EnsureCreated()`** in any environment. It bypasses migrations.
3. **No manual/out-of-band DDL** against the database. Schema is defined by migrations
   and only by migrations.
4. **MSSQL provider only** (`Microsoft.EntityFrameworkCore.SqlServer`). No other
   provider in production code paths.
5. **No Docker** for the database. Use a native/local SQL Server or Azure SQL.

## Where things live

- `DbContext` (`EbOrderingDbContext`), entity configurations, and `Migrations/` live
  in `{{ProjectName}}.Infrastructure`.
- Entities live in `{{ProjectName}}.Domain` and stay persistence-ignorant (no EF
  attributes). Mapping is done with `IEntityTypeConfiguration<T>` (Fluent API) in
  Infrastructure.

## Migration workflow

Design-time factory or the Api as startup project. Run from the solution root:

```bash
# Create a migration
dotnet ef migrations add <Name> \
  --project src/{{ProjectName}}.Infrastructure \
  --startup-project src/{{ProjectName}}.Api \
  --output-dir Migrations

# Apply to the local MSSQL database
dotnet ef database update \
  --project src/{{ProjectName}}.Infrastructure \
  --startup-project src/{{ProjectName}}.Api

# Produce an idempotent SQL script for review / deployment
dotnet ef migrations script --idempotent \
  --project src/{{ProjectName}}.Infrastructure \
  --startup-project src/{{ProjectName}}.Api \
  --output database/migrations/<Name>.sql
```

The full step-by-step is in [`../workflows/ef-core-migration.md`](../workflows/ef-core-migration.md).

## Conventions

- Migration names are descriptive and PascalCase: `AddOrderAndOrderLine`,
  `AddRateCardVersioning`.
- Review every generated migration by hand before applying — EF guesses can drop
  columns or rebuild tables.
- Keep the model snapshot in source control.
- Use `decimal(18,4)` for money/rates; `datetime2` for timestamps; explicit max
  lengths on strings. Configure precision in Fluent config, never rely on defaults.
- Seed reference/lookup data via migrations or a dedicated idempotent seeder (see
  `database/seed/`), not ad-hoc inserts.
- Concurrency: use `rowversion` on entities that need optimistic concurrency.
- The **audit log is append-only** (BRD 3.11) — model it so entries are inserted,
  never updated or deleted.

## Related

- [`mssql.md`](mssql.md) · [`clean-architecture.md`](clean-architecture.md) · [`../workflows/ef-core-migration.md`](../workflows/ef-core-migration.md)
