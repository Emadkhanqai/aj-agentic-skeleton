# Workflow: Feature Development

> **Model routing (do first):** classify the task and recommend a model — see [`../model-routing.md`](../model-routing.md). Feature *implementation* / tests → **Sonnet**; up-front *architecture* of the feature → **Opus/Fable**. Warn the user if the current model is too expensive before continuing.

End-to-end flow for building a feature across the stack.

## 1. Understand & plan
- Read the relevant BRD section(s) in `/docs`.
- Read the applicable [`../standards/`](../standards/) files.
- Identify affected layers (Domain/Application/Infrastructure/Contracts/Api,
  and frontend features/shared).

## 2. Branch
- `git checkout -b feature/<short-desc>`. Never work on `main` directly.

## 3. Backend (if applicable)
1. Model/adjust **Domain** entities & invariants (persistence-ignorant).
2. Add **Application** use cases (commands/queries + handlers), ports, FluentValidation.
3. Implement **Infrastructure** (EF config, repositories). Schema change → **EF Core
   migration** (see [`ef-core-migration.md`](ef-core-migration.md)).
4. Add **Contracts** DTOs; wire thin **Api** controllers + ProblemDetails.
5. Tests: Unit + Integration + Architecture.

## 4. Sync contracts
- Ensure Swagger/OpenAPI reflects the new DTOs.
- Regenerate frontend types into `src/shared/api/generated`.

## 5. Frontend (if applicable)
1. Add feature module under `src/features/<feature>`.
2. Centralised API calls via `src/shared/api` using generated types.
3. Page composition in `src/pages`. Respect import direction.
4. i18n strings, accessibility, tests.

## 6. Verify locally
- `dotnet build && dotnet test`, `npm run typecheck && npm run build`.

## 7. Pre-push gate
- Run [`pre-push-quality-gate.md`](pre-push-quality-gate.md). Fix all
  Blocker/Critical/Major. **Do not push without explicit approval.**
