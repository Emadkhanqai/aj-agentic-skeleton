# Workflow: Release

> **Model routing (do first):** classify the task and recommend a model — see [`../model-routing.md`](../model-routing.md). Release *mechanics/docs* → **Sonnet**; go/no-go *risk call* → **Opus/Fable**. Warn the user if the current model is too expensive before continuing.

Shipping a change to an environment. Nothing here bypasses the approval or SonarQube rules.

## 0. Preconditions
- Feature/API/DB workflows complete; branch is up to date.
- All invariants + `project-constraints.md` satisfied (migration-based, approval, Sonar gate).

## 1. Full verification
```
dotnet restore
dotnet build          # warnings-as-errors
dotnet test           # unit + integration + architecture
npm run typecheck
npm run build
```
- Then the **SonarQube scanner** ([`../standards/sonarqube.md`](../standards/sonarqube.md)).
- If SonarQube reports **Blocker/Critical/Major**: **stop → fix → rerun scanner → repeat** until
  clean. Minor/Info may be triaged.

## 2. Summarize & request approval
- Provide: change summary, changed files, build/test results, SonarQube result, remaining risks,
  and a suggested commit message.
- **Wait for explicit user approval.** No push, force-push, merge, rebase, tag, or release
  without it ([`../standards/git-approval-policy.md`](../standards/git-approval-policy.md)).

## 3. Database (if schema changed)
- Apply the reviewed idempotent migration script as a **controlled step** (not on app startup);
  DBA-reviewed. Optionally enable maintenance mode during the migration
  ([`../standards/middleware.md`](../standards/middleware.md) §19).

## 4. Deploy (per `project-constraints.md`)
- Backend → Azure App Service; frontend → Static Web Apps/App Service; DB → Azure SQL.
- Secrets from Key Vault/App Settings via Managed Identity. Environment-specific config for
  Development/Staging/Production ([`../standards/gcp.md`](../standards/gcp.md)).
- Confirm `/health/ready` (incl. DB) after deploy; watch Application Insights.

## 5. Post-release
- Verify the versioned API + OpenAPI are live; deprecated versions still respond within their
  window. Record any follow-ups in `.claude/memory/`.
