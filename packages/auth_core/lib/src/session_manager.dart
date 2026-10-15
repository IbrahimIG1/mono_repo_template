import 'dart:async';

import 'package:platform_foundation/platform_foundation.dart';

import 'auth_failure.dart';
import 'auth_gateway.dart';
import 'auth_session.dart';
import 'auth_state.dart';

typedef AuthClock = DateTime Function();

final class SessionManager {
  factory SessionManager({
    required SessionStore store,
    required SessionGateway gateway,
    AppLogger logger = const NullLogger(),
    AuthClock? clock,
    Duration refreshFailureBackoff = const Duration(seconds: 5),
  }) => SessionManager._(
    store,
    gateway,
    logger,
    clock ?? DateTime.now,
    refreshFailureBackoff,
  );

  SessionManager._(
    this._store,
    this._gateway,
    this._logger,
    this._clock,
    this.refreshFailureBackoff,
  );

  final SessionStore _store;
  final SessionGateway _gateway;
  final AppLogger _logger;
  final AuthClock _clock;
  final Duration refreshFailureBackoff;
  final StreamController<AuthState> _states =
      StreamController<AuthState>.broadcast(sync: true);

  AuthState _current = const AuthUninitialized();
  AuthSession? _session;
  Future<Result<String>>? _refreshInFlight;
  AppFailure? _memoizedRefreshFailure;
  DateTime? _memoizedRefreshFailureAt;
  var _generation = 0;
  var _restoreStarted = false;
  var _disposed = false;
  Future<void> _storeTail = Future<void>.value();

  AuthState get current => _current;
  Stream<AuthState> get states => _states.stream;
  int get generation => _generation;
  String? get currentAccessToken => _session?.accessToken;

  Future<Result<void>> restore() async {
    if (_restoreStarted) {
      return const Success(null);
    }
    _restoreStarted = true;
    final operationGeneration = _generation;
    _publish(const AuthRestoring());

    final result = await _serializeStore(_store.read);
    if (!_isCurrent(operationGeneration)) {
      return Failure(AuthFailure.staleOperation());
    }

    switch (result) {
      case Failure<AuthSession?>(:final failure):
        if (failure case AuthFailure(
          kind: AuthFailureKind.invalidStoredSession,
        )) {
          await _serializeStore(_store.clear);
        }
        _publish(const AuthUnauthenticated());
        return Failure(failure);
      case Success<AuthSession?>(value: null):
        _publish(const AuthUnauthenticated());
        return const Success(null);
      case Success<AuthSession?>(:final value?):
        if (value.isExpiredAt(_clock())) {
          await _serializeStore(_store.clear);
          if (_isCurrent(operationGeneration)) {
            _publish(const AuthUnauthenticated());
          }
          return const Success(null);
        }
        _session = value;
        _publish(AuthAuthenticated(value));
        return const Success(null);
    }
  }

  Future<Result<AuthSession>> establish(
    AuthSession session, {
    required int expectedGeneration,
  }) async {
    if (!_isCurrent(expectedGeneration)) {
      return Failure(AuthFailure.staleOperation());
    }

    final writeResult = await _serializeStore(() => _store.write(session));
    if (!_isCurrent(expectedGeneration)) {
      return Failure(AuthFailure.staleOperation());
    }
    if (writeResult case Failure<void>(:final failure)) {
      return Failure(failure);
    }

    _session = session;
    _clearRefreshFailure();
    _publish(AuthAuthenticated(session));
    return Success(session);
  }

  Future<Result<String>> recoverAccessToken({
    required String? failedAccessToken,
  }) {
    if (failedAccessToken == null) {
      return Future.value(
        const Failure(
          AuthFailure(
            kind: AuthFailureKind.missingToken,
            code: 'auth.missing_failed_token',
            message: 'The unauthorized request did not use an access token.',
          ),
        ),
      );
    }

    final session = _session;
    if (session == null) {
      return Future.value(
        const Failure(
          AuthFailure(
            kind: AuthFailureKind.missingSession,
            code: 'auth.missing_session',
            message: 'There is no authenticated session to refresh.',
          ),
        ),
      );
    }

    if (session.accessToken != failedAccessToken) {
      return Future.value(Success(session.accessToken));
    }

    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final memoizedFailure = _memoizedRefreshFailure;
    final memoizedAt = _memoizedRefreshFailureAt;
    if (memoizedFailure != null &&
        memoizedAt != null &&
        _clock().toUtc().difference(memoizedAt) < refreshFailureBackoff) {
      return Future.value(Failure(memoizedFailure));
    }

    final operation = _performRefresh(session, _generation);
    _refreshInFlight = operation;
    unawaited(
      operation.then((_) {
        if (identical(_refreshInFlight, operation)) {
          _refreshInFlight = null;
        }
      }),
    );
    return operation;
  }

  Future<void> signOut() async {
    final refreshToken = _session?.refreshToken;
    _generation++;
    final operationGeneration = _generation;
    _session = null;
    _refreshInFlight = null;
    _clearRefreshFailure();

    final clearResult = await _serializeStore(_store.clear);
    if (_isCurrent(operationGeneration)) {
      _publish(const AuthUnauthenticated());
    }
    if (clearResult case Failure<void>(:final failure)) {
      _logger.warning(
        'Local session clear failed during sign-out',
        fields: {'failureCode': failure.code},
      );
    }

    if (refreshToken == null) {
      return;
    }
    unawaited(_revokeBestEffort(refreshToken));
  }

  Future<void> _revokeBestEffort(String refreshToken) async {
    try {
      final revokeResult = await _gateway.revoke(refreshToken);
      if (revokeResult case Failure<void>(:final failure)) {
        _logger.warning(
          'Remote session revocation failed',
          fields: {'failureCode': failure.code},
        );
      }
    } on Object catch (error) {
      _logger.warning(
        'Remote session revocation threw unexpectedly',
        fields: {'errorType': error.runtimeType.toString()},
      );
    }
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _generation++;
    await _states.close();
  }

  Future<Result<String>> _performRefresh(
    AuthSession previousSession,
    int operationGeneration,
  ) async {
    _publish(AuthRefreshing(previousSession));
    late final Result<AuthSession> refreshResult;
    try {
      refreshResult = await _gateway.refresh(previousSession.refreshToken);
    } on Object catch (error, stackTrace) {
      refreshResult = Failure(
        AuthFailure(
          kind: AuthFailureKind.unexpected,
          code: 'auth.refresh_unexpected',
          message: 'Session refresh failed unexpectedly.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }

    if (!_isCurrent(operationGeneration)) {
      return Failure(AuthFailure.staleOperation());
    }

    return switch (refreshResult) {
      Success<AuthSession>(:final value) => _persistRefreshedSession(
        value,
        operationGeneration,
      ),
      Failure<AuthSession>(:final failure) => _handleRefreshFailure(
        failure,
        previousSession,
        operationGeneration,
      ),
    };
  }

  Future<Result<String>> _persistRefreshedSession(
    AuthSession session,
    int operationGeneration,
  ) async {
    final writeResult = await _serializeStore(() => _store.write(session));
    if (!_isCurrent(operationGeneration)) {
      return Failure(AuthFailure.staleOperation());
    }
    if (writeResult case Failure<void>(:final failure)) {
      _publish(AuthAuthenticated(_session!));
      _memoizeRefreshFailure(failure);
      return Failure(failure);
    }

    _session = session;
    _clearRefreshFailure();
    _publish(AuthAuthenticated(session));
    return Success(session.accessToken);
  }

  Future<Result<String>> _handleRefreshFailure(
    AppFailure failure,
    AuthSession previousSession,
    int operationGeneration,
  ) async {
    if (failure case AuthFailure(kind: AuthFailureKind.invalidSession)) {
      _session = null;
      await _serializeStore(_store.clear);
      if (_isCurrent(operationGeneration)) {
        _publish(const AuthUnauthenticated());
      }
      return Failure(failure);
    }

    _memoizeRefreshFailure(failure);
    _publish(AuthAuthenticated(previousSession));
    return Failure(failure);
  }

  void _memoizeRefreshFailure(AppFailure failure) {
    _memoizedRefreshFailure = failure;
    _memoizedRefreshFailureAt = _clock().toUtc();
  }

  void _clearRefreshFailure() {
    _memoizedRefreshFailure = null;
    _memoizedRefreshFailureAt = null;
  }

  bool _isCurrent(int operationGeneration) =>
      !_disposed && operationGeneration == _generation;

  Future<T> _serializeStore<T>(Future<T> Function() operation) {
    final result = _storeTail.then((_) => operation());
    _storeTail = result.then<void>((_) {}, onError: (_, _) {});
    return result;
  }

  void _publish(AuthState state) {
    if (_disposed || state == _current) {
      return;
    }
    _current = state;
    _states.add(state);
  }
}
