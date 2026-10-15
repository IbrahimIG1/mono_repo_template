import 'auth_session.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthUninitialized extends AuthState {
  const AuthUninitialized();

  @override
  bool operator ==(Object other) => other is AuthUninitialized;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class AuthRestoring extends AuthState {
  const AuthRestoring();

  @override
  bool operator ==(Object other) => other is AuthRestoring;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  @override
  bool operator ==(Object other) => other is AuthUnauthenticated;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);

  final AuthSession session;

  @override
  bool operator ==(Object other) =>
      other is AuthAuthenticated && session == other.session;

  @override
  int get hashCode => Object.hash(runtimeType, session);
}

final class AuthRefreshing extends AuthState {
  const AuthRefreshing(this.previousSession);

  final AuthSession previousSession;

  @override
  bool operator ==(Object other) =>
      other is AuthRefreshing && previousSession == other.previousSession;

  @override
  int get hashCode => Object.hash(runtimeType, previousSession);
}
