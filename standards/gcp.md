# Standard: Google Cloud

**Hosting target for the {{PROJECT_NAME}}.** Supersedes `azure.md` (archived at
`docs/archive/azure-pre-gcp-pivot/`) — the platform pivoted to Google Cloud 2026-07-14, and
`USP_Google_Cloud_Architecture_Context.md` is the authoritative ecosystem context. Read that
document before making database, backend, frontend, integration, security, testing, deployment,
or infrastructure decisions in this repo.

## Services (baseline)

| Concern | Google Cloud service |
|---|---|
| API hosting | **Cloud Run** (containers, not code-deploy — this is the one hard architectural break from the old Azure App Service baseline) |
| API gateway | **Apigee** — authN enforcement, token validation, routing, rate limiting, request correlation; not a substitute for domain authorization, which the portal API must still enforce server-side |
| Frontend hosting | Cloud Run (containerized) or an equivalent static hosting target — no code-deploy assumption |
| Database | **Google Cloud SQL for SQL Server** (MSSQL — see [`mssql.md`](mssql.md); connection-string shape is already platform-agnostic, no code change needed to point at a real instance) |
| Cache | **Memorystore for Redis** (reference/price-list cache, session/coordination — `IDistributedCache` abstraction already in place, cache-aside pattern already correct) |
| Object storage | **Google Cloud Storage** (PDFs, Excel, documents — behind the existing `IDocumentStore` port; `LocalFileDocumentStore` is the interim local implementation, not the target) |
| Messaging | **Google Cloud Pub/Sub** (integration events — behind the existing `IIntegrationEventPublisher` port; `LoggingIntegrationEventPublisher` is a stub, not the target) |
| Secrets | **Secret Manager** — no real secrets in appsettings, ever; local dev secrets in `appsettings.Development.json` (gitignored) are fine for local-only use |
| Identity | **Google Cloud Identity (OIDC)** for authentication + **Keycloak** for authorization (roles, channel scope, vendor-link token minting) — this is a confirmed, standing product-owner decision; do not revert to Entra ID even though some external reference docs describe Entra ID as the corporate IdP for this ecosystem (see the deviation note in `docs/execution/final-delta-ledger.md`) |
| Workflow orchestration | Cloud Workflows / Cloud Tasks — not yet needed beyond the existing outbox/inbox pattern; defer |
| Observability | Cloud Logging, Cloud Monitoring, Cloud Trace |
| Analytics | BigQuery + Cloud Storage data lake, read by Power BI — not this portal's responsibility beyond emitting well-formed Pub/Sub events |

## Rules

- No secrets in source or plain-text app settings for non-dev environments — use Secret Manager
  references and workload/service identities.
- Prefer service identities over embedded credentials wherever Cloud Run/Cloud SQL support it.
- Keep configuration keys at parity across Development and Production.
- ~~Do not build a Reference Data Service client or `ReferenceSyncRuns` table — {{PROJECT_NAME}} is the
  system of record for its own reference data (`docs/DECISIONS.md`, 2026-07-16), not a projection
  of an external service, despite `USP_Google_Cloud_Architecture_Context.md` §7.2 describing a
  Reference Data Service model. This is a confirmed, documented deviation for this project only.~~
  **CORRECTED 2026-07-17 (later same day):** the cited `DECISIONS.md` 2026-07-16 entry was never
  product-owner-approved — see `docs/DECISIONS.md`'s retraction entry for the forensic finding.
  **`USP_Google_Cloud_Architecture_Context.md` §7.2 was correct all along.** The corrected rule:
  **do** treat the external Reference Data Service as authoritative for Sources, SubSources,
  ChartNodes, CostFormats, Currencies, MainOutlines, SapGlAccounts, SubSourceOutlineFlags, Regions,
  RegionCountries, RateCards, RateEntries. {{PROJECT_NAME}} keeps a local SQL projection (via
  `IReferenceDataServiceClient`/`ReferenceDataProjectionSyncService`) + a Redis/Memorystore cache
  (`CachingReferenceCatalog`) of that data, and a `ReferenceSyncRuns` ledger recording sync-run
  outcomes — all now built on `fix/reference-data-ownership-correction` (Tasks A/B, migration
  `20260717142438_AddReferenceDataProjectionProvenanceAndSyncLedger`). Admin write endpoints over
  these 12 tables return `409` via `ReferenceDataOwnershipGuard` (Task D) — reads are unaffected.
  See `docs/database/data-ownership-matrix.md` and `docs/database/integration-event-map.md` for the
  full as-built picture.
- When a GCP adapter has no live credentials/instance in the current environment, build the
  adapter and its contract tests anyway, behind the existing port; classify live proof as
  `BlockedExternalInfrastructure`, never as "not needed."

See [`USP_Google_Cloud_Architecture_Context.md`](../../docs/architecture/USP_Google_Cloud_Architecture_Context.md)
and [`docs/execution/final-delta-ledger.md`](../../docs/execution/final-delta-ledger.md) §4 for the
current adapter-by-adapter build status.
