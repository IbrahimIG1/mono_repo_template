# Flutter Platform Working Rules

This repository is migrating from a legacy Flutter template to a modular internal platform targeting Android and iOS. Web and Windows code remains present, but validation and support are paused under ADR-008.

Read these sources before structural work:

- `docs/migration/v2-goal-1-audit.md`
- `docs/architecture/adr-001-foundation-contracts.md`
- `docs/architecture/adr-002-auth-session-and-replay.md`
- `docs/architecture/adr-003-composition-and-migration.md`
- `docs/architecture/adr-004-chat-event-boundary.md`
- `docs/architecture/adr-005-toolchain-workspace-and-runner.md`
- `docs/architecture/adr-006-foundation-packages.md`
- `docs/architecture/adr-007-auth-and-routing.md`

## Current migration boundary

- Goals 1 through 4 are complete: repository decisions, tooling/platform assumptions, foundation, authentication and typed routing are evidence-backed.
- Keep existing `core/` and `shared/` paths as compatibility facades.
- Do not convert `user_app` or `admin_app` in place.
- New V2 work extends the admitted production packages and `minimal_app`; do not promote removed scratch code.
- Chat is V2.1 and must not enter V2 foundation work.

## Architecture rules

- Dependencies point from apps/adapters/UI toward framework-neutral capability contracts.
- Apps own composition, endpoints, DTO adapters, routes, localization, platform files and branding.
- Use constructor injection. A service locator may exist only behind an app composition root.
- Do not use global Dio, global sockets, global storage, global navigation or package-level `GetIt.instance` access.
- Keep Cubits in presentation. Contracts, repositories and engines remain independent of `flutter_bloc` where practical.
- Simple features may use `UI -> Cubit -> Repository`; add use cases only for real business rules or orchestration.
- Typed routes are the only approved code generation. Models and JSON remain handwritten.
- Treat client-bundled configuration as public. Never commit or log secrets, tokens or passwords.

## Sharing rules

Before creating a widget, helper, model, repository, service or extension:

1. search the relevant capability package;
2. search the current app/feature;
3. search sibling apps and legacy compatibility code;
4. reuse or adapt only when ownership and semantics match;
5. otherwise keep the new code local until reuse is proven.

Do not put app assets, endpoints, Firebase configuration or feature DTOs into shared packages.

## Migration rules

- Preserve user changes and begin from an inspected Git state.
- Migrate one bounded vertical slice at a time.
- Capture behavior, fixtures and consumers before replacement.
- A replacement becomes authoritative before legacy removal.
- Delete nothing based only on appearance or lack of a direct Dart import; check platform/build/configuration consumers.
- Keep removal commits separate and recoverable.
- Follow workspace admission rules from the Goal 1 audit.

## Goal Git lifecycle

Before starting every goal:

1. require a clean worktree and inspect unowned changes;
2. switch to `main`, run `git fetch origin --prune`, then update with `git pull --ff-only origin main`;
3. create a new goal branch from that updated `main`;
4. do not implement the goal directly on `main`.

After completing and verifying every goal:

1. commit and push the goal branch;
2. switch to `main` and run `git pull --ff-only origin main` again;
3. merge the completed goal branch into `main` with a merge commit;
4. rerun checks proportional to the merge risk;
5. push `main` and verify local `main`, `origin/main`, and the remote head have the same commit;
6. start the next goal only from that synchronized `main`.

If `main` changes during integration, fetch and reconcile it before pushing. Never force-push `main` or discard either side of a conflict without inspecting ownership and intent.

## Quality rules

- Analyzer target: zero errors, warnings and infos.
- Every test file must contain executable tests.
- Report commands actually run and their exact result.
- Compilation is not proof of runtime/platform support.
- Use only: Supported, Unsupported, Experimental, or Manual-validation-required in capability matrices.
- Add regression tests for bugs and contract/concurrency tests for infrastructure.
- Generated route files must be reproducible with no second-run diff.

## Documentation rules

- Update architecture decisions when ownership or public contracts change.
- Document meaningful flows and limitations, not file-by-file narration.
- Keep package public APIs and setup requirements discoverable.
- Do not rewrite documentation for trivial internal changes.

## Collaboration

- One agent owns integration for a phase.
- Parallel contributors may handle bounded, non-overlapping tasks only after contracts are stable.
- Root workspace, routing, DI and shared contracts must not be edited concurrently without an explicit owner.
