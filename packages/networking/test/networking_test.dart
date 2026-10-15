import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:networking/dio.dart';
import 'package:networking/networking.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:test/test.dart';

void main() {
  test('maps a successful Dio response without logging its body', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    dio.httpClientAdapter = _StubAdapter(statusCode: 200, body: '{"ok":true}');
    final records = <LogRecord>[];
    final client = DioNetworkClient(
      dio: dio,
      logger: StructuredLogger(records.add),
    );

    final result = await client.send(
      const NetworkRequest(method: HttpMethod.get, path: '/health'),
    );

    expect(result, isA<Success<NetworkResponse>>());
    final loggedContent = records
        .map((record) => '${record.message} ${record.fields}')
        .join(' ');
    expect(loggedContent, isNot(contains('{"ok":true}')));
    client.close();
  });

  test('maps non-success status to a typed failure', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    dio.httpClientAdapter = _StubAdapter(
      statusCode: 503,
      body: '{"message":"unavailable"}',
    );
    final client = DioNetworkClient(dio: dio);

    final result = await client.send(
      const NetworkRequest(method: HttpMethod.get, path: '/health'),
    );

    final failure = (result as Failure<NetworkResponse>).failure;
    expect(failure, isA<NetworkFailure>());
    expect((failure as NetworkFailure).statusCode, 503);
    client.close();
  });

  test('recovers a 401 and replays an eligible request once', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    final adapter = _TokenAdapter(replacementTokenSucceeds: true);
    dio.httpClientAdapter = adapter;
    final recovery = _FakeRecovery('access-new');
    var bodyBuilds = 0;
    final client = DioNetworkClient(
      dio: dio,
      accessTokenProvider: const _TokenProvider('access-old'),
      unauthorizedRecovery: recovery,
    );

    final result = await client.send(
      NetworkRequest(
        method: HttpMethod.post,
        path: '/protected',
        requiresAuthorization: true,
        bodyFactory: () {
          bodyBuilds++;
          return {'value': bodyBuilds};
        },
      ),
    );

    expect(result, isA<Success<NetworkResponse>>());
    expect(adapter.callCount, 2);
    expect(recovery.callCount, 1);
    expect(recovery.failedTokens, ['access-old']);
    expect(bodyBuilds, 2);
    client.close();
  });

  test('a replayed 401 is returned without another recovery loop', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    final adapter = _TokenAdapter(replacementTokenSucceeds: false);
    dio.httpClientAdapter = adapter;
    final recovery = _FakeRecovery('access-new');
    final client = DioNetworkClient(
      dio: dio,
      accessTokenProvider: const _TokenProvider('access-old'),
      unauthorizedRecovery: recovery,
    );

    final result = await client.send(
      const NetworkRequest(
        method: HttpMethod.get,
        path: '/protected',
        requiresAuthorization: true,
      ),
    );

    expect(result, isA<Failure<NetworkResponse>>());
    expect(adapter.callCount, 2);
    expect(recovery.callCount, 1);
    client.close();
  });

  test('a one-shot body is never replayed after unauthorized', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    final adapter = _TokenAdapter(replacementTokenSucceeds: true);
    dio.httpClientAdapter = adapter;
    final recovery = _FakeRecovery('access-new');
    final client = DioNetworkClient(
      dio: dio,
      accessTokenProvider: const _TokenProvider('access-old'),
      unauthorizedRecovery: recovery,
    );

    final result = await client.send(
      const NetworkRequest(
        method: HttpMethod.post,
        path: '/upload',
        requiresAuthorization: true,
        body: <String, Object?>{'oneShot': true},
      ),
    );

    final failure = (result as Failure<NetworkResponse>).failure;
    expect(
      (failure as NetworkFailure).kind,
      NetworkFailureKind.requestNotReplayable,
    );
    expect(adapter.callCount, 1);
    expect(recovery.callCount, 0);
    client.close();
  });

  test('a refresh request can explicitly opt out of recovery', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    final adapter = _TokenAdapter(replacementTokenSucceeds: true);
    dio.httpClientAdapter = adapter;
    final recovery = _FakeRecovery('access-new');
    final client = DioNetworkClient(
      dio: dio,
      accessTokenProvider: const _TokenProvider('access-old'),
      unauthorizedRecovery: recovery,
    );

    await client.send(
      const NetworkRequest(
        method: HttpMethod.post,
        path: '/refresh',
        requiresAuthorization: true,
        recoverFromUnauthorized: false,
      ),
    );

    expect(adapter.callCount, 1);
    expect(recovery.callCount, 0);
    client.close();
  });

  test('cancellation while awaiting recovery prevents replay', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    final adapter = _TokenAdapter(replacementTokenSucceeds: true);
    dio.httpClientAdapter = adapter;
    final recovery = _ControlledRecovery();
    final cancellation = NetworkCancellationController();
    final client = DioNetworkClient(
      dio: dio,
      accessTokenProvider: const _TokenProvider('access-old'),
      unauthorizedRecovery: recovery,
    );

    final request = client.send(
      NetworkRequest(
        method: HttpMethod.get,
        path: '/protected',
        requiresAuthorization: true,
        cancellation: cancellation,
      ),
    );
    await recovery.started.future;
    cancellation.cancel();
    final result = await request;
    recovery.complete('access-new');

    final failure = (result as Failure<NetworkResponse>).failure;
    expect((failure as NetworkFailure).kind, NetworkFailureKind.cancelled);
    expect(adapter.callCount, 1);
    client.close();
  });

  test('one deadline covers recovery waiting and replay', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    final adapter = _TokenAdapter(replacementTokenSucceeds: true);
    dio.httpClientAdapter = adapter;
    final recovery = _ControlledRecovery();
    final client = DioNetworkClient(
      dio: dio,
      accessTokenProvider: const _TokenProvider('access-old'),
      unauthorizedRecovery: recovery,
    );

    final result = await client.send(
      NetworkRequest(
        method: HttpMethod.get,
        path: '/protected',
        requiresAuthorization: true,
        deadline: DateTime.now().add(const Duration(milliseconds: 100)),
      ),
    );
    recovery.complete('access-new');

    final failure = (result as Failure<NetworkResponse>).failure;
    expect((failure as NetworkFailure).code, 'network.deadline_exceeded');
    expect(adapter.callCount, 1);
    client.close();
  });
}

final class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

final class _TokenAdapter implements HttpClientAdapter {
  _TokenAdapter({required this.replacementTokenSucceeds});

  final bool replacementTokenSucceeds;
  var callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    final authorization = options.headers['Authorization'];
    final success =
        replacementTokenSucceeds && authorization == 'Bearer access-new';
    return ResponseBody.fromString(
      success ? '{"ok":true}' : '{"error":"unauthorized"}',
      success ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

final class _TokenProvider implements AccessTokenProvider {
  const _TokenProvider(this.token);

  final String? token;

  @override
  Future<String?> accessToken() async => token;
}

final class _FakeRecovery implements UnauthorizedRecovery {
  _FakeRecovery(this.replacementToken);

  final String replacementToken;
  final List<String?> failedTokens = [];
  var callCount = 0;

  @override
  Future<Result<String>> recoverAccessToken({
    required String? failedAccessToken,
  }) async {
    callCount++;
    failedTokens.add(failedAccessToken);
    return Success(replacementToken);
  }
}

final class _ControlledRecovery implements UnauthorizedRecovery {
  final Completer<void> started = Completer<void>();
  final Completer<Result<String>> _result = Completer<Result<String>>();

  void complete(String token) {
    if (!_result.isCompleted) {
      _result.complete(Success(token));
    }
  }

  @override
  Future<Result<String>> recoverAccessToken({
    required String? failedAccessToken,
  }) {
    if (!started.isCompleted) {
      started.complete();
    }
    return _result.future;
  }
}
