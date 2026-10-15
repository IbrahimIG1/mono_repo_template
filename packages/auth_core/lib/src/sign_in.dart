import 'package:platform_foundation/platform_foundation.dart';

import 'auth_gateway.dart';
import 'auth_session.dart';
import 'session_manager.dart';

abstract interface class SignIn<C extends AuthCredential> {
  Future<Result<AuthSession>> call(C credential);
}

final class BoundSignIn<C extends AuthCredential> implements SignIn<C> {
  factory BoundSignIn({
    required AuthGateway<C> gateway,
    required SessionManager sessionManager,
  }) => BoundSignIn._(gateway, sessionManager);

  const BoundSignIn._(this._gateway, this._sessionManager);

  final AuthGateway<C> _gateway;
  final SessionManager _sessionManager;

  @override
  Future<Result<AuthSession>> call(C credential) async {
    final generation = _sessionManager.generation;
    final result = await _gateway.authenticate(credential);
    return switch (result) {
      Failure<AuthSession>(:final failure) => Failure(failure),
      Success<AuthSession>(:final value) => _sessionManager.establish(
        value,
        expectedGeneration: generation,
      ),
    };
  }
}

abstract interface class SignOut {
  Future<void> call();
}

final class SessionSignOut implements SignOut {
  const SessionSignOut(this._sessionManager);

  final SessionManager _sessionManager;

  @override
  Future<void> call() => _sessionManager.signOut();
}
