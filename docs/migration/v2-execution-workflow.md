# V2 Execution Workflow: One Goal Per Phase

Status: Active. ADR-008 makes V2 mobile-first; Web and Windows validation is
paused. Complete, verify, integrate, and checkpoint one goal before starting the
next. Goals 1 through 4.5 are closed; Goal 5 is awaiting final CI and integration.

Every goal follows the Git lifecycle in `AGENTS.md`. Existing mobile tests and
quality gates remain mandatory even when a capability is not part of that goal.

## Goal 1 — Plan lock, safety, and audit (complete)

Inventory legacy behavior and lock ownership, dependency direction, migration,
security, and tooling decisions before structural work. Exit evidence is the
Goal 1 audit and ADR-001 through ADR-004. Checkpoint: Goal 1 commit/tag.

## Goal 2 — Toolchain and workspace spike (complete)

Timebox workspace resolution, typed route generation, runner selection, and
Android/iOS build feasibility. A repeat of the spike passes only when one root
resolution works, second route generation is clean, Android and iOS builds pass,
and the runner decision is evidence-backed. Paused targets are not exit gates.
Checkpoint: Goal 2 commit/tag plus a provenance tag on the probe commit.

## Goal 3 — Foundation and first app (complete)

Deliver `platform_foundation`, `networking`, `storage`, `design_system`, the app
composition root, and automated architecture boundaries.

Exit criteria:

- root/workspace formatting, analyzer, tests, generation, dependency-cycle, and
  forbidden-dependency gates pass;
- Android debug and iOS no-codesign builds pass;
- a disposable consumer is created, resolved, analyzed, tested, and built for
  Android from documentation only;
- legacy packages remain outside workspace admission and core contracts remain
  pure Dart;
- no Firebase, realtime, chat, socket, or legacy dependency enters the minimal
  dependency proof.

## Goal 4 — Authentication and typed routing (complete)

Deliver pure-Dart auth/session contracts, typed sign-in, serialized refresh,
request replay policy, app-owned persistence adapter, generated routes, auth
redirects, and mobile deep-link policy. Exit requires the concurrency, stale
generation, sign-out, storage-error, destination-policy, route-generation,
architecture, Android, and iOS gates recorded in the Goal 4/4.5 evidence.

## Goal 4.5 — Verification closure (complete)

Close destination-policy and restore error cases, secret-safe credential
diagnostics, offline architecture checks with negative fixtures, honest root
gates, legacy secret logging, the tracked temporary dependency tree, minimal-app
scope, checkpoints, clean-clone instructions, and an evidence-based Goals 1–4
verification report. No Goal 5 implementation belongs here.

## Goal 5 — Notifications, notification routing, and realtime contracts (verification)

Deliver `notifications_core`, the optional mobile FCM adapter, app-owned
destination mapping/coordinator, `realtime_core`, one selected transport adapter,
and fakes/contract tests. Firebase and realtime remain opt-in and must not enter
the minimal dependency proof transitively.

Exit criteria:

- notification parsing, deduplication, router/session readiness, protected
  destination restoration, and realtime lifecycle/reconnect contracts pass;
- the FCM background handler is a top-level entry point and constructs only its
  own background dependencies, never foreground DI;
- Android 13+ notification permission behavior is implemented and tested where
  automation permits;
- iOS APNs/Firebase setup is documented without committing credentials;
- push receipt/interaction and external deep links remain
  `Manual-validation-required` until physical-device evidence is recorded for
  Android and iOS;
- root gates and Android/iOS CI remain green.

## Goal 6 — Reference app migration

Create `showcase_app` through bounded strangler slices from `user_app`. Preserve
legacy paths and compatibility exports until behavior, storage, routes, assets,
and mobile builds reach documented parity. Do not convert `user_app` or
`admin_app` in place.

## Goal 7 — V2 stabilization and release

Finish reference documentation, package APIs, new-app rehearsal, migration
records, supported capability claims, and legacy-removal decisions. Chat is not
part of this release.

Exit criteria:

- clean-clone bootstrap and documented Android/iOS workflows pass;
- root quality, architecture, contract, generation, Android, and iOS CI gates
  are green at the release commit;
- the matrix uses only `Supported`, `Unsupported`, `Experimental`, or
  `Manual-validation-required`, with evidence for every non-unsupported mobile
  claim;
- rollback checkpoints and migration/parity evidence exist before any legacy
  removal;
- Web and Windows folders remain intact while their matrix state is
  `Unsupported` with the note `paused`.

## V2.1 — Chat program (separate release)

Plan and deliver the chat engine, durable outbox/reconciliation, media package
with sub-libraries, and optional `chat_ui` as its own project. V2 release health
is an entry criterion; chat cannot delay or redefine V2 completion.
