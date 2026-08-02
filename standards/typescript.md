# Standard: TypeScript

**Applies to:** any TypeScript frontend (Angular default, or React) and TS tooling.

## Compiler

- **`strict: true`** (and keep every strict sub-flag on).
- Also enable: `noUncheckedIndexedAccess`, `noImplicitOverride`,
  `exactOptionalPropertyTypes`, `noFallthroughCasesInSwitch`.
- `"module": "ESNext"`, `"moduleResolution": "Bundler"`, `"target": "ES2022"`.
- Path aliases mirror the folder architecture (e.g. `@/shared/*`, `@/features/*`).

## Rules

- **No `any`.** Use `unknown` + narrowing, generics, or a precise type. `any` is a
  review blocker.
- No non-null assertions (`!`) except with a documented, provable reason.
- Prefer `type` aliases for unions/DTOs; `interface` for extendable object shapes.
- Discriminated unions for state machines (e.g. request status).
- `as const` for literal tuples/enums-of-strings; avoid TS `enum` in favour of union
  literals unless there's a reason.
- All exported functions have explicit return types.

## DTOs & backend sync

- **Do not hand-write types that duplicate backend Contracts.** The API DTOs are the
  source of truth. Generated types live in `src/shared/api/generated/` and are
  produced from the backend OpenAPI/Swagger document.
- Never edit generated files by hand; regenerate them.
- See [`api-design.md`](api-design.md) and the loaded frontend playbook.

## Related

- [`../playbooks/frontend-angular-primeng.md`](../playbooks/frontend-angular-primeng.md) · [`api-design.md`](api-design.md) · [`testing.md`](testing.md)
