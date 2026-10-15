import 'dart:async';

import 'package:auth_core/auth_core.dart';
import 'package:auth_core/testing.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:test/test.dart';

void main() {
  group('SessionManager', () {
    test('restores once and publishes semantic state transitions', () async {
      final store = MemorySessionStore(initialSession: _oldSession);
      final gateway = _gateway((_) async => Success(_newSession));
      final manager = SessionManager(
        store: store,
        gateway: gateway,
        clock: () => DateTime.utc(2026, 10, 15, 12),
      );
      final states = <AuthState>[];
      final subscription = manager.states.listen(states.add);

      expect(await manager.restore(), isA<Success<void>>());
      expect(await manager.restore(), isA<Success<void>>());

      expect(store.readCount, 1);
      expect(states, [const AuthRestoring(), AuthAuthenticated(_oldSession)]);
      await subscription.cancel();
      await manager.dispose();
    });

    test(
      'expired restored session is cleared before unauthenticated',
      () async {
        final expired = AuthSession(
          accessToken: 'expired-access',
          refreshToken: 'expired-refresh',
          subjectId: 'user-1',
          expiresAt: DateTime.utc(2026, 10, 15, 11),
        );
        final store = MemorySessionStore(initialSession: expired);
        final manager = SessionManager(
          store: store,
          gateway: _gateway((_) async => Success(_newSession)),
          clock: () => DateTime.utc(2026, 10, 15, 12),
        );

        await manager.restore();

        expect(store.clearCount, 1);
        expect(manager.current, const AuthUnauthenticated());
        await manager.dispose();
      },
    );

    test('inaccessible storage read fails restore without clearing', () async {
      final readFailure = _storageFailure('auth.storage_read_failed');
      final store = _RestoreFailureStore(readFailure: readFailure);
      final manager = SessionManager(
        store: store,
        gateway: _gateway((_) async => Success(_newSession)),
      );

      final result = await manager.restore();

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).failure, same(readFailure));
      expect(store.clearCount, 0);
      expect(manager.current, const AuthUnauthenticated());
      await manager.dispose();
    });

    test('corrupt stored data is cleared and reports corruption', () async {
      final corruptFailure = const AuthFailure(
        kind: AuthFailureKind.invalidStoredSession,
        code: 'auth.invalid_stored_session',
        message: 'Stored session data is corrupt.',
      );
      final store = _RestoreFailureStore(readFailure: corruptFailure);
      final manager = SessionManager(
        store: store,
        gateway: _gateway((_) async => Success(_newSession)),
      );

      final result = await manager.restore();

      expect((result as Failure<void>).failure, same(corruptFailure));
      expect(store.clearCount, 1);
      expect(manager.current, const AuthUnauthenticated());
      await manager.dispose();
    });

    test('clear failure while removing corrupt data is returned', () async {
      const corruptFailure = AuthFailure(
        kind: AuthFailureKind.invalidStoredSession,
        code: 'auth.invalid_stored_session',
        message: 'Stored session data is corrupt.',
      );
      final clearFailure = _storageFailure('auth.storage_clear_failed');
      final store = _RestoreFailureStore(
        readFailure: corruptFailure,
        clearFailure: clearFailure,
      );
      final manager = SessionManager(
        store: store,
        gateway: _gateway((_) async => Success(_newSession)),
      );

      final result = await manager.restore();

      expect((result as Failure<void>).failure, same(clearFailure));
      expect(store.clearCount, 1);
      expect(manager.current, const AuthUnauthenticated());
      await manager.dispose();
    });

    test('concurrent restore calls share the same failure result', () async {
      final readFailure = _storageFailure('auth.storage_read_failed');
      final store = _RestoreFailureStore(readFailure: readFailure);
      final manager = SessionManager(
        store: store,
        gateway: _gateway((_) async => Success(_newSession)),
      );

      final results = await Future.wait([manager.restore(), manager.restore()]);

      expect(store.readCount, 1);
      expect(
        results.map((result) => (result as Failure<void>).failure),
        everyElement(same(readFailure)),
      );
      await manager.dispose();
    });

    test('twenty concurrent unauthorized requests share one refresh', () async {
      final completer = Completer<Result<AuthSession>>();
      final gateway = _gateway((_) => completer.future);
      final store = MemorySessionStore(initialSession: _oldSession);
      final manager = SessionManager(store: store, gateway: gateway);
      await manager.restore();

      final recoveries = List.generate(
        20,
        (_) => manager.recoverAccessToken(
          failedAccessToken: _oldSession.accessToken,
        ),
      );
      expect(gateway.refreshCallCount, 1);

      completer.complete(Success(_newSession));
      final results = await Future.wait(recoveries);

      expect(gateway.refreshCallCount, 1);
      expect(
        results.map((result) => (result as Success<String>).value),
        everyElement(_newSession.accessToken),
      );
      expect(store.session, _newSession);
      await manager.dispose();
    });

    test(
      'a stale-token 401 returns the current token without refresh',
      () async {
        final gateway = _gateway((_) async => Success(_newSession));
        final manager = SessionManager(
          store: MemorySessionStore(initialSession: _oldSession),
          gateway: gateway,
        );
        await manager.restore();

        await manager.recoverAccessToken(
          failedAccessToken: _oldSession.accessToken,
        );
        final delayed = await manager.recoverAccessToken(
          failedAccessToken: _oldSession.accessToken,
        );

        expect(gateway.refreshCallCount, 1);
        expect((delayed as Success<String>).value, _newSession.accessToken);
        await manager.dispose();
      },
    );

    test('a request without a token never starts refresh', () async {
      final gateway = _gateway((_) async => Success(_newSession));
      final manager = SessionManager(
        store: MemorySessionStore(initialSession: _oldSession),
        gateway: gateway,
      );
      await manager.restore();

      final result = await manager.recoverAccessToken(failedAccessToken: null);

      expect(result, isA<Failure<String>>());
      expect(gateway.refreshCallCount, 0);
      await manager.dispose();
    });

    test('transient refresh failure is shared and memoized', () async {
      var now = DateTime.utc(2026, 10, 15, 12);
      final failure = AuthFailure(
        kind: AuthFailureKind.transient,
        code: 'auth.refresh_unavailable',
        message: 'Refresh is temporarily unavailable.',
      );
      final gateway = _gateway((_) async => Failure(failure));
      final manager = SessionManager(
        store: MemorySessionStore(initialSession: _oldSession),
        gateway: gateway,
        clock: () => now,
        refreshFailureBackoff: const Duration(seconds: 10),
      );
      await manager.restore();

      final first = await manager.recoverAccessToken(
        failedAccessToken: _oldSession.accessToken,
      );
      final memoized = await manager.recoverAccessToken(
        failedAccessToken: _oldSession.accessToken,
      );
      now = now.add(const Duration(seconds: 11));
      final afterBackoff = await manager.recoverAccessToken(
        failedAccessToken: _oldSession.accessToken,
      );

      expect(first, isA<Failure<String>>());
      expect(memoized, isA<Failure<String>>());
      expect(afterBackoff, isA<Failure<String>>());
      expect(gateway.refreshCallCount, 2);
      expect(manager.current, AuthAuthenticated(_oldSession));
      await manager.dispose();
    });

    test('terminal refresh rejection clears the local session', () async {
      final failure = AuthFailure(
        kind: AuthFailureKind.invalidSession,
        code: 'auth.refresh_rejected',
        message: 'Refresh token was rejected.',
      );
      final store = MemorySessionStore(initialSession: _oldSession);
      final gateway = _gateway((_) async => Failure(failure));
      final manager = SessionManager(store: store, gateway: gateway);
      await manager.restore();

      await manager.recoverAccessToken(
        failedAccessToken: _oldSession.accessToken,
      );

      expect(store.session, isNull);
      expect(manager.current, const AuthUnauthenticated());
      await manager.dispose();
    });

    test('sign-out wins over a late refresh result', () async {
      final completer = Completer<Result<AuthSession>>();
      final store = MemorySessionStore(initialSession: _oldSession);
      final gateway = _gateway((_) => completer.future);
      final manager = SessionManager(store: store, gateway: gateway);
      await manager.restore();

      final refresh = manager.recoverAccessToken(
        failedAccessToken: _oldSession.accessToken,
      );
      await manager.signOut();
      completer.complete(Success(_newSession));
      final result = await refresh;

      expect(result, isA<Failure<String>>());
      expect(store.session, isNull);
      expect(manager.current, const AuthUnauthenticated());
      await manager.dispose();
    });

    test('sign-out clear is serialized after an in-progress write', () async {
      final store = _ControlledWriteStore();
      final manager = SessionManager(
        store: store,
        gateway: _gateway((_) async => Success(_newSession)),
      );

      final establish = manager.establish(
        _oldSession,
        expectedGeneration: manager.generation,
      );
      await store.writeStarted.future;
      final signOut = manager.signOut();
      store.completeWrite();

      expect(await establish, isA<Failure<AuthSession>>());
      await signOut;
      expect(store.session, isNull);
      expect(store.operations, ['write', 'clear']);
      expect(manager.current, const AuthUnauthenticated());
      await manager.dispose();
    });

    test(
      'sign-out publishes locally before remote revocation completes',
      () async {
        final revokeCompleter = Completer<Result<void>>();
        final gateway = FakeSessionGateway(
          refreshHandler: (_) async => Success(_newSession),
          revoke: (_) => revokeCompleter.future,
        );
        final manager = SessionManager(
          store: MemorySessionStore(initialSession: _oldSession),
          gateway: gateway,
        );
        await manager.restore();

        await manager.signOut();

        expect(manager.current, const AuthUnauthenticated());
        expect(manager.currentAccessToken, isNull);
        expect(gateway.revokeCallCount, 1);
        revokeCompleter.complete(
          const Failure(
            AuthFailure(
              kind: AuthFailureKind.transient,
              code: 'auth.revoke_failed',
              message: 'Best-effort revocation failed.',
            ),
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(manager.current, const AuthUnauthenticated());
        await manager.dispose();
      },
    );
  });

  test('late sign-in cannot establish a session after sign-out', () async {
    final completer = Completer<Result<AuthSession>>();
    final authGateway = FakeAuthGateway<_Credential>((_) => completer.future);
    final store = MemorySessionStore();
    final manager = SessionManager(
      store: store,
      gateway: _gateway((_) async => Success(_newSession)),
    );
    final signIn = BoundSignIn<_Credential>(
      gateway: authGateway,
      sessionManager: manager,
    );

    final resultFuture = signIn(const _Credential());
    await manager.signOut();
    completer.complete(Success(_oldSession));
    final result = await resultFuture;

    expect(result, isA<Failure<AuthSession>>());
    expect(store.writeCount, 0);
    expect(store.session, isNull);
    expect(manager.current, const AuthUnauthenticated());
    await manager.dispose();
  });
}

FakeSessionGateway _gateway(RefreshHandler refresh) =>
    FakeSessionGateway(refreshHandler: refresh);

final _oldSession = AuthSession(
  accessToken: 'access-old',
  refreshToken: 'refresh-old',
  subjectId: 'user-1',
  expiresAt: DateTime.utc(2030, 1, 1),
);

final _newSession = AuthSession(
  accessToken: 'access-new',
  refreshToken: 'refresh-new',
  subjectId: 'user-1',
  expiresAt: DateTime.utc(2030, 1, 2),
);

final class _Credential implements AuthCredential {
  const _Credential();
}

AuthFailure _storageFailure(String code) => AuthFailure(
  kind: AuthFailureKind.storage,
  code: code,
  message: 'Secure storage is unavailable.',
);

final class _RestoreFailureStore implements SessionStore {
  _RestoreFailureStore({required this.readFailure, this.clearFailure});

  final AppFailure readFailure;
  final AppFailure? clearFailure;
  var readCount = 0;
  var clearCount = 0;

  @override
  Future<Result<void>> clear() async {
    clearCount++;
    final failure = clearFailure;
    return failure == null ? const Success(null) : Failure(failure);
  }

  @override
  Future<Result<AuthSession?>> read() async {
    readCount++;
    return Failure(readFailure);
  }

  @override
  Future<Result<void>> write(AuthSession session) async => const Success(null);
}

final class _ControlledWriteStore implements SessionStore {
  final Completer<void> writeStarted = Completer<void>();
  final Completer<void> _writeMayFinish = Completer<void>();
  final List<String> operations = [];
  AuthSession? session;

  void completeWrite() => _writeMayFinish.complete();

  @override
  Future<Result<void>> clear() async {
    operations.add('clear');
    session = null;
    return const Success(null);
  }

  @override
  Future<Result<AuthSession?>> read() async => Success(session);

  @override
  Future<Result<void>> write(AuthSession value) async {
    operations.add('write');
    writeStarted.complete();
    await _writeMayFinish.future;
    session = value;
    return const Success(null);
  }
}
