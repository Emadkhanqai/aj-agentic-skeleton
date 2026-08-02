# Workflow: Code Review

> **Model routing (do first):** classify the task and recommend a model — see [`../model-routing.md`](../model-routing.md). Final pre-push / architecture review → **Opus/Fable**. Warn the user if the current model is mismatched before continuing.

Run before proposing a push, after the build/test gate, alongside SonarQube.

## Checklist

**Architecture**
- [ ] Backend dependency directions correct (Domain→nothing, App→Domain,
      Infra→App+Domain, Api→App+Infra+Contracts, Contracts=DTOs only).
- [ ] Frontend import direction correct (pages→features→shared; shared imports neither).

**Standards**
- [ ] Matches the relevant files in [`../standards/`](../standards/).
- [ ] No `any` (TS); nullable/warnings-as-errors respected (C#).

**Correctness & BRD fidelity**
- [ ] Order Ref ID uniqueness / issued once on Complete.
- [ ] Completeness gating; WHT & PHF math; amendment types; audit append.
- [ ] Multi-currency dual retention.

**Security**
- [ ] Price-list raw values filtered server-side; test proves no leak to disallowed roles.
- [ ] Server-side authz; secrets absent; ProblemDetails without internal leaks.

**Forbidden patterns**
- [ ] `project-constraints.md` honored (containers, DB provider). No `EnsureCreated`/manual DDL.
- [ ] No hand-duplicated DTOs where generated types exist.

**Tests**
- [ ] New/changed behaviour covered; architecture tests updated.

## Output
Prioritized findings (severe first), `file:line`, blockers vs nits. No push approval
while a correctness/security/architecture blocker is open.
