# PR: <concise title>

## Summary
What changed and why (link the BRD section / issue).

## Changes
- Backend: <layers touched, migrations added>
- Frontend: <features/pages/shared touched, regenerated types?>
- Docs/DB/Azure: <notes>

## Quality gate (must be green before requesting merge)
- [ ] `dotnet build` clean
- [ ] `dotnet test` green (unit + integration + architecture)
- [ ] `npm run typecheck` clean
- [ ] `npm run build` clean
- [ ] SonarQube run — **0** Blocker / Critical / Major
- [ ] EF schema change shipped as a migration (if applicable)

## Architecture & standards
- [ ] Clean Architecture boundaries respected
- [ ] Frontend import direction respected
- [ ] `project-constraints.md` honored · no hand-duplicated DTOs

## Security
- [ ] Price-list raw values not exposed to disallowed roles (test present)
- [ ] Server-side authz; no secrets in source

## Notes / risks
<remaining risks, follow-ups>

> Push requires explicit approval. SonarQube must pass first.
