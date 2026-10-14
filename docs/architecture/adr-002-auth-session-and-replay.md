# ADR-002: Authentication, Session Ownership, and Request Replay

Status: Accepted for V2 spike and implementation.

## Ownership

| Concern | Owner |
|---|---|
| Remote sign-in, refresh and revocation calls | App-owned typed gateway adapters |
| Backend DTO parsing/mapping | App-owned gateway adapters |
| Current session and auth state | `SessionManager` in `auth_core` |
| Persisting/clearing the session | `SessionManager` through an app-owned `SessionStore` |
| Attaching a token to HTTP requests | Networking through `AccessTokenProvider` |
| Recovering from an unauthorized response | Networking calls `UnauthorizedRecovery` |
| Auth redirects | App router observing auth state |
| Form/controller lifecycle | Presentation layer |

`SessionStore` is defined by `auth_core`. The app implements it by adapting the `storage` package's `SecureStore`. Neither package imports the other.

## Typed sign-in

Presentation receives a typed use case, never a gateway or service locator.

```dart
abstract interface class AuthCredential {
  const AuthCredential();
}

abstract interface class AuthGateway<C extends AuthCredential> {
  Future<Result<AuthSession>> authenticate(C credential);
}

abstract interface class SignIn<C extends AuthCredential> {
  Future<Result<AuthSession>> call(C credential);
}

abstract interface class SessionGateway {
  Future<Result<AuthSession>> refresh(String refreshToken);
  Future<Result<void>> revoke(String refreshToken);
}
```

The app binds `SignIn<C>` to the matching gateway and session coordinator at its composition root. No runtime credential cast or type map is allowed.

## Session and recovery contracts

```dart
abstract interface class SessionStore {
  Future<AuthSession?> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}

abstract interface class AccessTokenProvider {
  Future<String?> accessToken();
}

abstract interface class UnauthorizedRecovery {
  Future<Result<String>> recoverAccessToken({
    required String? failedAccessToken,
  });
}

abstract interface class SessionManager implements UnauthorizedRecovery {
  AuthState get current;
  Stream<AuthState> get states;

  Future<void> restore();
  Future<Result<AuthSession>> establish(AuthSession session);
  Future<void> signOut();
}
```

`SessionManager` owns restore, session establishment, serialized refresh and local sign-out. Infrastructure-level session coordination methods are not injected into Cubits; Cubits receive typed use cases.

`SessionGateway` is constructor-injected into `SessionManager`. `SignIn<C>` calls its typed `AuthGateway<C>` and, on success, calls `SessionManager.establish`; presentation never receives either gateway. The manager writes a session before publishing it as authenticated.

## Auth state transitions

Form submission/loading/error state belongs to the sign-in Cubit and is not duplicated in `AuthState`.

| Current state | Event | Next published state | Required effect |
|---|---|---|---|
| `uninitialized` | `restore()` starts | `restoring` | Read `SessionStore` once |
| `restoring` | no valid stored session | `unauthenticated` | Clear invalid stored data when necessary |
| `restoring` | valid stored session | `authenticated(session)` | Make the restored session current |
| `unauthenticated` | successful `establish` | `authenticated(session)` | Persist atomically before publishing |
| `authenticated(old)` | refresh starts | `refreshing(old)` | Share one in-flight refresh future |
| `refreshing(old)` | refresh succeeds | `authenticated(new)` | Persist replacement before publishing |
| `refreshing(old)` | transient failure | `authenticated(old)` | Return failure and enforce the retry cooldown |
| `refreshing(old)` | terminal rejection | `unauthenticated` | Clear the persisted session |
| any state | `signOut()` | `unauthenticated` | Increment generation and clear locally before best-effort revoke |

Repeated `restore()` calls after initialization return without rereading unless an explicit future reset API is approved. State emissions are distinct by semantic value; a stale operation from an older generation emits nothing.

## Refresh algorithm

1. Networking passes the exact access token used by the failed request, or `null` when none was attached.
2. If no token was attached, return a typed unauthorized failure without refreshing.
3. If the current stored token is different, return it without refreshing.
4. If a refresh is active, return the same in-flight future.
5. Otherwise create one refresh future and publish it before awaiting network I/O.
6. The refresh request bypasses unauthorized recovery.
7. On success, persist the full replacement session atomically, then publish authenticated state.
8. On terminal rejection, clear local session and publish unauthenticated state.
9. On transient failure, keep the session for possible recovery but memoize/back off the failure; do not start an immediate refresh storm.
10. Clear the in-flight future in `finally` only if it is still the active operation.

Every session-changing operation captures a monotonically increasing generation. Sign-out increments it before awaiting any I/O. Results from older generations are discarded and never persisted.

## Local-first sign-out

Sign-out order is:

1. copy the in-memory refresh token needed for revocation, without reading storage or doing I/O;
2. increment generation and prevent new authenticated work;
3. clear local session/store;
4. publish unauthenticated state;
5. attempt server revocation with the copied token as best effort.

Revocation failure is reported diagnostically but never restores local authentication.

## Request replay policy

- A request may be replayed at most once after successful recovery.
- The replay uses the replacement token returned by recovery.
- A replayed 401 is returned to the caller; it never starts another interceptor loop.
- Refresh/revocation endpoints opt out of recovery.
- Only replayable bodies are retried. Streamed uploads and one-shot bodies fail with a typed `request_not_replayable` failure unless the caller supplies a body factory.
- Cancellation and deadlines propagate through refresh waiting and replay.
- Non-auth transient retries are a separate policy; they do not share the unauthorized replay counter.

## Required concurrency tests

- Twenty concurrent requests with the same failed token cause exactly one refresh.
- All eligible requests await the same result and replay no more than once.
- A delayed 401 using an old token after refresh returns the current token without another refresh.
- A 401 from a request without an attached token does not start refresh.
- Refresh failure is shared and respects backoff/failure memoization.
- Refresh endpoint 401 cannot recurse.
- Sign-out during sign-in/refresh wins; late success cannot persist a session.
- A non-replayable request is not silently resent.

## Security

Tokens, passwords, authorization headers and refresh payloads are always redacted. Values bundled in client assets or `dart-define` are configuration, not secrets.
