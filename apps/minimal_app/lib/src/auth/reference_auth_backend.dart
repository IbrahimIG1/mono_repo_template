import 'package:auth_core/auth_core.dart';
import 'package:platform_foundation/platform_foundation.dart';

import 'email_password_credential.dart';

final class ReferenceAuthBackendConfiguration {
  const ReferenceAuthBackendConfiguration({
    this.minimumPasswordLength = 8,
    this.sessionLifetime = const Duration(minutes: 30),
    this.simulatedLatency = Duration.zero,
  });

  final int minimumPasswordLength;
  final Duration sessionLifetime;
  final Duration simulatedLatency;
}

final class ReferenceAuthBackend {
  ReferenceAuthBackend({
    required this.configuration,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ReferenceAuthBackendConfiguration configuration;
  final DateTime Function() _clock;
  final Set<String> _activeRefreshTokens = {};
  var _sequence = 0;

  Future<Result<AuthSession>> authenticate(
    EmailPasswordCredential credential,
  ) async {
    await _latency();
    if (!_isValidEmail(credential.email) ||
        credential.password.length < configuration.minimumPasswordLength) {
      return const Failure(
        AuthFailure(
          kind: AuthFailureKind.invalidCredentials,
          code: 'auth.invalid_credentials',
          message: 'The supplied credentials are invalid.',
        ),
      );
    }
    return Success(_createSession(credential.email.trim().toLowerCase()));
  }

  Future<Result<AuthSession>> refresh(String refreshToken) async {
    await _latency();
    if (!_activeRefreshTokens.remove(refreshToken)) {
      return const Failure(
        AuthFailure(
          kind: AuthFailureKind.invalidSession,
          code: 'auth.refresh_rejected',
          message: 'The refresh token is no longer valid.',
        ),
      );
    }
    return Success(_createSession('reference-user'));
  }

  Future<Result<void>> revoke(String refreshToken) async {
    await _latency();
    _activeRefreshTokens.remove(refreshToken);
    return const Success(null);
  }

  AuthSession _createSession(String subjectId) {
    final id = ++_sequence;
    final refreshToken = 'reference-refresh-$id';
    _activeRefreshTokens.add(refreshToken);
    return AuthSession(
      accessToken: 'reference-access-$id',
      refreshToken: refreshToken,
      subjectId: subjectId,
      expiresAt: _clock().toUtc().add(configuration.sessionLifetime),
    );
  }

  bool _isValidEmail(String email) {
    final normalized = email.trim();
    final separator = normalized.indexOf('@');
    return separator > 0 && separator < normalized.length - 1;
  }

  Future<void> _latency() =>
      Future<void>.delayed(configuration.simulatedLatency);
}

final class ReferenceEmailPasswordAuthGateway
    implements AuthGateway<EmailPasswordCredential> {
  const ReferenceEmailPasswordAuthGateway(this.backend);

  final ReferenceAuthBackend backend;

  @override
  Future<Result<AuthSession>> authenticate(
    EmailPasswordCredential credential,
  ) => backend.authenticate(credential);
}

final class ReferenceSessionGateway implements SessionGateway {
  const ReferenceSessionGateway(this.backend);

  final ReferenceAuthBackend backend;

  @override
  Future<Result<AuthSession>> refresh(String refreshToken) =>
      backend.refresh(refreshToken);

  @override
  Future<Result<void>> revoke(String refreshToken) =>
      backend.revoke(refreshToken);
}
