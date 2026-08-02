# Playbook: Frontend — Angular + PrimeNG

## Baseline

- Angular latest LTS, **standalone components only**, signals-first state; NgRx only when
  complexity demands it (record the reason in an ADR).
- **PrimeNG is the component library.** No mixing libraries in one app; custom components only
  where PrimeNG has no equivalent, and they follow PrimeNG theme tokens.
- `inject()` over constructor injection; typed reactive forms; `OnPush` everywhere;
  `strict: true`, no `any`.
- **API layer generated from the OpenAPI spec** (`ng-openapi-gen` or `openapi-generator`);
  hand-written HTTP clients are prohibited. Types come from the backend contract, including
  the `ApiResponse<T>` envelope — the frontend switches on `code`, never on `message`.
- ESLint + Prettier committed config; components >~300 lines get split.

## Design

- Every repo carries a `DESIGN.md` (colors, typography, spacing, component rules) that the
  agent reads before building any UI — source standard formats from https://getdesign.md so
  agent-built pages follow one visual language instead of generic AI layouts.

## Testing

- Jest/Vitest for services + component logic; Playwright E2E for critical flows (author and
  verify via Playwright MCP). Run axe-core basics on new UI.

## Structure

```
src/app/
├── core/          # singleton services, interceptors (auth, envelope, correlation-id)
├── shared/        # dumb reusable components, pipes, directives
└── features/      # one folder per feature: routes + components + state + tests
```
Feature folders mirror backend slices — `features/orders/` talks to the Orders module's API.
