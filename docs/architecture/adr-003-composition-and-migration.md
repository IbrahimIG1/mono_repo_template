# ADR-003: Composition, Compatibility, and Workspace Admission

Status: Accepted for V2 spike and implementation.

## Dependency injection

- Use constructor injection throughout packages and application code.
- Each app has one explicit composition root that creates infrastructure first, then adapters, use cases and presentation factories.
- `get_it` is optional and may be used only behind the app composition root.
- Packages, repositories, Cubits and widgets must not call `GetIt.instance` or `getIt<T>()`.
- The composition root owns lifecycle resources and invokes `dispose`/`close` in reverse dependency order.
- Background entry points create the minimal supported dependency graph for their task; they do not assume the foreground container exists.
- Tests instantiate subjects directly with fakes.

## Compatibility facades

Current `core/` and `shared/` remain at their existing paths during migration. They may export or adapt new APIs after consumers move, but new packages never import legacy packages.

For every migrated vertical slice:

1. capture current behavior and consumers;
2. implement and test the replacement;
3. switch one consumer set to the replacement;
4. declare the replacement authoritative;
5. prevent parallel feature changes in both implementations;
6. remove legacy code only after reference count, parity, tests and builds pass.

Do not create a separate `legacy/` package tree merely to rename existing code.

## Workspace admission

The first Pub Workspace contains only new spike/V2 members. Legacy members stay independently resolved until they satisfy the admission rules in the Goal 1 audit.

This is a temporary migration boundary, not a permanent second dependency universe. Every retained legacy member must have an explicit future disposition.

## Configuration ownership

- Apps own endpoints, Firebase files, package identifiers, flavors, localization and routes.
- Shared packages accept configuration through constructors and immutable values.
- Client assets and compile-time defines are public configuration. Secrets remain on trusted services.
- Shared packages do not inspect `.env` files or select a flavor globally.

## Consequences

- Dependency creation is visible and testable.
- A service locator cannot become a hidden package dependency.
- Existing imports remain valid until verified migration.
- The workspace becomes green incrementally without pretending known legacy failures pass.
