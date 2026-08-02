# Standard: Git Approval Policy

**Status:** Enforced · **Applies to:** every agent and contributor

This is the most important operational rule in the system. It exists because pushing
code has consequences that are hard to reverse (CI triggers, deploys, shared history,
external visibility).

## The rule

> **Never push without explicit user approval — every time.**

- No `git push` to any branch or any remote until the user explicitly authorises
  *that specific push*.
- Approval is **not** durable. Approval to push once is not approval to push again.
  Ask again for the next push.
- Approval given for one branch/remote does not transfer to another.
- "Commit" is allowed as normal local work; **"push" is the gated action**.

## What agents MAY do without asking

- `git init`, `git status`, `git diff`, `git log`, `git add`, `git commit`
- Create and switch local branches
- Stage and organise work locally

## What agents MUST NOT do without explicit, current approval

- `git push` (any form, including `--force`, `--tags`, `--set-upstream`)
- Open or update a pull request that triggers remote CI
- Any command that publishes local state to a remote

## Preconditions for even *proposing* a push

A push may only be proposed to the user after **all** of the following are true:

1. The working tree is committed and clean (no stray changes).
2. Tests pass — see [`testing.md`](testing.md).
3. The **SonarQube scanner has run** on the current state — see [`sonarqube.md`](sonarqube.md).
4. **Zero open Blocker, Critical, or Major** SonarQube issues.
5. A short summary of what will be pushed is presented to the user.

Only then may the agent ask: *"Ready to push `<branch>` to `<remote>`. Approve?"*
and wait for an explicit yes.

## Branch discipline

- Never commit feature work directly to `main`/`master`. Branch first.
- Branch naming: `feature/<short-desc>`, `fix/<short-desc>`, `chore/<short-desc>`.
- Commit messages: imperative mood, scoped, explain the *why*.
- **Never** add AI/assistant attribution or co-author trailers to commits, PRs, docs, or
  code. No "Co-Authored-By", no "Generated with …", no tool credit — anywhere, ever.

## Related

- [`sonarqube.md`](sonarqube.md) — the quality gate that must pass first
- [`../workflows/pre-push-quality-gate.md`](../workflows/pre-push-quality-gate.md) — the exact pre-push sequence
- [`../commands/pre-push.md`](../commands/pre-push.md) — the `/pre-push` command
