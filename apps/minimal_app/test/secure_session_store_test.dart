import 'dart:convert';

import 'package:auth_core/auth_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_app/src/auth/secure_session_store.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:storage/storage.dart';

void main() {
  test('round-trips a session as one secure value', () async {
    final secureStore = _MemorySecureStore();
    final store = SecureSessionStore(
      secureStore: secureStore,
      storageKey: 'session',
    );

    expect(await store.write(_session), isA<Success<void>>());
    final restored = await store.read();

    expect((restored as Success<AuthSession?>).value, _session);
    expect(secureStore.values.keys, ['session']);
  });

  test('rejects missing required fields without coercion', () async {
    final secureStore = _MemorySecureStore(
      initialValues: {
        'session': jsonEncode({
          'accessToken': 42,
          'refreshToken': 'refresh',
          'subjectId': 'user',
          'expiresAt': '2026-10-15T14:00:00.000Z',
        }),
      },
    );
    final store = SecureSessionStore(
      secureStore: secureStore,
      storageKey: 'session',
    );

    final result = await store.read();

    expect(result, isA<Failure<AuthSession?>>());
    expect(
      (result as Failure<AuthSession?>).failure.code,
      'auth.session_decode',
    );
  });

  test('ignores unknown fields', () async {
    final secureStore = _MemorySecureStore(
      initialValues: {
        'session': jsonEncode({
          'accessToken': 'access',
          'refreshToken': 'refresh',
          'subjectId': 'user',
          'expiresAt': '2026-10-15T14:00:00.000Z',
          'futureField': true,
        }),
      },
    );
    final store = SecureSessionStore(
      secureStore: secureStore,
      storageKey: 'session',
    );

    expect(await store.read(), isA<Success<AuthSession?>>());
  });
}

final class _MemorySecureStore implements SecureStringStore {
  _MemorySecureStore({Map<String, String>? initialValues})
    : values = {...?initialValues};

  final Map<String, String> values;

  @override
  Future<Result<String?>> read(String key) async => Success(values[key]);

  @override
  Future<Result<void>> remove(String key) async {
    values.remove(key);
    return const Success(null);
  }

  @override
  Future<Result<void>> write(String key, String value) async {
    values[key] = value;
    return const Success(null);
  }
}

final _session = AuthSession(
  accessToken: 'access',
  refreshToken: 'refresh',
  subjectId: 'user',
  expiresAt: DateTime.utc(2026, 10, 15, 14),
);
