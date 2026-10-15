import 'package:dio/dio.dart';
import 'package:platform_foundation/platform_foundation.dart';

import 'network_client.dart';
import 'network_failure.dart';
import 'network_models.dart';

final class DioNetworkClient implements NetworkClient {
  DioNetworkClient({required this.dio, this.logger = const NullLogger()});

  factory DioNetworkClient.create({
    required NetworkConfiguration configuration,
    AppLogger logger = const NullLogger(),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: configuration.baseUri.toString(),
        connectTimeout: configuration.connectTimeout,
        receiveTimeout: configuration.receiveTimeout,
        sendTimeout: configuration.sendTimeout,
        headers: configuration.defaultHeaders,
        validateStatus: (_) => true,
      ),
    );
    return DioNetworkClient(dio: dio, logger: logger);
  }

  final Dio dio;
  final AppLogger logger;

  @override
  Future<Result<NetworkResponse>> send(NetworkRequest request) async {
    logger.debug(
      'HTTP request',
      fields: {'method': request.method.name, 'path': request.path},
    );

    try {
      final response = await dio.request<Object?>(
        request.path,
        data: request.body,
        queryParameters: request.queryParameters,
        options: Options(
          method: request.method.name.toUpperCase(),
          headers: request.headers,
          validateStatus: (_) => true,
        ),
      );
      final statusCode = response.statusCode;
      if (statusCode == null) {
        return Failure(
          NetworkFailure(
            kind: NetworkFailureKind.invalidResponse,
            code: 'network.missing_status',
            message: 'The server response did not contain a status code.',
          ),
        );
      }

      if (statusCode < 200 || statusCode >= 300) {
        logger.warning(
          'HTTP request failed',
          fields: {
            'method': request.method.name,
            'path': request.path,
            'statusCode': statusCode,
          },
        );
        return Failure(
          NetworkFailure(
            kind: NetworkFailureKind.invalidResponse,
            code: 'network.http_status',
            message: 'The server returned a non-success status.',
            statusCode: statusCode,
          ),
        );
      }

      return Success(
        NetworkResponse(
          statusCode: statusCode,
          data: response.data,
          headers: response.headers.map,
        ),
      );
    } on DioException catch (error, stackTrace) {
      final failure = _mapFailure(error, stackTrace);
      logger.warning(
        'HTTP transport failed',
        fields: {
          'method': request.method.name,
          'path': request.path,
          'failureCode': failure.code,
        },
      );
      return Failure(failure);
    }
  }

  @override
  void close() => dio.close(force: true);

  NetworkFailure _mapFailure(DioException error, StackTrace stackTrace) {
    final kind = switch (error.type) {
      DioExceptionType.cancel => NetworkFailureKind.cancelled,
      DioExceptionType.connectionError => NetworkFailureKind.connection,
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.transformTimeout => NetworkFailureKind.timeout,
      DioExceptionType.badResponse => NetworkFailureKind.invalidResponse,
      DioExceptionType.badCertificate ||
      DioExceptionType.unknown => NetworkFailureKind.transport,
    };
    return NetworkFailure(
      kind: kind,
      code: 'network.${kind.name}',
      message: 'The HTTP request could not be completed.',
      statusCode: error.response?.statusCode,
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
