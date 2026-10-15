# V2 Goal 3: Foundation and `minimal_app`

Status: local implementation gates complete; four-platform CI pending.

## Delivered boundary

- Explicit Pub Workspace containing only the four V2 foundation packages and `minimal_app`.
- Shared strict analysis and a single root lockfile under Flutter `3.44.1` / Dart `3.12.1`.
- Sealed results, extensible failures, structured redacted logging, injected HTTP/storage adapters, and brand-neutral UI primitives.
- App-owned constructor composition with explicit resource disposal.
- Dependency-cycle, allowed-edge, forbidden-transitive-dependency, global-instance, and legacy-import checks.
- A disposable clean-workspace consumer proof that creates a third app, resolves all packages, analyzes, and builds Web.

Legacy `core`, `shared`, `user_app`, and `admin_app` were not admitted, converted, or removed. Auth, routing, notifications, realtime, and chat are outside this goal.

## Verification record

Local evidence collected on Windows on 2026-10-15:

| Gate | Command | Result |
|---|---|---|
| Locked resolution | `flutter pub get --enforce-lockfile` | PASS |
| Formatting, member analysis/tests, route check | `dart run tool/workspace.dart verify` | PASS; zero analyzer findings and all tests passed |
| Tool analysis | `dart analyze tool` | PASS; zero findings |
| Dependency and source boundaries | `dart run tool/check_architecture.dart` | PASS |
| Fresh third-app proof | `dart run tool/verify_temporary_consumer.dart` | PASS; generated workspace/app analyzed and built Web |
| Android | `flutter build apk --debug --no-pub` | PASS |
| Web | `flutter build web --release --no-pub` | PASS, including Wasm dry run |
| Windows | `flutter build windows --release --no-pub` | PASS |
| Windows launch smoke | release executable remained alive for 8 seconds | PASS |
| iOS | `flutter build ios --release --no-codesign --no-pub` | VERIFY: macOS CI pending |

The first Android attempt exposed a Kotlin incremental-cache failure because the Windows Pub cache and repository were on different drives. `kotlin.incremental=false` was added to the new app's Gradle properties; a clean rebuild then passed. This changes build performance only, not runtime behavior.

Runtime capability claims remain limited by the [platform matrix](../capabilities/platform-matrix.md). The final CI run is recorded here at goal close.
