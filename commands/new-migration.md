---
description: Create, review, apply, and script an EF Core migration (MSSQL, migration-based, no Docker).
---

# /new-migration <PascalCaseName>

Create an EF Core migration following the standard.

## Steps
1. Confirm the Domain model + `IEntityTypeConfiguration` changes are in place.
2. Add the migration:
   ```bash
   dotnet ef migrations add <PascalCaseName> \
     --project src/{{ProjectName}}.Infrastructure \
     --startup-project src/{{ProjectName}}.Api \
     --output-dir Migrations
   ```
3. **Review the generated `Up()`/`Down()` by hand** using the checklist in
   [`../templates/ef-migration.md`](../templates/ef-migration.md).
4. Apply locally: `dotnet ef database update ...`.
5. Script it: `dotnet ef migrations script --idempotent ... --output database/migrations/<PascalCaseName>.sql`.
6. Commit migration + snapshot + SQL together. **Do not push without approval.**

Rules: MSSQL only · no `EnsureCreated` · no manual DDL · no Docker.
See [`../workflows/ef-core-migration.md`](../workflows/ef-core-migration.md).
