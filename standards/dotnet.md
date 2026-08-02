# Standard: .NET Backend

**Target:** .NET 10 (SDK installed: 10.0.x) · ASP.NET Core Web API · C# latest.

## Project layout

Solution `{{ProjectName}}.sln` with:

- `src/{{ProjectName}}.Domain`
- `src/{{ProjectName}}.Application`
- `src/{{ProjectName}}.Infrastructure`
- `src/{{ProjectName}}.Contracts`
- `src/{{ProjectName}}.Api`
- `tests/{{ProjectName}}.UnitTests`
- `tests/{{ProjectName}}.IntegrationTests`
- `tests/{{ProjectName}}.ArchitectureTests`

Dependency directions are defined in [`clean-architecture.md`](clean-architecture.md)
and enforced by `{{ProjectName}}.ArchitectureTests`.

## Language & style

- `Nullable` **enabled**, `ImplicitUsings` enabled, `TreatWarningsAsErrors` **true**.
- `LangVersion` latest. File-scoped namespaces. One top-level type per file.
- Prefer `record` for immutable DTOs/value objects; `sealed` classes by default.
- Async all the way: `async`/`await`, `CancellationToken` on every I/O path,
  suffix async methods with `Async`.
- No `async void` (except event handlers). No `.Result`/`.Wait()` blocking.
- Use `System.Text.Json` (not Newtonsoft) unless a specific need arises.

## Validation

- Use **FluentValidation** for request/command validation where validation exists or
  is needed. Validators live in Application. Wire them into the pipeline so failures
  surface as ProblemDetails (see [`api-design.md`](api-design.md)).

## Errors

- API errors returned as **RFC 7807 ProblemDetails** (see [`api-design.md`](api-design.md)).
- Domain/Application throw typed exceptions or return result objects; a middleware
  maps them to ProblemDetails. No raw 500s leaking stack traces in production.

## Configuration & secrets

- `appsettings.json` for non-secret config; environment-specific overrides via
  `appsettings.{Environment}.json` and environment variables.
- **No secrets in source.** Locally use `dotnet user-secrets`; in Azure use Key Vault
  + workload/service identities (see [`gcp.md`](gcp.md)).
- Connection strings target the recorded relational store (MSSQL default — see [`mssql.md`](mssql.md)).

## Build & test commands

```bash
dotnet restore
dotnet build --no-incremental
dotnet test
dotnet format --verify-no-changes   # style gate
```

## Related

- [`clean-architecture.md`](clean-architecture.md) · [`ef-core.md`](ef-core.md) · [`api-design.md`](api-design.md) · [`testing.md`](testing.md) · [`security.md`](security.md)
