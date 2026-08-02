# enforcement/ — words become walls

`/architect` copies these into the target repo after the playbook is chosen. They are the
deterministic layer under the advisory markdown: a standard the agent could forget becomes a
build failure it cannot.

- `Directory.Build.props` — warnings-as-errors + analyzers on every project, no opt-out.
- `settings.template.json` → repo `.claude/settings.json` — permission denies + hooks.
- `hooks/` — dangerous-command blocker (incl. dependency-approval gate), protected-file guard,
  auto-format.
- `architecture-tests/` — NetArchTest templates per playbook; `/architect` copies the matching
  one into `tests/{{ProjectName}}.ArchitectureTests/` and replaces tokens. Requires packages:
  `NetArchTest.Rules`, `xunit`.

Microservices projects additionally add consumer-driven contract tests (see the playbook);
minimal-api projects keep Directory.Build.props + hooks and may skip layering tests.
