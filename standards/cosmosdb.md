# Standard: Azure Cosmos DB (conditional — load only if the project uses Cosmos)

Loaded when `/architect` records Cosmos DB in the stack. Skip entirely otherwise. Cosmos is
not "NoSQL SQL Server" — modeling, consistency, and cost work completely differently, and the
mistakes are expensive (literally: they bill in RUs).

## When Cosmos is the right call (and when it isn't)

- Right: high-scale document/event workloads, globally distributed reads, flexible-schema
  ingestion (feeds, telemetry, AI/vector pipelines), change-feed-driven processing.
- Wrong: relational data with joins/reporting, strong multi-entity transactions, or "we might
  need scale later" — that's MSSQL's job. Dual-store designs (MSSQL primary + Cosmos for a
  specific workload, synced via messaging) are legitimate and common.

## Partitioning — the decision you cannot cheaply undo

- Choose the partition key for the **dominant query pattern**; every hot read should be
  single-partition. Cross-partition queries are a design smell — log and review any.
- High-cardinality keys; avoid hot partitions (a single tenant/day as key = throttling). Use
  hierarchical partition keys or synthetic keys (`tenantId_yyyyMM`) when one dimension is too
  coarse. 20GB logical-partition limit is a hard wall — design for it on day one.

## Modeling

- Model **by access pattern, not by normalization**: embed what is read together; reference
  what grows unbounded or is shared. Documents have a 2MB hard cap — unbounded arrays inside a
  document are a bug.
- Every document carries `type` and a version/schema field; readers tolerate old versions.
- **Concurrency: ETag everywhere.** All replaces use `If-Match`; handle 412/409 with retry or
  conflict flow mapped to the standard 409 envelope. Never blind-overwrite.
- IDs: `id` unique *per partition* — uniqueness beyond that is your design's job.

## Cost & performance (RUs are the currency)

- Log RU charge per operation in dev/test; alert on regressions. Point reads
  (`ReadItemAsync(id, pk)`) ≈1 RU — prefer them over queries wherever possible.
- **Indexing policy is explicit:** exclude paths by default for write-heavy containers; include
  only queried paths; composite indexes for multi-field ORDER BY.
- Bounded page sizes (`MaxItemCount`); always drain continuation tokens; never `ToList()` an
  unbounded query.
- Autoscale over manual provisioning unless load is provably flat; watch 429s and set sane
  retry policy on the client (single `CosmosClient` singleton, Direct mode).

## Consistency & processing

- Default **Session** consistency; deviate only with a written justification (ADR).
- **Change feed** is the integration backbone — project/sync/index from it instead of dual
  writes. Dual writes without an outbox are a data-corruption bug.
- Multi-document invariants: same-partition transactional batch, or saga via messaging —
  cross-partition transactions do not exist.

## EF Core Cosmos provider — use with care

The provider trails the SDK and has real gaps (query translation limits, no bulk, migration
concepts don't apply). Rule: **SDK-first for anything hot or complex**; the EF provider only
for simple aggregate persistence, pinned and integration-tested against the emulator — its
generated queries must be inspected, not trusted.

Related: `efcore-migrations.md` (concurrency parallels) · `observability-tracing.md` (RU + 429 telemetry)
