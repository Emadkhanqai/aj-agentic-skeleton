# /architect — derive the architecture, then make it enforceable

Run in a new or undecided repo. Interviews the user, chooses a playbook, records the decision,
and writes deterministic guardrails into the repo. Run once per project; re-run only for a
deliberate architecture change (which produces a superseding ADR).

Non-interactive mode for CI/testing: `/architect --scope fullstack --mode monolith --project OrderHub --frontend angular --db mssql --cosmos no`
skips the interview and applies the named playbook directly.

## Step 1 — Interview (one question at a time)

Ask, in order. Stop early if answers make the decision obvious.

1. **Project name?** → replaces `{{PROJECT_NAME}}` / `{{ProjectName}}` everywhere.
2. **Scope: frontend-only, backend-only, or full-stack?** This gates every later question —
   skip backend questions for frontend-only scope and vice versa.
3. **What is being built, in one paragraph?** (domain, users, rough scale)
4. **Team size and seniority?**
5. *(backend/full only)* **One deployable or many?** Does any part *provably* need independent
   deploy/scale today — not "maybe later"?
6. *(backend/full only)* **Domain complexity?** Heavy business rules and long product life, or
   mostly CRUD over data?
7. *(frontend/full only)* **Frontend framework?** Angular + PrimeNG (default). React only if the org explicitly requires it.
8. *(backend/full only)* **Relational database?** MSSQL/Azure SQL (default) or other. If
   MSSQL → record it; `standards/mssql.md` code-first practices apply to all schema work.
9. *(backend/full only)* **Will the project use Cosmos DB?** Yes → record it;
   `standards/cosmosdb.md` applies (partition-key design happens NOW, not later). No → record
   "no Cosmos"; that standard is skipped entirely. If both MSSQL and Cosmos: record dual-store
   + the outbox/change-feed sync rule.
10. **Cloud & constraints?** Anything the org mandates or forbids — containers, compliance,
    air-gapped envs. These become `project-constraints.md`.

## Step 2 — Decide (the tree)

```
SCOPE:
  frontend-only  → frontend playbook only (skip backend tree)
  backend-only   → backend tree below (skip frontend playbook)
  full-stack     → backend tree below + frontend playbook

BACKEND TREE:
one small tool / POC / single-purpose API?        → minimal-api
proven independent deploy/scale need, team ≥8,
  and org can afford distributed-systems tax?     → microservices
complex domain + long-lived + heavy rules?        → clean-architecture
otherwise (the common case)                       → modular-monolith   ← DEFAULT

DATA (backend/full):
MSSQL recorded   → mssql.md applies to all schema/query work
Cosmos = yes     → cosmosdb.md applies; partition keys designed in this session
Cosmos = no      → cosmosdb.md is never loaded
both             → dual-store: sync via outbox/change feed, dual writes banned
```

Rules of judgment:
- **Modular monolith is the default.** Microservices require the user to name the concrete
  constraint that demands them; "scalability" without numbers is not a constraint.
- Team ≤6 choosing microservices → warn explicitly, recommend modular monolith with enforced
  module boundaries (it migrates to services later far more cheaply than the reverse).
- When torn between clean-architecture and modular-monolith, note that the monolith playbook
  already uses clean layering *inside each module* — choose clean-architecture only when the
  domain layer itself is the product.

State the recommendation and reasoning, get explicit user confirmation before writing anything.

## Step 3 — Write the decision into the repo

In this exact order:

1. **`docs/adr/0001-architecture-choice.md`** — from `templates/adr.md`: the decision, the
   drivers from the interview, the options rejected and why.
2. **`project-constraints.md`** (repo root) — the org/project-specific rules from question 8,
   clearly labeled: *"These are project constraints, not universal standards."* (e.g. "MSSQL
   only", "No containers", "EU data residency".)
3. **`CLAUDE.md`** (repo root) — generated, containing: project name + one-paragraph domain
   summary; **recorded scope (frontend/backend/full-stack)**; the chosen playbook name(s) and
   pointers; **recorded data stores (MSSQL / Cosmos / both / other)** so future sessions load
   the right conditional standards; the invariants pointer (`invariants.md` of this skill);
   `project-constraints.md` pointer; build/test/run commands; and the pre-push gate command.
4. **Enforcement files — words become walls (MANDATORY, never skip):**
   - `Directory.Build.props` ← `enforcement/Directory.Build.props`
   - `.claude/settings.json` ← `enforcement/settings.template.json` (hooks wired)
   - `.claude/hooks/*` ← `enforcement/hooks/`
   - *(backend/full)* `tests/{{ProjectName}}.ArchitectureTests/` ← the architecture-test
     template matching the chosen playbook from `enforcement/architecture-tests/`, tokens
     replaced. Deviation fails the build.
   - *(frontend/full)* committed ESLint + Prettier config and strict `tsconfig` per the
     frontend playbook; a `DESIGN.md` stub with a pointer to https://getdesign.md.
5. **Token sweep** — replace all `{{PROJECT_NAME}}` / `{{ProjectName}}` across copied files.

## Step 4 — Prove it

Run the build and the architecture tests. Show the user the green output. If anything is red,
fix it before declaring the repo initialized. End with a one-screen summary: chosen playbook,
files written, and the single command that runs the full local gate.
