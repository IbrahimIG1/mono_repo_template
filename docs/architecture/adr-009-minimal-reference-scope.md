# ADR-009: `minimal_app` Is the Compact Integration Reference

Status: Accepted for Goal 4.5.

## Context

Goal 3 created `minimal_app` with all four foundation packages. Goal 4 then
added auth, typed routing, Bloc, and their app adapters. It is no longer a true
minimum dependency example, while renaming/moving its Android and iOS projects
now would create churn in completed evidence and CI. `showcase_app` already has
a separate migration purpose: it is the Goal 6 strangler target for `user_app`.

## Decision

The plan is amended:

- `minimal_app` keeps its historical name and becomes the compact V2 integration
  reference for foundation, authentication, networking replay, storage, and
  typed routing.
- It is not evidence that an app has the smallest possible dependency graph.
- `showcase_app` is not created early merely to repair naming. It remains the
  incremental migration host for `user_app` in Goal 6.
- The true minimum is continuously rehearsed by
  `tool/verify_temporary_consumer.dart`: a fresh app depends only on
  `platform_foundation`, `design_system`, and Flutter, then resolves, checks its
  dependency graph, analyzes, and builds Android.
- That gate rejects auth, networking, storage, Dio, Firebase, realtime, chat,
  socket, and legacy dependencies. New apps still opt into those capabilities
  explicitly.

## Consequences

Documentation must call `minimal_app` an integration reference, not a
dependency-minimum app. The temporary consumer is disposable and cannot replace
the Android/iOS reference app or runtime tests. A future rename is allowed only
if its migration value exceeds the platform-project and CI churn.
