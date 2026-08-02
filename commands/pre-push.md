---
description: Run the mandatory pre-push quality gate (build, test, typecheck, SonarQube) and report readiness. Never pushes.
---

# /pre-push

Run the full pre-push quality gate and report. **This command never pushes.**

## Do this, in order (stop and fix on first hard failure)

1. `git status` and `git diff --stat`.
2. `dotnet restore`
3. `dotnet build --no-incremental` (zero errors).
4. `dotnet test` (unit + integration + architecture).
5. In `/frontend`: `npm run typecheck` then `npm run build`.
6. Run the **SonarQube scanner** (runner per `project-constraints.md`) and read results via the
   SonarQube MCP: `get_project_quality_gate_status` and
   `search_sonar_issues_in_projects` filtered to `BLOCKER,CRITICAL,MAJOR`.

## Enforce

- Any open **Blocker / Critical / Major** → fix, rerun build/test, rerun the scanner,
  repeat until zero remain.
- Minor / Info → triage and record.

## Report

Print: git status, build result, test result, typecheck/build result, SonarQube gate
status + open Blocker/Critical/Major count, remaining risks, and a suggested commit
message. Then **ask for explicit push approval** — do not push.

See [`../workflows/pre-push-quality-gate.md`](../workflows/pre-push-quality-gate.md).
