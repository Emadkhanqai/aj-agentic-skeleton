# Playbook: Minimal API (small tools & POCs)

For single-purpose APIs, internal utilities, and proofs of concept. Small does not mean
sloppy — all invariants still apply (envelope, validation, tests, gates). What relaxes is
*ceremony*, not *discipline*.

## Structure

```
src/{{ProjectName}}/
├── Program.cs                 # Bootstrap + middleware + endpoint mapping
├── Endpoints/                 # One static class per resource, MapGroup per area
├── Features/                  # Handler + validator per operation (still slices)
├── Data/                      # DbContext + migrations
└── Common/                    # ApiResponse<T>, exception handlers
tests/{{ProjectName}}.Tests/   # WebApplicationFactory integration tests as the primary layer
```

## Rules

1. Minimal APIs + endpoint filters for validation; `IExceptionHandler` chain exactly as in
   `standards/error-handling.md` — the envelope is identical to big projects.
2. Integration tests over unit tests — at this size, testing through HTTP catches more per test.
3. Single project until it hurts; the moment Endpoints/Features grow past ~15 operations or a
   second bounded context appears, STOP and run `/architect` again — this playbook is not for
   growing products.
4. Still no: entities over the wire, string-built SQL, secrets in config, unversioned breaking
   changes.
