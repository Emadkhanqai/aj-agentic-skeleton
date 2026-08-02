# Workflow: Pre-Push Quality Gate

> **Model routing (do first):** classify the task and recommend a model — see [`../model-routing.md`](../model-routing.md). Final review judgement → **Opus/Fable**; the SonarQube *fixes* it produces → **Sonnet**. Warn the user if the current model is too expensive before continuing.

**Mandatory before every push.** Native tooling only — **no Docker**.

## Steps (stop and fix on first hard failure)

```bash
# 1. Understand the change
git status
git diff --stat

# 2. Backend
dotnet restore
dotnet build --no-incremental          # zero errors
dotnet test                            # unit + integration + architecture green

# 3. Frontend
npm run typecheck                      # (in /frontend)
npm run build

# 4. SonarQube scan (native)
dotnet sonarscanner begin /k:"<projectKey>" /d:sonar.host.url="<url>" /d:sonar.token="<token>"
dotnet build --no-incremental
dotnet sonarscanner end /d:sonar.token="<token>"
# (frontend analysed in the same scan when configured)
```

## Reading the SonarQube result

Prefer the SonarQube MCP tools:
- `get_project_quality_gate_status`
- `search_sonar_issues_in_projects` filtered to `BLOCKER,CRITICAL,MAJOR`

## Gate rule

- **Any open Blocker / Critical / Major → push is BLOCKED.** Fix them, rerun build/
  test, rerun the scanner, and repeat until zero remain.
- Minor / Info → triage and record; not blocking.

## After the gate is green

1. Produce a gate report (git status, build, tests, typecheck/build, Sonar status,
   remaining risks).
2. Suggest a commit message.
3. **Ask the user for explicit approval to push.** Do not push otherwise. Approval is
   per-push and non-transferable — see
   [`../standards/git-approval-policy.md`](../standards/git-approval-policy.md).
