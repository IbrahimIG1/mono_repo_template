# V2 Goal 1 Audit

Status: complete baseline snapshot; implementation has not started.

Snapshot date: 2026-10-15 (Africa/Cairo)

## Safety and checkpoint

- Baseline branch: `main`
- Baseline commit: `23c8af8d6cd51a7e07de009d054f1056790f6471`
- Baseline remote: `origin/main`
- Audit branch: `v2/goal-1-audit`
- The worktree was clean before the audit branch was created.
- The baseline commit is the rollback point. Goal 1 does not rewrite history, delete legacy code, or move packages.
- Audit changes remain uncommitted for user review. A commit/tag is created only through the normal project workflow.

Build commands generated only ignored build artifacts. Two timed-out builds left child processes; only the processes started by those audit commands were stopped.

## Toolchain snapshot

- Flutter: 3.44.1 stable, revision `924134a44c`
- Dart: 3.12.1 stable
- Host: Windows x64
- Locally available targets: Android emulator, Windows, Chrome and Edge
- iOS build validation is unavailable on this host and remains unverified until macOS CI runs.

## Repository inventory

The repository contains 584 tracked files and 137 tracked Dart files. The unexpectedly large tracked `.tmp_liquid_glass/` tree accounts for most tracked test/golden artifacts.

| Area | Current purpose | V2 disposition |
|---|---|---|
| `apps/user_app` | Feature-rich legacy/reference app | Keep running; migrate vertical slices into a new `showcase_app` using the strangler pattern |
| `apps/admin_app` | Generated counter-app skeleton | Keep outside the initial workspace; do not convert in place; remove or archive only after consumer/build checks |
| `core` | DI, networking, storage and mixed helpers | Keep at the same path as a compatibility facade until all consumers migrate |
| `shared` | Widgets, styles and shared models | Keep at the same path as a compatibility facade until all consumers migrate |
| `.tmp_liquid_glass` | Tracked copy of an experimental dependency, example, build-like files and goldens | Never admit to V2 workspace; candidate for later removal after reference and provenance checks |
| `.vscode/launch.json` | User/admin launch configurations | Keep, then repair during baseline work; admin entries currently point to nonexistent flavors/entrypoints |

### Applications and platforms

Both apps currently contain generated Android, iOS, Web, Windows, Linux and macOS directories. V2 now targets Android and iOS. Web and Windows validation is paused under ADR-008; no generated platform directory is deleted as a consequence of that scope change.

`user_app` has Android `dev` and `pro` product flavors. Equivalent iOS/Windows/Web flavor configuration is not present. `admin_app` has no flavors even though the VS Code launch configuration declares them.

No tracked `google-services.json`, `GoogleService-Info.plist`, generated `firebase_options.dart`, or Web messaging service worker was found.

### User application features

| Feature | Dart files | Current layers | Disposition |
|---|---:|---|---|
| Login | 10 | UI, Cubit, repository, request/response models | Preserve behavior; migrate through new auth contracts |
| Register | 13 | UI, Cubit, repository, request/response models | Preserve; Showcase-owned flow using auth primitives |
| OTP | 4 | Screen, Cubit, repository | Preserve; app-specific auth flow |
| Forget password | 4 | Screen, Cubit, repository inherited from OTP repo | Preserve; remove inheritance coupling during migration |
| Reset password | 5 | Screen, Cubit, repository, request model | Preserve; app-specific flow |
| Notifications | 12 | UI, Cubit, repository, Firebase factory, models | Preserve useful behavior; replace direct Firebase/UI coupling |
| Language | 4 | UI and Cubit | Preserve; move app-owned localization state out of infrastructure |
| Onboarding | 2 | Stateful screen and widget | Preserve visible behavior |
| Layout | 1 | Stateful navigation shell | Preserve navigation behavior; experimental glass UI is replace/review candidate |
| Home | 1 | Static/demo UI | Keep as Showcase content if still useful |

Current feature flow is generally `UI -> Cubit -> repository -> ApiServices`. Cubits and screens also access storage, navigation and Flutter controllers directly.

### Routes

Declared route names:

- `/onBoardingScreen`
- `/layoutScreen`
- `/home`
- `/login`
- `/register`
- `/otpScreen`
- `/forgetPassword`
- `/resetPassword`
- `/changeLangScreen`

OTP route generation is commented out. Route arguments use mutable string fields. The route generator owns error UI and process-exit behavior. There is no verified app-link/universal-link configuration.

### Storage keys

All keys have development and production variants derived from runtime `.env` state:

- `user_name`
- `user_phone`
- `user_id`
- `user_married_status`
- `user_allow_chat_status`
- `user_wasal_status`
- `user_has_subscribed`
- `profile_image`
- `user_token`
- `refreshToken`
- `welcome_screen`
- `language`

Tokens are stored through secure storage; other values use shared preferences. Current helpers are static, `clear()` can erase unrelated values, and secure storage logs token values. Migration must retain key compatibility until a tested storage migration succeeds.

### Environment and API configuration

Tracked asset files `.env_dev` and `.env_pro` contain a `BASE_URL` key. Their values were intentionally not copied into this audit. Client-bundled environment values must be treated as public configuration, never secrets.

Only these endpoint constants currently have consumers in the tracked app code:

- login, register, OTP, forget password and reset password;
- FCM token registration;
- notification list/count/read;
- media-image lookup.

Many additional constants describe profile, search, subscriptions, payment and chat APIs but currently have no tracked consumers. They are inventory, not proof that those capabilities are implemented.

### Assets and localization

Tracked user assets include two `.env` files, seven Plex font files, logos/splash images, one login SVG and one notification-empty SVG. Asset ownership is currently split incorrectly: `core/AppImages` points to app-owned paths.

Both ARB files are empty JSON objects. Generated localization sources exist, but there are no actual localized messages. The file `intl_en copy.arb` is also a naming/duplication candidate.

### Dependency observations

- `shared` depends on `core`, largely because shared presentation code imports app-image infrastructure.
- `core` includes Flutter UI helpers, Bloc, ScreenUtil and Firebase alongside networking/storage.
- `user_app` repeats many dependencies already supplied transitively by `core` or `shared`.
- SDK constraints differ: core/shared/user use Dart `^3.7.0`; admin uses `^3.10.8`.
- Every current package has its own lockfile; there is no root Pub Workspace.
- `liquid_glass_renderer ^0.2.0-dev.4` is experimental and is the observed cause of Web shader build failure.

## Baseline results

All commands used `--no-pub` where supported to avoid changing tracked lockfiles.

| Target | Command | Result |
|---|---|---|
| `core` | `flutter analyze --no-pub` | PASS, zero issues |
| `shared` | `flutter analyze --no-pub` | PASS, zero issues |
| `apps/user_app` | `flutter analyze --no-pub` | FAIL gate: 15 info findings |
| `apps/admin_app` | `flutter analyze --no-pub` | PASS, zero issues |
| `apps/user_app` | `flutter test --no-pub` | FAIL: test file has no `main` |
| `apps/admin_app` | `flutter test --no-pub` | FAIL: language-version/dot-shorthand compile error with current Flutter SDK |
| `apps/user_app` Web | debug build, development entrypoint | FAIL: `liquid_glass_renderer` SkSL shader compilation; Wasm dry run also reports incompatible Web dependencies |
| `apps/user_app` Windows | debug build, development entrypoint | TIMEOUT after four minutes; no executable produced |
| `apps/user_app` Android | debug dev APK | TIMEOUT after four minutes; no APK produced |
| `apps/admin_app` Web | debug build | FAIL: language-version/dot-shorthand compile error |
| iOS | local build | VERIFY: no macOS/Xcode host was available for validation |

The 15 user-app findings are: two overridden repository fields, four `withOpacity` deprecations, four deprecated radio APIs, five production `print` calls, and one private type exposed by a public API.

Timeouts are not treated as platform failures or successes. Goal 2 must rerun them in controlled CI with build logs and an explicit timeout policy.

## Initial workspace membership decision

No legacy package enters the first V2 Pub Workspace.

The Goal 2 spike starts with only a scratch `platform_foundation` and new `minimal_app`. This isolates workspace/tooling validation from known legacy failures. The spike must also verify that excluded sibling packages can retain independent resolution without shadowing or confusing the root workspace.

Legacy admission order:

1. new V2 foundation packages and `minimal_app`;
2. new optional capability packages;
3. `showcase_app` slices as they are created;
4. `core` and `shared` compatibility facades after their consumers and dependency direction are valid;
5. `user_app` only if retaining it as a workspace member still adds value;
6. `admin_app` only if an explicit product/reference purpose is approved.

`.tmp_liquid_glass` is never a workspace member.

## Admission rules

A package/app may use `resolution: workspace` only after all applicable gates pass:

1. SDK constraints match the pinned workspace baseline.
2. `dart pub get` resolves through the single root lockfile.
3. No nested lockfile or package configuration shadows the workspace.
4. Analyzer returns zero warnings, infos and errors under shared rules.
5. Every tracked test file is executable and all tests pass.
6. Direct and transitive local dependencies obey the approved direction and contain no cycle.
7. Generated sources are current and reproducible.
8. Apps pass required platform build gates or carry an explicit non-supported status.
9. Secrets are not tracked or bundled as client assets.
10. Compatibility behavior, storage keys and consumers are documented.

## Baseline repair backlog before legacy admission

- Resolve all 15 user-app analyzer findings.
- Replace the empty user-app test with meaningful smoke/contract tests.
- Align admin SDK/language configuration with the pinned Flutter toolchain and repair its tests/build.
- Remove or replace the experimental liquid-glass dependency only after visual consumer/parity review.
- Investigate the tracked `.tmp_liquid_glass` provenance, references and safe-removal evidence.
- Repair admin VS Code launch entries.
- Decide whether empty generated localization should be regenerated from real ARB content.
- Add or document required Firebase configuration per app/platform; do not add credentials to shared packages.
- Re-run Android builds with CI-grade timeouts and full logs; validate iOS on macOS CI.

## Locked architecture decisions

The contracts and ownership decisions required by Goal 1 are recorded in:

- [`ADR-001: Foundation results, failures, and JSON`](../architecture/adr-001-foundation-contracts.md)
- [`ADR-002: Authentication, refresh, and request replay`](../architecture/adr-002-auth-session-and-replay.md)
- [`ADR-003: Composition, compatibility, and workspace admission`](../architecture/adr-003-composition-and-migration.md)
- [`ADR-004: Chat event-source boundary`](../architecture/adr-004-chat-event-boundary.md)

## Goal 2 entry checklist

- Goal 1 documentation is reviewed.
- The audit branch is clean or its documentation changes are checkpointed.
- No user changes are pending without an owner.
- Spike work is isolated from legacy source migration.
- The spike validates workspace resolution, typed routes, Android/iOS builds,
  mobile secure-storage integration assumptions and Melos-versus-Dart
  orchestration. Historical paused-platform probes do not remain current exit
  criteria.
- A failed spike selects a documented fallback; it does not silently lower a capability claim.
