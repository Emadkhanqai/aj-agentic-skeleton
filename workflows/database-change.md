# Workflow: Database Change

> **Model routing (do first):** classify the task and recommend a model — see [`../model-routing.md`](../model-routing.md). Schema change / EF migration → **Sonnet**. Warn the user if the current model is too expensive before continuing.

Any schema change. EF Core migration-based (database per `project-constraints.md`). Extends
[`ef-core-migration.md`](ef-core-migration.md) with the 2026-grade rules.

## 1. Model the change
- Adjust Domain entities / EF configuration. Money is `decimal` with explicit precision; store
  original + USD + conversion rate. Add a `rowversion` concurrency token on critical aggregates.
  See [`../standards/efcore-migrations.md`](../standards/efcore-migrations.md).

## 2. Create the migration
```bash
export PATH="$PATH:$HOME/.dotnet/tools"
dotnet ef migrations add <BusinessIntentName> \
  --project backend/src/{{ProjectName}}.Infrastructure \
  --startup-project backend/src/{{ProjectName}}.Api \
  --output-dir Migrations
```
- **Name describes business intent** (`AddVendorInviteToOrder`), not `Update1`.

## 3. Review the generated migration
- Inspect Up/Down; check for **data loss**, index/constraint changes, and correct precision.
- Confirm indexes on lookup/filter columns and the **filtered unique index on Reference ID**.
- Confirm the **audit table stays append-only** (no update/delete paths).

## 4. Produce a deployable script
```bash
dotnet ef migrations script --idempotent \
  --project backend/src/{{ProjectName}}.Infrastructure \
  --startup-project backend/src/{{ProjectName}}.Api \
  --output database/migrations/<BusinessIntentName>.sql
```
- **Never auto-apply migrations on production startup** — the script is applied as a controlled,
  DBA-reviewed release step ([`release.md`](release.md)).

## 5. Test
- Build; run unit + architecture tests. Where a DB is reachable, run DB-backed integration
  tests (cloud dev). Use transactions for multi-step operations (completion + Ref-ID issuance,
  vendor roll-up).

## 6. Review & gate
- `/review` then the pre-push quality gate. **No push without explicit approval.**
