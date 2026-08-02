# Workflow: EF Core Migration

> **Model routing (do first):** classify the task and recommend a model — see [`../model-routing.md`](../model-routing.md). EF Core migration authoring → **Sonnet**. Warn the user if the current model is too expensive before continuing.

Every schema change ships as a migration. **MSSQL only. No Docker. No `EnsureCreated`.**

## 1. Change the model
- Edit Domain entities and their `IEntityTypeConfiguration<T>` in Infrastructure.

## 2. Add the migration
```bash
dotnet ef migrations add <PascalCaseName> \
  --project src/{{ProjectName}}.Infrastructure \
  --startup-project src/{{ProjectName}}.Api \
  --output-dir Migrations
```

## 3. Review the generated migration by hand
- Confirm no unintended column drops or table rebuilds.
- Confirm money/rate columns are `decimal(18,4)`, timestamps `datetime2`, strings have
  explicit lengths, and the Order Reference ID has a unique index.

## 4. Apply locally
```bash
dotnet ef database update \
  --project src/{{ProjectName}}.Infrastructure \
  --startup-project src/{{ProjectName}}.Api
```

## 5. Produce a reviewable SQL script (for /database + deployment)
```bash
dotnet ef migrations script --idempotent \
  --project src/{{ProjectName}}.Infrastructure \
  --startup-project src/{{ProjectName}}.Api \
  --output database/migrations/<PascalCaseName>.sql
```

## 6. Commit
- Migration code + model snapshot + the generated SQL script, together, on a branch.
- Do **not** push without explicit approval and a green quality gate.

## Notes
- Seed reference data via idempotent seeders under `database/seed/`, not ad-hoc SQL.
- The audit table is append-only — never author a migration that enables updates/
  deletes on it without an explicit, approved reason.
