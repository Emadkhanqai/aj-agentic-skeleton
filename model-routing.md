# Model Routing Policy

**Every task starts by classifying the work and recommending the cheapest model that fits.**
Claude cannot switch its own model — so it MUST classify the task up front and, if the current
model is more expensive than the work needs, **STOP and warn the user before continuing**.

## Classify first

| Task type | Recommended model |
|---|---|
| **Architecture / design decisions** | **Opus / Fable** |
| **Security review / threat modeling** | **Opus / Fable** |
| **Complex debugging** (multi-system, root-cause unknown) | **Opus / Fable** |
| **High-risk refactors** (broad blast radius, hot paths) | **Opus / Fable** |
| **Final pre-push review** | **Opus / Fable** |
| Normal implementation / CRUD | **Sonnet** |
| Tests (unit / integration / arch / component) | **Sonnet** |
| Frontend build / UI | **Sonnet** |
| EF Core migrations | **Sonnet** |
| SonarQube fixes | **Sonnet** |
| Docs / config / memory updates | **Sonnet** |

## What to say

**If the current model is too expensive for the task:**
> **Recommended model: Sonnet. Please switch model before continuing.**

**If the task is high-risk / architectural:**
> **Recommended model: Opus/Fable for architecture review.**

State the recommendation, then wait — do not burn an expensive model on Sonnet-tier work just
because a session is already open on it.

## Operating rules

- **Use Sonnet** for: implementation, tests, docs, Sonar fixes, CRUD, frontend, EF migrations.
- **Use Opus/Fable only** for: architecture, security review, complex debugging, high-risk
  refactors, final review.
- **Keep sessions short.** Long sessions burn context and hit session limits.
- **After every slice:** update [`memory/shared-context.md`](memory/shared-context.md), push if
  approved/allowed, then **recommend closing the session**.
- Subagents inherit this policy. The master-agent assigns each dispatched agent a model per the
  table above (implementation/test/migration → Sonnet; security/final-review → Opus/Fable).

## Why

Opus/Fable are for judgment-heavy work where a wrong call is expensive. Sonnet handles the bulk of
implementation at a fraction of the cost. Routing by task type keeps spend proportional to risk and
avoids exhausting session limits mid-slice.
