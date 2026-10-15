# ADR-007: Goal 4 Authentication and Typed Routing

Status: Accepted and implemented.

## Decision

`auth_core` is a pure-Dart capability package. Credential types and remote
adapters remain app-owned; `AuthGateway<C>` makes mismatched credentials a
compile-time error. `BoundSignIn<C>` captures its gateway at composition time,
so presentation receives only `SignIn<C>`.

`SessionManager` is the sole session persistence owner. It serializes store
operations and refresh calls, compares the failed request token with the current
token, memoizes transient refresh failures for a bounded cooldown, and rejects
late results through a generation counter. Sign-out invalidates the generation,
clears local state and storage, then attempts remote revocation as best effort.

`auth_ui` is optional and owns only replaceable presentation state, validators,
and form primitives. Apps own screens, controllers, form keys, copy, branding,
and routing.

Networking owns a transport-neutral token provider/recovery boundary. The app
bridges it to `SessionManager`; neither capability package imports the other.
Eligible unauthorized requests replay at most once, using a fresh body factory
when a body exists. Cancellation and an absolute deadline cover refresh waiting
and replay without cancelling the shared refresh for other callers.

Each app owns a generated `go_router` route tree and one centralized redirect.
Only validated, allow-listed internal URIs are preserved through login. Route
payloads that must survive deep links use path/query parameters, not `$extra`.

## Dependency boundary

```text
app UI -> auth_ui -> auth_core -> platform_foundation
app adapters ------> auth_core
app bridges -------> auth_core + networking
app router --------> auth_core + go_router
networking --------------------> platform_foundation
```

`auth_core` must not depend on Flutter, Bloc, Dio, routers, or storage plugins.
`auth_ui` and app presentation must not mention `AuthGateway` or
`SessionGateway`. The architecture gate enforces these rules.

## Consequences and limits

- A backend-specific app supplies DTO/error mapping and decides which failures
  are terminal.
- The reference backend is deterministic and in-memory; it is not production
  authentication.
- Android/iOS deep-link registration still requires manual device validation.
  Widget tests prove router policy, not external launch behavior.
- Refresh cooldown is process-local. Cross-process coordination is deferred
  until a demonstrated multi-isolate requirement exists.
