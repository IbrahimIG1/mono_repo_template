# V2 Goal 5: Notifications and Realtime

Status: complete on the Goal 5 branch; main integration and checkpoint evidence
are recorded below.

## Delivered boundary

- `notifications_core` owns framework-neutral client, message, interaction,
  permission, versioned payload-decoding, and durable deduplication contracts.
- `notifications_fcm` is an optional Android/iOS adapter. Firebase project files
  and credentials remain app-owned and none are committed by the template.
- `minimal_app` demonstrates app-owned destination mapping and a serialized
  pending-interaction coordinator. It waits for router/session readiness,
  preserves a protected destination through login, and re-authorizes it before
  navigation.
- The FCM background entry point is top-level and builds only its background
  dependencies. It does not read the foreground composition root.
- Android 13+ permission mapping is covered by adapter tests. iOS APNs and
  Firebase setup, including the iOS 15 deployment target required by the pinned
  Firebase packages, is documented in the mobile notifications guide.
- `realtime_core` owns transport-neutral client, codec, authentication,
  subscription, cancellation, ordering, overflow, and lifecycle contracts.
- `realtime_websocket` is the one V2 transport. It uses `dart:io`, bounded
  reconnect with jitter, heartbeat, cancellation, restored subscriptions, and
  disposal that prevents later public events.

Chat, presence, Socket.IO, production Firebase configuration, and physical
device validation are not part of Goal 5. Push, deep links, and the WebSocket
transport therefore remain `Manual-validation-required` in the capability
matrix.

## Race handling and trade-offs

- Concurrent FCM initialization shares one in-flight operation, so it installs
  one set of listeners and performs one initial-interaction lookup.
- Notification interactions are serialized. One malformed item, mapper error,
  or diagnostic-observer error is isolated and cannot poison later items.
- Interaction IDs are claimed through a durable, bounded ledger before routing;
  a failed persistence write does not falsely claim the interaction.
- Concurrent explicit WebSocket `connect()` calls, including a call during
  automatic reconnect, join the active operation instead of opening a second
  socket.
- Reconnect count and delay are bounded and jitter is injected for deterministic
  tests. At-most-once local stream delivery is provided; reconnect does not
  claim server history recovery, so applications must resynchronize their API
  source of truth.
- Event buffering is bounded and configurable as drop-oldest, drop-newest, or
  disconnect. This avoids unbounded memory growth but makes loss visible and
  deliberate under pressure.

## Automated evidence

Evidence collected on Windows on 2026-10-19 against commit `cfdd451` (the source
candidate) and final CI commit `d803ceb`:

| Gate | Command | Result |
|---|---|---|
| Locked resolution | `flutter pub get --enforce-lockfile` | PASS |
| Workspace format/analyze/tests/routes | `dart run tool/workspace.dart verify` | PASS; all admitted-package tests passed and the second route generation wrote zero outputs |
| Root analyzer | `dart analyze --fatal-warnings --fatal-infos` | PASS; zero findings |
| Architecture fixture tests | `dart test tool/test` | PASS; 5 tests |
| Offline dependency/source boundaries | `dart run tool/check_architecture.dart` | PASS |
| True-minimum consumer | `dart run tool/verify_temporary_consumer.dart` | PASS; resolved, analyzed, and built Android without optional capabilities |
| Optional capability rehearsal | `dart run tool/verify_optional_capabilities.dart --android` | PASS; FCM/realtime opt-in and complete removal both resolved, analyzed, and built |
| Repository diff | `git diff --exit-code` | PASS |
| Documented clean clone | README commands, in order, from a `git clone --no-local` temporary clone | PASS in 179.3 seconds |

The clean-clone run executed 21 `minimal_app`, 15 `auth_core`, 4 `auth_ui`,
1 `design_system`, 8 `networking`, 9 `notifications_core`, 6
`notifications_fcm`, 3 `platform_foundation`, 5 `realtime_core`, 5
`realtime_websocket`, and 1 `storage` tests. The WebSocket suite used a real
deterministic local server. No test was skipped or weakened.

The Android rehearsal emitted a Flutter warning that the pinned `firebase_core`
plugin still applies the Kotlin Gradle Plugin and should migrate to built-in
Kotlin. The build passed; this warning is retained here as upgrade debt rather
than suppressed.

An independent read-only review was requested after implementation. It found
three concurrency/error-isolation defects: duplicate WebSocket connection risk
during reconnect, duplicate FCM listener installation during concurrent
initialization, and a notification failure poisoning the serialized queue. Each
finding was fixed with a deterministic regression test, then the focused
read-only re-review passed those cases. A later observer-error case was also
isolated and regression-tested before this final verification.

## CI and platform evidence

- Branch Android/quality workflow:
  [run 39294681677](https://github.com/IbrahimIG1/mono_repo_template/actions/runs/39294681677)
  — PASS on `d803ceb`.
- Branch iOS no-codesign workflow:
  [run 39294681735](https://github.com/IbrahimIG1/mono_repo_template/actions/runs/39294681735)
  — PASS on `d803ceb` using Xcode 26.

These compile and contract-test mobile integrations; they are not physical
device proof. The main-branch merge runs and checkpoint tag are appended during
integration so the record points at the exact authoritative commit.

## Honest execution notes

- An initial clean-clone attempt earlier in Goal 5 used Git's local-clone
  optimization across Windows volumes and failed with `Improper link`; the
  documented proof uses `--no-local` and passed.
- An early manual `flutter test apps/minimal_app` invocation selected generated
  build artifacts. Package-scoped workspace commands were then used; no gate or
  source test was removed.
- The optional-capability rehearsal initially exposed iOS deployment-target and
  diagnostic gaps. A later iOS run also showed that `flutter analyze` after the
  opt-in build scanned Dart fixtures inside Swift Package Manager's generated
  `build/ios/SourcePackages` checkout. Because `flutter pub get` can materialize
  that checkout before the build starts, the disposable app now analyzes its
  owned `lib/` source explicitly, while still removing the generated `build/`
  tree before proving the opt-out build. Source scope, cleanup, and deployment-
  target behavior have unit tests, and failing command output is preserved.
- The Intel macOS 15 runner then proved too old for Firebase iOS SDK 13's Swift
  tools 6.2.1 manifest. CI is pinned to GitHub's GA `macos-26` standard runner,
  whose official image inventory provides Xcode 26. This is a toolchain
  compatibility requirement, not a runtime-support claim.
- Physical-device push receipt, notification taps from foreground/background/
  terminated states, APNs provisioning, and OS deep-link launch behavior were
  not run because this environment has no provisioned Android/iOS devices or
  production Firebase project. Their matrix status remains
  `Manual-validation-required`.
