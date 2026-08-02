---
description: Run SonarQube and enforce zero Blocker/Critical/Major before a push may be proposed.
---

# /quality-gate

Focused SonarQube gate (assumes build/test already green; if not, run `/pre-push`).

## Steps
1. Ensure the solution builds (`dotnet build`) so the scanner has fresh analysis input.
2. Run the scanner natively (no Docker):
   ```bash
   dotnet sonarscanner begin /k:"<projectKey>" /d:sonar.host.url="<url>" /d:sonar.token="<token>"
   dotnet build --no-incremental
   dotnet sonarscanner end /d:sonar.token="<token>"
   ```
3. Read results (SonarQube MCP): `get_project_quality_gate_status`,
   `search_sonar_issues_in_projects` filtered to `BLOCKER,CRITICAL,MAJOR`,
   `search_security_hotspots` for security review.

## Rule
- **Blocker / Critical / Major must be zero before any push.** Fix → rebuild →
  rescan → repeat. Minor/Info triaged.
- Do not suppress issues to pass the gate without explicit user approval + reason.

See [`../standards/sonarqube.md`](../standards/sonarqube.md).
