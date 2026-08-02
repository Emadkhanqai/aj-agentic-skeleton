# Template: EF Core Migration checklist

Use with [`../workflows/ef-core-migration.md`](../workflows/ef-core-migration.md).

```bash
dotnet ef migrations add <PascalCaseName> \
  --project src/{{ProjectName}}.Infrastructure \
  --startup-project src/{{ProjectName}}.Api \
  --output-dir Migrations
```

Before applying, verify the generated `Up()`/`Down()`:

- [ ] No unintended column drops / table rebuilds.
- [ ] Money & rates → `decimal(18,4)`; percentages → `decimal(9,4)`.
- [ ] Timestamps → `datetime2`, stored UTC.
- [ ] Strings → `nvarchar` with explicit max length (Unicode for Arabic).
- [ ] Order Reference ID → unique index.
- [ ] No cascade delete that could remove audit history.
- [ ] `Down()` cleanly reverses `Up()`.

Then:

```bash
dotnet ef database update --project src/{{ProjectName}}.Infrastructure --startup-project src/{{ProjectName}}.Api
dotnet ef migrations script --idempotent \
  --project src/{{ProjectName}}.Infrastructure --startup-project src/{{ProjectName}}.Api \
  --output database/migrations/<PascalCaseName>.sql
```

Database per `project-constraints.md` · migration-based · no `EnsureCreated`.
```
