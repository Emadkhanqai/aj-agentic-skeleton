# Standard: SonarQube Quality Gate

**Status:** Enforced · **Applies to:** every push, every agent

SonarQube is the mandatory quality gate. It runs **before every push**, and its
Blocker/Critical/Major findings **block** the push.

## The rules

1. **The scanner runs before every push.** No exceptions. A push proposed without a
   fresh scan is invalid.
2. **Blocker, Critical, and Major issues must be fixed before push.** While any such
   issue is open on the changed code, the push is blocked.
3. **Minor / Info** issues are triaged: fix if cheap, otherwise record why they are
   deferred. They do not block a push.
4. **Do not game the gate.** Suppressing, `// NOSONAR`-ing, or marking issues
   "won't fix" to pass the gate is prohibited unless the user explicitly approves the
   specific suppression with a documented reason.

## Severity → action

| Severity | Action | Blocks push? |
|----------|--------|:---:|
| Blocker  | Fix now | ✅ Yes |
| Critical | Fix now | ✅ Yes |
| Major    | Fix now | ✅ Yes |
| Minor    | Triage; fix if cheap | ❌ No |
| Info     | Triage | ❌ No |

## Running the scanner

> Execution environment per **`project-constraints.md`**. Use the
> installed `dotnet-sonarscanner` / `sonar-scanner` CLI or the SonarQube MCP tools.

Typical .NET flow (native):

```bash
dotnet sonarscanner begin /k:"<projectKey>" /d:sonar.host.url="<url>" /d:sonar.token="<token>"
dotnet build --no-incremental
dotnet test --collect:"XPlat Code Coverage"
dotnet sonarscanner end /d:sonar.token="<token>"
```

Frontend (TypeScript) is analysed by the same scanner run configured with the
TypeScript/JS analyzer and the LCOV coverage report path.

## Reading results (MCP)

The SonarQube MCP server is available. Preferred read path:

1. Resolve the project key (`.sonarlint/connectedMode.json` → config files → `search_my_sonarqube_projects`).
2. `get_project_quality_gate_status` — overall pass/fail.
3. `search_sonar_issues_in_projects` filtered to severities `BLOCKER,CRITICAL,MAJOR`.
4. For a PR, discover the PR key with `list_pull_requests` and pass `pullRequest`;
   for a branch, use `list_branches` and pass `branch`. Never pass both.

## Definition of "gate passed"

- Quality gate status is **OK**, **and**
- Zero open issues at severity Blocker, Critical, or Major on the new/changed code.

Only when the gate has passed may a push be *proposed* (and it still requires explicit
user approval — see [`git-approval-policy.md`](git-approval-policy.md)).

## Related

- [`git-approval-policy.md`](git-approval-policy.md)
- [`../workflows/pre-push-quality-gate.md`](../workflows/pre-push-quality-gate.md)
- [`../commands/quality-gate.md`](../commands/quality-gate.md)
