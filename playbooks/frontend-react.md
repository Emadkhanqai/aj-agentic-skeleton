# Standard: React Frontend

**Target:** React + TypeScript + **Vite**. Feature-based architecture.

## Folder architecture

```
src/
├── app/                 App shell, providers, router, global setup
├── pages/               Route-level screens (compose features + shared)
├── features/            Self-contained feature modules (orders, price-lists, …)
│   └── <feature>/       components, hooks, api, model — scoped to the feature
└── shared/              Cross-cutting, feature-agnostic building blocks
    ├── api/             Centralised API client
    │   └── generated/   Types/clients generated from backend OpenAPI (do not edit)
    ├── components/      Reusable presentational components
    ├── hooks/           Reusable hooks
    ├── types/           Shared types
    └── utils/           Pure helpers
```

## Import direction rules (enforced by lint boundaries)

| Layer | May import from | Must NOT import from |
|---|---|---|
| `pages` | `features`, `shared` | — |
| `features` | `shared` (and its own module) | `pages`, other `features`' internals |
| `shared` | `shared` only | `pages`, `features` |

`shared` is the leaf: it never reaches upward into `features` or `pages`.

## API calls

- **All API calls are centralised** in `src/shared/api`. Components/features never call
  `fetch`/`axios` directly.
- Request/response types come from `src/shared/api/generated` (from backend OpenAPI).
  **No hand-duplicated backend models** when a generated type exists — see
  [`typescript.md`](../standards/typescript.md) and [`api-design.md`](../standards/api-design.md).
- Prefer a data-fetching layer (e.g. TanStack Query) wrapping the generated client;
  keep server-state out of ad-hoc component state.

## Component conventions

- Function components + hooks only. No class components.
- One component per file; colocate its styles/tests.
- Presentational vs. container separation where it adds clarity.
- Accessibility: semantic HTML, labelled controls, keyboard support, visible focus.
- **Bilingual-ready** (BRD 2.1): all user-facing strings via i18n from day one; layout
  must tolerate RTL (Arabic) even though English ships first.

## Quality

- ESLint + Prettier; TS `strict`. `npm run typecheck` and `npm run build` must pass
  before any push (and feed SonarQube — see [`sonarqube.md`](../standards/sonarqube.md)).

## Related

- [`typescript.md`](../standards/typescript.md) · [`api-design.md`](../standards/api-design.md) · [`testing.md`](../standards/testing.md)
