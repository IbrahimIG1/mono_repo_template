# Flutter Internal Platform Template

This repository is migrating from a legacy Flutter template to a modular internal platform targeting Android and iOS. Web and Windows code is retained but support and validation are paused. The first usable V2 foundation is intentionally small: apps opt into admitted packages and own their composition, configuration, routes, DTOs, branding, and platform files.

## Current status

- Goals 1 and 2 are complete: the legacy inventory, architecture decisions, pinned Flutter `3.44.1` / Dart `3.12.1` toolchain, Pub Workspace behavior, and the historical spike evidence are recorded.
- Goals 3 and 4 are complete and add the foundation, `auth_core`, optional `auth_ui`, typed
  routing, and a new `minimal_app` that proves the complete auth/replay flow.
- `core`, `shared`, `user_app`, and `admin_app` remain outside the V2 workspace as compatibility code. They are not examples of the target architecture.
- Goal 5 is complete. It adds opt-in
  notification and realtime contracts, the mobile FCM adapter, and one mobile
  WebSocket transport. Chat remains V2.1.

## Workspace

```text
apps/
  minimal_app/          # Compact auth/routing integration reference (historical name)
packages/
  platform_foundation/  # Result, AppFailure, redacted logging
  networking/           # HTTP contracts and injected Dio adapter
  storage/              # Storage contracts and plugin adapters
  design_system/        # Brand-neutral theme tokens and primitives
  auth_core/            # Pure-Dart auth/session contracts and orchestration
  auth_ui/              # Optional Cubit and form primitives
  notifications_core/  # Pure-Dart payload, client, and deduplication contracts
  notifications_fcm/   # Optional Android/iOS Firebase Messaging adapter
  realtime_core/       # Pure-Dart realtime lifecycle and buffering contracts
  realtime_websocket/  # Optional Android/iOS dart:io WebSocket transport
core/                   # Legacy compatibility package; not admitted
shared/                 # Legacy compatibility package; not admitted
```

Dependency direction:

```text
minimal_app -> design_system
            -> auth_ui -> auth_core -> platform_foundation
            -> auth_core
            -> networking -> platform_foundation
            -> storage    -> platform_foundation
            -> platform_foundation
```

Packages never import app code or legacy packages. There is no global Dio, storage instance, navigation object, or package-level service locator.

## Bootstrap and verification

Install the Flutter version declared in `.fvmrc`, then run from the repository root:

```powershell
flutter pub get --enforce-lockfile
dart run tool/workspace.dart verify
dart analyze --fatal-warnings --fatal-infos
dart test tool/test
dart run tool/check_architecture.dart
dart run tool/verify_temporary_consumer.dart
dart run tool/verify_optional_capabilities.dart --android
git diff --exit-code
```

The root formatting gate is `dart run tool/workspace.dart format`. It derives
admitted packages from Pub Workspace configuration and includes root `tool/`
sources, while generated build artifacts and not-yet-admitted legacy paths stay
outside the gate through the documented workspace policy.

Run the reference app:

```powershell
cd apps/minimal_app
flutter run -d <android-emulator-or-ios-simulator>
```

Platform build gates are documented in [Goal 3 evidence](docs/migration/v2-goal-3-foundation.md). Compilation is not treated as proof of production runtime support; see the [capability/platform matrix](docs/capabilities/platform-matrix.md).

Goal 4 behavior and test evidence are documented in the
[auth/routing migration record](docs/migration/v2-goal-4-auth-routing.md).
Mobile push setup is documented in the
[notifications guide](docs/guides/mobile-notifications.md).
Goal 5 boundaries, race handling, limitations, and verification are recorded in
the [notifications/realtime migration record](docs/migration/v2-goal-5-notifications-realtime.md).

## Create another V2 app

Follow the [new-app guide](docs/guides/new-v2-app.md). The disposable consumer
gate proves the true minimum (`platform_foundation` + `design_system`) without
auth, networking, storage, Firebase, realtime, chat, socket, or legacy code. A
new app is admitted only after workspace resolution, zero analyzer findings,
executable tests, architecture checks, and applicable platform builds pass.

## Architecture and migration sources

- [Goal 1 audit](docs/migration/v2-goal-1-audit.md)
- [Goal 2 spike](docs/spikes/goal-2-technical-spike.md)
- [Foundation contracts](docs/architecture/adr-001-foundation-contracts.md)
- [Composition and migration](docs/architecture/adr-003-composition-and-migration.md)
- [Toolchain and workspace runner](docs/architecture/adr-005-toolchain-workspace-and-runner.md)
- [Foundation package ownership](docs/architecture/adr-006-foundation-packages.md)
- [Auth and typed routing implementation](docs/architecture/adr-007-auth-and-routing.md)
- [Mobile-first V2 scope](docs/architecture/adr-008-mobile-first-scope.md)
- [`minimal_app` scope decision](docs/architecture/adr-009-minimal-reference-scope.md)
- [Notifications and realtime boundaries](docs/architecture/adr-010-notifications-and-realtime.md)
- [Execution workflow](docs/migration/v2-execution-workflow.md)
- [Repository working rules](AGENTS.md)
