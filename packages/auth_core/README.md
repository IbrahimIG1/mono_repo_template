# auth_core

Framework-neutral authentication contracts and session orchestration.

Public API includes typed `AuthGateway<C>`, `SessionGateway`, `SessionStore`,
`SignIn<C>`, `SignOut`, `AuthSession`, exhaustive auth states, and
`SessionManager`. The manager is the only session persistence owner. It
serializes store operations and token refresh, rejects stale generations, and
applies a cooldown after transient refresh failures.

Apps bind credential-specific gateways and implement `SessionStore`. UI code
depends on `SignIn<C>` and `SignOut`, never gateways. The package has no
Flutter, Dio, router, Bloc, or storage-plugin dependency.

Fakes are available from `package:auth_core/testing.dart` for contract and app
tests.
