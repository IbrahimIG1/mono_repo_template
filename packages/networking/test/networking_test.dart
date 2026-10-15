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
