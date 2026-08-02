# aj-agentic-skeleton

**A portable engineering brain for AI-first development** — install it as a Claude Code skill, and every project your team (or your AI agent) builds follows the same senior-grade standards: frontend, backend, or full-stack.

Backend: **.NET / ASP.NET Core / C# / EF Core** · Frontend: **Angular + PrimeNG** or **React + TypeScript** · Data: **SQL Server (code-first)** and/or **Azure Cosmos DB** · Agent: **Claude Code**

> The core idea in one line: **derive the architecture once per project, then enforce it forever** — advisory markdown for judgment, deterministic guardrails (build props, hooks, architecture tests) for everything an agent or a rushed human could forget.

---

## Why this exists

Agentic coding has a quality problem: give ten developers the same AI tool and you get ten different codebases. Documentation doesn't fix this — nobody (human or agent) reliably re-reads documents. What fixes it is a system where:

1. **The right way is the only way that compiles.** Layering violations, unconfigured column types, hand-crafted response envelopes — these fail the build, they don't wait for code review.
2. **Architecture is derived, not imposed.** Not every project should be clean architecture. Not every project needs microservices. A decision tree interviews you and picks the fit — modular monolith by default, and it makes you justify anything heavier.
3. **Standards travel.** Install the skill once; every repo you initialize inherits 12+ years of .NET architecture judgment — API contracts, error handling, security, testing discipline, cost-aware model routing.

## What's inside

| Layer | What it does |
|---|---|
| **`invariants.md`** | 20 non-negotiable rules that hold in *every* project regardless of architecture — always loaded. Push-approval policy, quality gates, one `ApiResponse<T>` envelope, entities never over the wire, evidence-or-it-didn't-happen, dependency-approval gate, and more. |
| **`playbooks/`** | Architecture-specific guidance, loaded one at a time: modular monolith (default), clean architecture, microservices (with anti-rules), minimal API, Angular + PrimeNG, React + TypeScript. |
| **`commands/architect.md`** | The `/architect` interview: scope (frontend / backend / full-stack), team, domain, databases → picks the playbook, writes the ADR, generates the repo's `CLAUDE.md` and `project-constraints.md`, then **writes the enforcement files**. |
| **`enforcement/`** | The walls: `Directory.Build.props` (warnings-as-errors + analyzers, no opt-out), Claude Code hooks (dangerous-command blocker, dependency-approval gate, protected-file guard, auto-format), and **NetArchTest architecture-test templates** per playbook. |
| **`standards/`** | Topic deep-dives loaded per task: API design/versioning/envelope, error handling & middleware order, EF Core & migrations, **MSSQL code-first pro practices**, **Cosmos DB rules** (conditional — loaded only if the project uses Cosmos), OWASP-aligned security, observability, SonarQube gating. |
| **`agents/`** | Role prompts for subagents: orchestrator, backend engineer, frontend engineer, code reviewer, security auditor, test engineer, quality gate. |
| **`model-routing.md`** | Cost discipline: classify every task and recommend the cheapest fitting model *before* starting. Opus-class models for architecture/security/debugging; Sonnet-class for implementation. |
| **`workflows/` + `templates/`** | Repeatable processes (new feature, API change, DB change, release, code review) and copy-paste starting points (ADR, PR, controller, entity, component). |

## Advantages

- **Consistency at scale** — junior, senior, or fully agent-driven: the structural output is identical, because deviation fails the build, not the vibe check.
- **Architecture flexibility without chaos** — monolith here, microservices there, a minimal API for the internal tool; each choice is recorded in an ADR and enforced by matching tests.
- **Conditional intelligence** — MSSQL code-first tips apply only when MSSQL is recorded; Cosmos DB rules (partition-key design, RU discipline, ETag concurrency, change feed) load only if you answer "yes, Cosmos". No noise.
- **Agent-safe by construction** — hooks block force-pushes and destructive commands, gate every new NuGet/npm package behind human approval (supply-chain protection), and protect `.env` / prod config / committed migrations from edits.
- **Cost-aware** — the model-routing policy stops you burning Opus-class tokens on CRUD.
- **Compounding** — the prompt→asset pipeline: a mistake that happens twice becomes a rule, hook, or architecture test. The system gets better every week you use it.

## Installation

**As a plugin (recommended):**
```
/plugin marketplace add Emadkhanqai/aj-agentic-skeleton
/plugin install fullstack-standards
```

**Manual:** clone this repo into `~/.claude/skills/fullstack-standards/` (global) or your repo's `.claude/skills/fullstack-standards/` (per-project).

**Prerequisites for the full quality gate:** a SonarQube instance (self-hosted Community Edition or SonarCloud) with the SonarQube MCP configured in Claude Code — `/pre-push` reads the quality-gate status through it. No SonarQube yet? The gate degrades gracefully: build, tests, and architecture tests still block; wire Sonar in when ready.

## Usage — A to Z

**A. Start a project.** Create an empty repo, open Claude Code in it, and run:
```
/architect
```

**B. Answer the interview.** One question at a time:
1. Project name
2. **Scope: frontend-only, backend-only, or full-stack** (gates everything else)
3. What you're building, one paragraph
4. Team size & seniority
5. One deployable or many? *(backend/full)*
6. Domain complexity? *(backend/full)*
7. Frontend framework — Angular (default: + PrimeNG) or React *(frontend/full)*
8. Relational DB — MSSQL/Azure SQL? *(backend/full)*
9. **Cosmos DB — yes or no?** *(backend/full — "yes" means partition keys get designed in this session, not "later")*
10. Org constraints (containers, compliance, air-gapped…)

CI / non-interactive: `/architect --scope fullstack --mode monolith --project OrderHub --db mssql --cosmos no`

**C. Review the recommendation.** The decision tree proposes a playbook with reasoning (and will push back — e.g. a 4-person team asking for microservices gets a warning and a better alternative). You confirm before anything is written.

**D. Watch the walls go up.** `/architect` writes into your repo:
- `docs/adr/0001-architecture-choice.md` — the decision and why
- `project-constraints.md` — *your* org's rules (e.g. "MSSQL only"), clearly separated from universal standards
- `CLAUDE.md` — project summary, recorded scope + playbook + data stores, commands
- `Directory.Build.props`, `.claude/settings.json` + hooks, and `tests/<Project>.ArchitectureTests/` matching your playbook (backend scopes) / ESLint + Prettier + strict tsconfig + `DESIGN.md` stub (frontend scopes)

**E. Verify.** The command ends by building and running the architecture tests, showing you green output. If it's red, it fixes before declaring the repo initialized.

**F. Build features.** Use `/implement` for the spec → plan → code → verify loop. The skill auto-loads the right playbook and topic standards per task — Cosmos rules never appear in a Cosmos-free project.

**G. Ship safely.** Before any push: `/pre-push` runs the full quality gate (build, format, tests, SonarQube). Pushing requires your explicit approval, every time — the agent cannot push on its own.

**Z. Compound.** When the agent gets something wrong twice, don't just fix the code — add the rule, hook, or architecture test that makes the mistake impossible. That's the whole philosophy: *derive once, enforce forever.*

## Repository structure

```
├── SKILL.md              # Router: invariants always, playbooks on demand, scope-first
├── invariants.md         # The 20 non-negotiables
├── playbooks/            # monolith · clean-arch · microservices · minimal-api · angular · react
├── commands/             # /architect · /implement · /review · /pre-push · /quality-gate …
├── enforcement/          # Build props · hooks · settings template · NetArchTest templates
├── standards/            # API · errors · EF Core · MSSQL · Cosmos DB · security · testing …
├── agents/               # Subagent role definitions
├── workflows/            # Repeatable engineering processes
├── templates/            # ADR · PR · controller · entity · component
├── memory/               # Durable cross-session project context
└── .claude-plugin/       # Plugin + marketplace manifests
```

## Honest limits

This system guarantees **structural** quality — layering, contracts, gates. It does not review your domain model or your specs; a wrong requirement implemented cleanly is still wrong. Spec review stays human. The skill routes judgment to people and everything else to the pipeline.

## Contributing

PRs welcome — with one warning taken seriously: **markdown in this repo instructs coding agents**, so documentation changes get the same scrutiny as executable code. Keep invariants architecture-agnostic; project-specific rules belong in generated `project-constraints.md`, never here.

## License & author

MIT — see [LICENSE](LICENSE).
Built by **[Emad Khan](https://emadkhan.pro)** — Senior .NET Solutions Architect. 12+ years of C#/.NET, Azure cloud-native architecture, and large-scale platform delivery, distilled into a skill your agent can carry.
