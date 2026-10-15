# V2 Goal 4: Authentication and Typed Routing

Status: implementation complete; local gates passed, CI evidence pending integration.

## Delivered boundary

- Pure-Dart `auth_core` with typed gateways/use cases, exhaustive auth states,
  sole-owner session persistence, serialized store operations and refresh,
  failed-token comparison, refresh cooldown, local-first sign-out, and stale
  generation protection.
- Optional `auth_ui` with a typed sign-in Cubit, validators, and replaceable form
  primitives; app screens retain controllers and layout.
- App-owned secure session JSON adapter and deterministic reference auth backend.
- Networking unauthorized recovery with a maximum of one safe replay,
  cancellation/deadline propagation, and refresh endpoints that can opt out.
- Generated app-owned routes, centralized auth redirect, and allow-listed
  protected destination restoration through login.
- Architecture checks that prevent auth framework/plugin leakage and gateways in
  presentation.

Legacy `core`, `shared`, `user_app`, and `admin_app` remain untouched and outside
the workspace. Notifications/realtime remain later V2 work; chat remains V2.1.

## Acceptance evidence

The automated suite includes:

- twenty concurrent unauthorized recoveries causing exactly one refresh;
- an end-to-end local HTTP test proving twenty initial 401 responses, one
  refresh, and one replay per request;
- stale-token, missing-token, terminal/transient failure and cooldown cases;
- sign-out during sign-in, refresh, remote revocation, and an in-progress store
  write;
- non-replayable bodies, second-401 termination, cancellation, and one absolute
  deadline;
- secure-session JSON round trip, malformed data, unknown fields, and errors;
- protected deep-link restoration, rejected external destinations, and restored
  sessions entering protected routes;
- stable second-run typed-route generation.

Final command results and GitHub Actions run are recorded here during branch
integration. Platform compilation does not upgrade runtime capability status;
the capability matrix remains authoritative.

## Local verification record

Evidence collected on Windows on 2026-10-15:

| Gate | Command | Result |
|---|---|---|
| Locked resolution | `flutter pub get --enforce-lockfile` | PASS |
| Workspace format/analyze/tests | `dart run tool/workspace.dart verify` | PASS through all tests; route stage was rerun after a build cache clean |
| Typed route stability | `dart run tool/workspace.dart routes` | PASS; second generation wrote zero outputs |
| Tool analysis | `dart analyze tool` | PASS; zero findings |
| Dependency/source boundaries | `dart run tool/check_architecture.dart` | PASS |
| Fresh third-app proof | `dart run tool/verify_temporary_consumer.dart` | PASS; analyzed and built Web |
| Android | `flutter build apk --debug --no-pub` | PASS |
| Web | `flutter build web --release --no-pub` | PASS, including Wasm dry run |
| Windows | `flutter build windows --release --no-pub` | PASS |
| Windows launch smoke | release executable remained alive for 8 seconds | PASS |
| iOS | GitHub Actions macOS build | PENDING |

The first full workspace run passed formatting, analysis, and all tests, then
encountered stale `build_runner` state after removal of a generated package
template file. `dart run build_runner clean` removed that cache; the dedicated
two-pass route gate then passed. This was tooling state, not a source or route
generation failure.
