# Flutter Internal Platform Template

This repository is migrating from a legacy Flutter template to a modular internal platform for Android, iOS, Web, and Windows. The first usable V2 foundation is intentionally small: apps opt into four admitted packages and own their composition, configuration, routes, DTOs, branding, and platform files.

## Current status

- Goals 1 and 2 are complete: the legacy inventory, architecture decisions, pinned Flutter `3.44.1` / Dart `3.12.1` toolchain, Pub Workspace behavior, and four-platform spike are evidence-backed.
- Goal 3 adds `platform_foundation`, `networking`, `storage`, `design_system`, and a new `minimal_app`.
- `core`, `shared`, `user_app`, and `admin_app` remain outside the V2 workspace as compatibility code. They are not examples of the target architecture.
- Auth, routing, notifications, and realtime are later V2 goals. Chat remains V2.1 and is not part of the foundation.

## Workspace

```text
apps/
  minimal_app/          # Small reference app and app-owned composition root
packages/
  platform_foundation/  # Result, AppFailure, redacted logging
  networking/           # HTTP contracts and injected Dio adapter
  storage/              # Storage contracts and plugin adapters
  design_system/        # Brand-neutral theme tokens and primitives
core/                   # Legacy compatibility package; not admitted
shared/                 # Legacy compatibility package; not admitted
```

Dependency direction:

```text
minimal_app -> design_system
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
dart analyze tool
dart run tool/check_architecture.dart
dart run tool/verify_temporary_consumer.dart
```

Run the reference app:

```powershell
flutter run -d windows -C apps/minimal_app
```

If your Flutter CLI does not support `-C`, use:

```powershell
cd apps/minimal_app
flutter run -d windows
```

Platform build gates are documented in [Goal 3 evidence](docs/migration/v2-goal-3-foundation.md). Compilation is not treated as proof of production runtime support; see the [capability/platform matrix](docs/capabilities/platform-matrix.md).

## Create another V2 app

Follow the [new-app guide](docs/guides/new-v2-app.md). A new app is admitted only after workspace resolution, zero analyzer findings, executable tests, architecture checks, and applicable platform builds pass.

## Architecture and migration sources

- [Goal 1 audit](docs/migration/v2-goal-1-audit.md)
- [Goal 2 spike](docs/spikes/goal-2-technical-spike.md)
- [Foundation contracts](docs/architecture/adr-001-foundation-contracts.md)
- [Composition and migration](docs/architecture/adr-003-composition-and-migration.md)
- [Toolchain and workspace runner](docs/architecture/adr-005-toolchain-workspace-and-runner.md)
- [Foundation package ownership](docs/architecture/adr-006-foundation-packages.md)
- [Repository working rules](AGENTS.md)

