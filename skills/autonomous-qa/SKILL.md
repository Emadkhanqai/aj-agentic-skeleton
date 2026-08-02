---
name: autonomous-portal-qa
description: Use when extending or running browser-level QA for the Angular/Nx frontend (frontend/frontend-ng) — adding a new Playwright journey, investigating a UI bug report, or auditing test coverage for a route/feature.
---

# Autonomous Portal QA

Extends `frontend/frontend-ng` (an Nx workspace: `apps/portal` + 12 libraries) with real
browser-level regression coverage, on top of its existing strong Vitest suite. Read
`the project QA design spec under docs/specs/ (if present)` and
`docs/qa/requirements-test-matrix.md` before starting — they record what's already covered and
why, so you don't redo Phase 1's audit.

## Before writing anything

1. **Understand the Nx project graph.** Run `npx nx show projects` and `npx nx show project
   <name>` from `frontend/frontend-ng` — never assume a project's targets or tags from its
   directory name alone. `nx.json` registers `@nx/playwright/plugin` with `targetName: "e2e"`, so
   any project directory containing a `playwright.config.ts` automatically gets an inferred `e2e`
   target — you do not need to hand-write one in `project.json` (see `apps/portal-e2e/project.json`
   for the one exception: an explicit `dependsOn: []` override on the `e2e` target, needed because
   the plugin's inferred `dependsOn` picks `portal:serve`'s *default* configuration, which
   conflicts with `playwright.config.ts`'s own `webServer` that explicitly runs
   `portal:serve:demo`).
2. **Identify the owning library** for whatever route/component you're testing or fixing
   (`libs/feature-*`, `libs/shared/*`, `libs/data-access/*`, `libs/auth`, `libs/shell`) — the
   `eslint.config.mjs` `scope:*` dependency-constraint matrix tells you what each library is
   allowed to depend on, which tells you what it's responsible for.
3. **Read relevant plans/specs/knowledge graph** — the project plan/spec docs —
   `docs/` — before assuming a UI behavior is a bug.
   Several apparent "bugs" turn out to be deliberate (see "Investigated, not a defect" in
   `docs/qa/defect-ledger.md` for a real example: PDF em-dash normalization).
4. **Check `docs/qa/test-coverage-gaps.md` first** — if the journey you're about to write is
   already logged as a known gap, that confirms scope; if it's already logged as covered, don't
   duplicate it.

## Exploration vs. regression — use the right tool

- **Playwright MCP** (`mcp__plugin_chrome-devtools-mcp_chrome-devtools__*` /
  `mcp__plugin_playwright_playwright__*`) is for live, interactive exploration: reproducing a
  bug report, checking exact accessible names/roles before writing a locator, verifying a fix
  visually. Its artifacts (screenshots, snapshots) are evidence, not regression coverage. Root
  `.playwright-mcp/` output is gitignored session scratch — don't try to make it durable.
- **Playwright Test** (`apps/portal-e2e`) is the executable regression suite. Every journey you
  add here must actually run green under `npx nx run portal-e2e:e2e` before you consider it done.
- **Vitest** (`libs/*/src/**/*.spec.ts`) is for narrow logic and component-level regression —
  validation functions, computed signals, individual component rendering. Don't reach for a full
  browser test when a Vitest unit test proves the same thing faster and more reliably.

**Locator discipline:** don't guess PrimeNG DOM structure or accessible names. `p-select`
components' accessible `name` often tracks their *placeholder/current value text*, not the
associated `<label>` — verify with a live MCP snapshot (`take_snapshot`) or
`evaluate_script`-based DOM queries before writing a `getByRole` locator, the way
`apps/portal-e2e/src/pages/new-order.page.ts` and `reports.page.ts` were built. A locator that
"looks right" by reading the template is not verified — run it.

**Lazy-route navigation race:** clicking through to a `loadComponent`-lazy route (e.g.
`reports/:mode/:orderId`) does not guarantee `page.url()` reflects the new route the instant
`.click()` resolves — the dynamic import + router resolution can still be in flight. A page-object
method that navigates via such a click must `await this.page.waitForURL(...)` itself (see
`reports.page.ts`'s `openBaReport`/`openNetworkReport`) rather than leaving every caller to
remember it — found this the hard way when a second test reading `page.url()` immediately after
the same click got a stale URL and an `undefined` downstream value, while an adjacent test that
happened to `await expect(...).toBeVisible()` right after masked the same race.

**Full page navigation vs. SPA navigation:** `page.goto()`/`page.reload()` are real browser
navigations that destroy all in-page JS state — including anything installed via
`installMockOverride` (see below) and, in production, `sessionStorage`-backed demo data (DEF-001).
To keep state across a navigation, click through the UI (`page.getByRole('link', ...).click()`)
instead of a second `page.goto()`.

**MSW runtime overrides for `@mocked` failure paths:** Playwright's `page.route()`/
`context.route()` cannot intercept requests the app's Service-Worker-based MSW mock already
answers — verified empirically (a route handler registered before a request never fired; the
response came back `200` from MSW regardless). Use `apps/portal-e2e/src/utils/mock-override.ts`'s
`installMockOverride(page, { method, path, status, body?, delayMs? })` instead, which reaches into
`window.__mswE2E` (a demo-build-only hook in `apps/portal/src/mocks/browser.ts`, tree-shaken out
of `production`). Install the override on the CURRENT page (after any navigation, before the
SPA-internal action that triggers the request) — installing it, then doing a second `page.goto()`/
`page.reload()`, destroys it (see "Full page navigation vs. SPA navigation" above). Some queries
retry by default (TanStack Query's default retry/backoff) before settling into an error state —
order 10-15s, not a fixed short timeout, when asserting on the resulting error UI.

## Test tiers — tag every journey, and never blur them

Every `describe`/`test` title must carry exactly one environment tag, plus any content tags that
apply. **Never describe an MSW-backed (`@mocked`) test as full production integration coverage** —
it proves the Angular app honors the HTTP contract; it does not prove the real backend implements
that contract, or that data survives a real database round-trip.

| Tag | Environment | Use for |
|---|---|---|
| `@mocked` | `portal:serve:demo` (MSW) | HTTP failure paths (401/403/409/422/429/500), slow-response/spinner-lifecycle behavior, duplicate-action prevention, edge cases, controlled report fixtures — anything that needs a *deterministic* server response you can't reliably provoke from a real backend on demand |
| `@integration` | A real running backend + real database | Actual authentication, real frontend-to-backend communication, real persistence, real reference-data loading, real save/reload, real report/PDF generation. **Requires** a reachable backend URL and valid credentials — see "Blocked tiers" below if unavailable |
| `@smoke` | A real deployed URL (or `portal:serve:demo` locally as a stand-in) | Deployed reachability, login, authenticated navigation, one read-only critical journey, one safe persistence journey (only if test-data cleanup exists), one real report/PDF journey, console/network-failure checks |
| `@pdf` | Either | Content tag (combine with an environment tag): any test that downloads and parses a PDF |
| `@visual` | `portal:serve:demo` | Content tag: screenshot-baseline comparisons (`toHaveScreenshot()`) |
| `@accessibility` | `portal:serve:demo` | Content tag: axe-core scans |

**Blocked tiers:** if `@integration` or a real post-deployment `@smoke` run needs a URL/credential/
secret this session doesn't have, do not fake it against MSW and call it integration coverage.
Write the test, tag it, document in the PR description and `docs/qa/known-limitations.md` exactly
what's missing (URL env var name, secret name), and report the tier as **blocked**, not passing or
skipped-silently.

## Adding a new journey

1. Add spec files under `apps/portal-e2e/src/journeys/<area>/`, using a page object from
   `apps/portal-e2e/src/pages/` (add one if the area doesn't have one yet — keep page objects
   thin: locators + the actions a test needs, not assertions).
2. Use `apps/portal-e2e/src/fixtures/auth.ts`'s `signInAs()` to skip the login UI for journeys
   that aren't testing login itself; the one exception is `smoke/critical-path.spec.ts`, which
   deliberately exercises the real login UI.
3. Default to `portal:serve:demo` (MSW-backed, deterministic, no real backend needed) — see
   `apps/portal-e2e/playwright.config.ts`. Don't point new tests at a different serve
   configuration without a documented reason, and tag accordingly (see "Test tiers" above).
4. Tag journeys meant for the fast CI gate with `@smoke` (grep-filterable via `--grep @smoke`, see
   `.github/workflows/frontend-ci.yml`). Deeper journeys should NOT carry `@smoke` — keep the
   tagged set small and fast.
5. Update `docs/qa/requirements-test-matrix.md` with the new row, and remove the corresponding
   entry from `docs/qa/test-coverage-gaps.md` if one existed.

## Avoid

- **Arbitrary waits.** Use Playwright's auto-waiting assertions (`expect(locator).toBeVisible()`,
  `toHaveText()`, etc.) or explicit event waits (`page.waitForEvent('download')`,
  `page.waitForURL()`). No `page.waitForTimeout()` as a substitute for a real wait condition.
- **Blind baseline updates.** If a visual/text assertion starts failing, investigate whether the
  app changed or the assertion was wrong before "fixing" it by updating the expected value —
  `ba-report-pdf.spec.ts`'s em-dash normalization is the documented example of a *correct*
  assertion fix (the PDF's own sanitization is intentional); don't treat every failure as license
  to loosen an assertion without checking the underlying behavior first.
- **Weakening assertions to make a flaky test pass.** Find the root cause (usually a missing
  auto-wait or a real race) instead of loosening `toContain` to something so broad it stops
  proving anything.
- **Unrelated refactoring** of the app code you're testing — a QA task fixes QA infrastructure
  and, when a real defect is found, the smallest fix for that defect (see the defect-remediation
  process below). It does not restyle or restructure code that isn't the bug.
- **Direct unverified pushes.** Run the full local gate before pushing: `npx nx run-many -t
  lint,test,build` (exclude `portal-e2e` from that if you also want to run its own `e2e` target
  separately, since project.json can filter via `--exclude=portal-e2e`), then `npx nx run
  portal-e2e:e2e`. See "Git safety" below for branch/push rules — they supersede any earlier
  per-project convention.

## Git safety (mandatory, every session)

These rules exist because a 2026-07-16 run pushed frontend QA-infra changes to `angular-migration`
and API docs changes directly to `main` — reviewed afterward and found not to have leaked
anything, but the review should have been unnecessary if the workflow itself had prevented direct
`main` pushes and unrelated-file staging in the first place. Follow all twelve, every time:

1. **Inspect `git status` before making any change.** Do this in every repo you're about to touch,
   before the first edit.
2. **Record all pre-existing dirty/untracked files** you find in that first `git status` — note
   them explicitly (in your task notes or the final report), so you can tell your own changes
   apart from anything already sitting there when you started.
3. **Never stage unrelated pre-existing changes.** If step 1/2 found dirty files that aren't part
   of what you're doing, leave them alone — don't sweep them into your commit just because they're
   sitting in the working tree.
4. **Stage files explicitly, never `git add .` or `git add -A`.** Name every file:
   `git add path/to/file1 path/to/file2`. An indiscriminate add is exactly how an unrelated file
   (or a secret, or a generated artifact) ends up in a commit unnoticed.
5. **Show the staged diff before committing.** Run `git diff --staged` (or `git status --short`
   plus a targeted `git diff` per file) and actually look at it — don't commit from memory of what
   you intended to change.
6. **Never push directly to `main`.** Not even for "small" or "docs-only" changes. No exceptions
   inside this skill's own workflow — an explicit, direct instruction from the user in the current
   conversation to push to `main` is the *user's* call to make (and overrides this rule when given
   plainly, as happened on 2026-07-16), but the skill itself must never decide on its own to push
   there.
7. **Create a dedicated QA branch** for QA work (e.g. `qa/phase-2-<short-topic>`), branched from
   the current tip of the repo's normal working branch (`angular-migration` for
   `aj-eordering-portal`, `main` for `aj-eordering-api`). Don't reuse an existing shared feature
   branch unless you have a specific, stated reason.
8. **Open a pull request** for the QA branch once the work and its local gate are green. Use
   `gh pr create` (or the repo's SCM CLI) with a summary and a test plan — don't hand the user a
   branch name and call it done.
9. **Wait for required CI** on the PR before considering the work mergeable. Report the CI run's
   actual status (pass/fail/pending) — don't assume it passed because the local gate did.
10. **Merge only under repository-approved policy.** If branch protection requires review/approval
    this skill cannot satisfy on its own (no auto-approval, no bypassing required reviewers), stop
    at "PR open, CI status reported" and say so — don't force-merge.
11. **Never rewrite or force-push shared history.** No `git push --force` (or `--force-with-lease`)
    to any branch another session or person might have based work on, and no `git rebase`/`commit
    --amend` on commits already pushed to a shared branch. If a mistake needs correcting, use a new
    corrective commit and explain it (see the 2026-07-16 gitignore-hardening commit for the
    pattern), never history rewriting.
12. **Report uncommitted or unrelated files separately** from your own work summary — don't fold
    "here's what I built" and "here's what I found sitting in the tree that isn't mine" into one
    paragraph; call the second one out explicitly so the user can decide what to do with it.

## Visual and accessibility gates

- **Never auto-update visual baselines in CI.** `--update-snapshots` is a local, human-reviewed
  action only — a CI job that silently regenerates baselines on failure defeats the point of the
  gate. If a screenshot test fails, a person looks at the diff and decides intentional-change vs.
  regression before any baseline is touched.
- **Don't blindly approve a new/changed baseline.** Actually look at the before/after image
  (`--update-snapshots` locally, then review the diff in the PR) before committing it.
- **Document accepted accessibility exceptions with justification**, not a blanket rule disable —
  if an axe rule is intentionally allowed to fail on a specific route/component, record why in
  `docs/qa/known-limitations.md` (or inline near the exception) rather than silently excluding it.

## Defect remediation

When a journey finds a real defect (not a deliberate behavior — check first, see above):

1. Add an entry to `docs/qa/defect-ledger.md` with an ID (`DEF-NNN`), reproduction steps, root
   cause, owning Nx project, and severity.
2. Write the regression test FIRST (it should fail against the current code), confirm it fails
   for the right reason, then implement the smallest fix.
3. Re-run the regression test, the owning project's full test suite, `npx nx affected
   -t lint,test,build`, and the full `portal-e2e:e2e` suite (a UI fix can have E2E-visible
   side effects a unit test won't catch).
4. Update the defect ledger entry to "Fixed" with the commit hash and the regression test's path,
   and update `docs/qa/requirements-test-matrix.md`/`test-coverage-gaps.md` if the fix changes
   what's covered.

## Real `@integration` tier — check the actual contract before writing anything

Before writing a single `@integration`-tagged test, read `docs/qa/integration-test-contract.md`
(added Phase 3, 2026-07-16). It lists the exact env vars/secrets/roles required and the
environment-safety check every write must perform (refuse to run destructive steps if the target
resolves to production, or if the environment can't be identified at all — fail closed, not
open). As of Phase 3, **none of the prerequisites existed** — no real backend deployment, no Entra
ID tenant configured (empty `TenantId`/`ClientId`), no real staging DB, zero CI secrets wired in
either repo. Do not invent credentials, add a test-only auth bypass, or point a test at a
convenient-but-uncontracted URL to make progress look further along than it is — report the gap
against the contract instead, same as any other blocked tier.

## Verify docs against source before trusting them — even this project's own docs

Phase 3 found `backend/database/erd.md` was 10 migrations stale (documented 9 tables; the live EF
Core model snapshot had 24 — reference/taxonomy data had moved from embedded JSON into real tables
months earlier, and the doc never caught up). The lesson: a `docs/*.md` file describing "current"
schema, architecture, or deployment state is a claim about a point in time, not a live query. Before
citing one in a report (this skill's own memory included), re-verify against the actual source
(`*ModelSnapshot.cs` for schema, actual `appsettings.json`/CI workflow files for deployment
state) — the same standard this skill already applies to `docs/qa/*` staleness in "Producing a QA
report" below.

## Producing a QA report

When asked to report on QA status, read (don't re-derive) `docs/qa/requirements-test-matrix.md`,
`docs/qa/test-coverage-gaps.md`, `docs/qa/known-limitations.md`, and `docs/qa/defect-ledger.md`,
then run the actual suites (`nx run portal-e2e:e2e`, `nx run-many -t lint,test,build`) to confirm
the documented status still matches reality before reporting it — a doc can go stale; a fresh
green/red run is the source of truth.
