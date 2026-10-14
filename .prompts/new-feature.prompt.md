# New Feature Prompt

Use for a new feature or a meaningful extension.

## Before implementation

- Define the user outcome and measurable acceptance criteria.
- State assumptions and unsupported platforms.
- Search capability packages, the current feature, sibling apps and legacy facades.
- Choose lightweight feature flow or structured ports/adapters using the criteria in `AGENTS.md`.
- Identify app-owned configuration, DTOs, routes and platform setup.
- Define tests, failure behavior, migration impact and rollback boundary.

## Implementation rules

- Keep contracts framework-neutral unless the package is explicitly presentation-only.
- Inject external dependencies through constructors.
- Keep Cubits independent of clients/plugins/transports.
- Localize user-facing text.
- Do not add a package or abstraction without a demonstrated ownership/reuse reason.
- Do not enable an optional capability transitively for every app.

## Completion report

- Behavior delivered and acceptance criteria status.
- Reuse decisions and dependency changes.
- Public contracts/configuration added.
- Tests and builds actually run.
- Capability/platform status and manual steps.
- Documentation updated.

Use `$monorepo`, `$flutter-architecture` and `$documentation` when their scopes apply.
