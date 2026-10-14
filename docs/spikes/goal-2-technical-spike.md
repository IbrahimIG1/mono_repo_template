# Goal 2: Five-Day Technical Spike

Status: in progress; local probes passed, CI results remain `VERIFY`.

Spike branch: `v2/goal-2-spike`

Baseline commit: `34e9caf`

## Fixed five-day schedule

| Day | Focus | Exit evidence |
|---|---|---|
| 1 | Pin toolchain; create explicit Pub Workspace and scratch members | One root resolution and member list |
| 2 | Typed routes and legacy inclusion/exclusion | Stable second generation; recorded resolver results |
| 3 | Web/Windows secure storage and browser WebSocket authentication | Runtime round trips and authenticated handshake log |
| 4 | Melos comparison, Dart runner and four-platform workflow | Tooling ADR and committed CI workflow |
| 5 | CI execution, fallback decisions and cleanup | Green/approved build matrix; disposable code removed |

The estimate and timebox are exactly five working days. Finishing an experiment early does not expand its scope into production migration.

## Disposable spike boundary

The following exist only to collect evidence and must be removed at spike close:

- root spike `pubspec.yaml` and `pubspec.lock`;
- `spikes/goal2/scratch_package`;
- `spikes/goal2/scratch_app`;
- `spikes/goal2/websocket_probe_server.dart`;
- the spike-only GitHub Actions workflow.

The exact SDK pin and accepted architecture/tooling decisions may remain. Any retained runner must be explicitly adopted rather than left behind by accident.

## Candidate toolchain and dependency resolution

Candidate baseline:

- Flutter `3.44.1` stable, framework revision `924134a44c`;
- Dart `3.12.1` stable;
- exact Flutter pin in `.fvmrc` and CI;
- spike SDK range `>=3.12.1 <3.13.0` to reject an unreviewed minor upgrade.

Pub resolved these versions under that baseline:

| Package | Resolved | Constraint verified from installed package |
|---|---:|---|
| `go_router` | 18.1.0 | Dart `^3.12.0`, Flutter `>=3.44.0` |
| `go_router_builder` | 4.5.0 | Dart `^3.10.0`, Flutter `>=3.38.0` |
| `build_runner` | 2.15.1 | Dart `^3.8.0` |
| `flutter_secure_storage` | 11.2.0 | Dart `>=3.8.0 <4.0.0`, Flutter `>=3.19.0` |
| `flutter_secure_storage_web` | 2.1.1 | Dart `>=3.3.0 <4.0.0`, Flutter `>=3.19.0` |
| `flutter_secure_storage_windows` | 4.2.2 | Dart `>=3.3.0 <4.0.0`, Flutter `>=3.19.0` |
| `web_socket_channel` | 3.0.3 | Dart `^3.3.0` |

This resolution proves compatibility with the candidate; it does not prove every platform behavior. Official references: [Dart Pub Workspaces](https://dart.dev/tools/pub/workspaces), [`go_router_builder`](https://pub.dev/packages/go_router_builder), [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage), and [`web_socket_channel`](https://pub.dev/packages/web_socket_channel).

## Evidence log

All local evidence below was collected on Windows on 2026-10-15.

### Workspace resolution

`flutter pub get` at the root:

- created one root lockfile and one root package configuration;
- deleted nested scratch lockfiles/package configurations;
- listed exactly root, `scratch_package`, and `goal2_scratch_app`;
- resolved the app's `scratch_package: ^0.0.1` dependency to the local workspace member.

Legacy experiments ran in a disposable Git worktree:

| Membership | Result | Evidence/decision |
|---|---|---|
| Both legacy apps excluded | PASS | Scratch resolution, analyzer and tests passed |
| `admin_app` included through temporary workspace resolution | PASS | Resolution, analyzer and widget test passed |
| `user_app` included through temporary workspace resolution | FAIL | `flutter_lints ^5.0.0` conflicts with scratch app `^6.0.0` |

Decision: keep all legacy members excluded initially. `admin_app` is technically admissible after an explicit purpose is approved; `user_app` must pass baseline repair first.

### Typed routing

`go_router_builder` generated typed path and query handling for `/probe/:probeId?source=...`.

- First generation produced `routes.g.dart`.
- Second generation produced zero outputs.
- SHA-256 stayed `FB187EC92988EFE062088ECD786D2DB7A0BFA780A0A5728FD1EC3B0F2411F969` before later dependency-only changes.
- Analyzer and widget navigation test passed.
- `build_runner 2.15.1` warns that `--delete-conflicting-outputs` was removed; automation does not use that obsolete option.

### Secure storage

The integration probe deletes a unique key, writes a value, reads the same value, deletes it, and verifies a null read.

| Platform | Result | Status |
|---|---|---|
| Windows local debug runner | PASS | Manual-validation-required |
| Web Chrome 155 on localhost | PASS | Experimental |

Web remains Experimental because the plugin documents its WebCrypto implementation as experimental and requires HTTPS or localhost plus appropriate security headers. Windows remains Manual-validation-required until packaged-app lifecycle and upgrade behavior are validated; a passing round trip is not a production-readiness claim.

### Browser WebSocket authentication

Installed API source shows:

- the cross-platform/browser `WebSocketChannel.connect` accepts URI and subprotocols, not arbitrary headers;
- `IOWebSocketChannel.connect` separately supports headers on native platforms.

A headless Chrome integration test connected to a local server with a short-lived ticket in the handshake query. The server rejected missing/incorrect tickets and logged:

```text
ACCEPT origin=http://localhost:1500
```

Decision: browser adapters must not require an `Authorization` handshake header. Prefer a same-origin secure cookie when the backend can enforce Origin/CSRF policy; otherwise exchange the access token over HTTPS for a short-lived, single-use WebSocket ticket. Never place a long-lived access/refresh token in the URL.

### Local builds

| Platform | Command | Result |
|---|---|---|
| Android | `flutter build apk --debug --no-pub` | PASS |
| Web | `flutter build web --release --no-pub` | PASS, including Wasm dry run |
| Windows | `flutter build windows --release --no-pub` | PASS |
| iOS | macOS CI command | VERIFY |

## Melos decision

Melos `8.9.0` was temporarily resolved and successfully ran the experiment. It offers changed-package filtering, dependency-aware ordering, package filters, interactive selection, and publishing/version workflows beyond Pub Workspaces.

None is essential for the current small team and unpublished internal packages. The tested gates required separate Melos invocations for Dart and Flutter members, while `dart run tool/workspace.dart verify` used `dart pub workspace list --json` and ran format, analyze, test, and stable route generation in one command.

Decision: reject Melos for V2. The dependency was removed after the comparison. Reconsider only when changed-package selection, coordinated publishing/versioning, or dependency-ordered scripts become a measured need. The observed timings are not compared because caches were warm in different runs.

## CI pass/fail and fallbacks

The spike workflow has independent Android, iOS, Web and Windows matrix executions plus Web/Windows runtime probes.

| Gate | Pass | Failure fallback |
|---|---|---|
| Pinned SDK and root lockfile | Exact version and `--enforce-lockfile` resolve | Pin the last resolving SDK/dependency set; record incompatibility before change |
| Typed routes | First run current; second run byte-stable; Git diff empty | Pin compatible router/builder pair or defer typed routes; no handwritten/generated hybrid |
| Android build | CI APK succeeds | Diagnose SDK/plugin constraint; do not lower target silently |
| iOS build | CI no-codesign build succeeds | Pin compatible plugin/toolchain or mark affected capability Unsupported |
| Web build | CI release build succeeds | Remove/replace incompatible adapter; do not claim Web support from analyzer only |
| Windows build | CI release build succeeds | Split/omit unsupported adapter and mark capability status honestly |
| Runtime storage probes | Real plugin round trip succeeds | Use an app-owned unsupported adapter or reassess plugin; never silently use plaintext |
| Browser WebSocket | Server accepts one-time ticket and records Origin | Same-origin secure-cookie design or capability Unsupported until backend contract exists |

CI results and run URLs remain `VERIFY` until the branch is pushed and GitHub Actions completes.
