import 'package:platform_foundation/platform_foundation.dart';

enum AuthFailureKind {
  cooldown,
  invalidCredentials,
  invalidSession,
  invalidStoredSession,
  missingSession,
  missingToken,
  staleOperation,
  storage,
  transient,
  unexpected,
}

final class AuthFailure extends AppFailure {
  const AuthFailure({
    required this.kind,
    required super.code,
    required super.message,
    super.cause,
    super.stackTrace,
  });

  factory AuthFailure.staleOperation() => const AuthFailure(
    kind: AuthFailureKind.staleOperation,
    code: 'auth.stale_operation',
    message: 'The authentication operation is no longer current.',
  );

  final AuthFailureKind kind;
}
