import 'dart:convert';

import 'package:auth_core/auth_core.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:storage/storage.dart';

final class SecureSessionStore implements SessionStore {
  factory SecureSessionStore({
    required SecureStringStore secureStore,
    required String storageKey,
  }) => SecureSessionStore._(secureStore, storageKey);

  const SecureSessionStore._(this._secureStore, this._storageKey);

  final SecureStringStore _secureStore;
  final String _storageKey;

  @override
  Future<Result<void>> clear() => _secureStore.remove(_storageKey);

  @override
  Future<Result<AuthSession?>> read() async {
    final result = await _secureStore.read(_storageKey);
    return switch (result) {
      Failure<String?>(:final failure) => Failure(failure),
      Success<String?>(value: null) => const Success(null),
      Success<String?>(:final value?) => _decode(value),
    };
  }

  @override
  Future<Result<void>> write(AuthSession session) => _secureStore.write(
    _storageKey,
    jsonEncode({
      'accessToken': session.accessToken,
      'refreshToken': session.refreshToken,
      'subjectId': session.subjectId,
      'expiresAt': session.expiresAt.toUtc().toIso8601String(),
    }),
  );

  Result<AuthSession?> _decode(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Session JSON must be an object.');
      }
      final accessToken = _requiredString(decoded, 'accessToken');
      final refreshToken = _requiredString(decoded, 'refreshToken');
      final subjectId = _requiredString(decoded, 'subjectId');
      final expiresAtSource = _requiredString(decoded, 'expiresAt');
      final expiresAt = DateTime.tryParse(expiresAtSource)?.toUtc();
      if (expiresAt == null) {
        throw const FormatException('expiresAt must be an ISO-8601 timestamp.');
      }
      return Success(
        AuthSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          subjectId: subjectId,
          expiresAt: expiresAt,
        ),
      );
    } on Object catch (error, stackTrace) {
      return Failure(
        AuthFailure(
          kind: AuthFailureKind.invalidStoredSession,
          code: 'auth.session_decode',
          message: 'The persisted session is invalid.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  String _requiredString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('$key must be a non-empty string.');
    }
    return value;
  }
}
