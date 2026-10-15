import 'dart:async';

import 'package:dio/dio.dart';
import 'package:platform_foundation/platform_foundation.dart';

import 'network_client.dart';
import 'network_failure.dart';
import 'network_models.dart';
import 'unauthorized_recovery.dart';

final class DioNetworkClient implements NetworkClient {
  DioNetworkClient({
    required this.dio,
    this.logger = const NullLogger(),
    this.accessTokenProvider,
    this.unauthorizedRecovery,
    NetworkClock? clock,
  }) : clock = clock ?? DateTime.now;

  factory DioNetworkClient.create({
    required NetworkConfiguration configuration,
    AppLogger logger = const NullLogger(),
    AccessTokenProvider? accessTokenProvider,
    UnauthorizedRecovery? unauthorizedRecovery,
    NetworkClock? clock,
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
    return DioNetworkClient(
      dio: dio,
      logger: logger,
      accessTokenProvider: accessTokenProvider,
      unauthorizedRecovery: unauthorizedRecovery,
      clock: clock,
    );
  }

  final Dio dio;
  final AppLogger logger;
  final AccessTokenProvider? accessTokenProvider;
  final UnauthorizedRecovery? unauthorizedRecovery;
  final NetworkClock clock;

  @override
  Future<Result<NetworkResponse>> send(NetworkRequest request) async {
    final lifecycleFailure = _lifecycleFailure(request);
    if (lifecycleFailure != null) {
      return Failure(lifecycleFailure);
    }
    String? failedAccessToken;
    if (request.requiresAuthorization) {
      final provider = accessTokenProvider;
      if (provider == null) {
        return const Failure(
          NetworkFailure(
            kind: NetworkFailureKind.authorization,
            code: 'network.authorization_unconfigured',
            message: 'The request requires an access-token provider.',
          ),
        );
      }
      try {
        failedAccessToken = await provider.accessToken();
      } on Object catch (error, stackTrace) {
        return Failure(
          NetworkFailure(
            kind: NetworkFailureKind.authorization,
            code: 'network.token_provider_failed',
            message: 'The access token could not be obtained.',
            cause: error,
            stackTrace: stackTrace,
          ),
        );
      }
    }

    final firstResult = await _sendOnce(
      request,
      accessToken: failedAccessToken,
      isReplay: false,
    );
    if (!_isUnauthorized(firstResult) ||
        !request.requiresAuthorization ||
        !request.recoverFromUnauthorized) {
      return firstResult;
    }

    final recovery = unauthorizedRecovery;
    if (recovery == null) {
      return firstResult;
    }
    if (!request.canReplayAfterUnauthorized) {
      return const Failure(
        NetworkFailure(
          kind: NetworkFailureKind.requestNotReplayable,
          code: 'network.request_not_replayable',
          message: 'The unauthorized request body cannot be replayed safely.',
        ),
      );
    }

    late final Result<String> recoveryResult;
    try {
      recoveryResult = await _awaitWithLifecycle(
        recovery.recoverAccessToken(failedAccessToken: failedAccessToken),
        request,
      );
    } on Object catch (error, stackTrace) {
      return Failure(
        NetworkFailure(
          kind: NetworkFailureKind.authorization,
          code: 'network.unauthorized_recovery_failed',
          message: 'Unauthorized recovery failed unexpectedly.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
    return switch (recoveryResult) {
      Failure<String>(:final failure) => Failure(failure),
      Success<String>(:final value) => _sendOnce(
        request,
        accessToken: value,
        isReplay: true,
      ),
    };
  }

  Future<Result<NetworkResponse>> _sendOnce(
    NetworkRequest request, {
    required String? accessToken,
    required bool isReplay,
  }) async {
    final lifecycleFailure = _lifecycleFailure(request);
    if (lifecycleFailure != null) {
      return Failure(lifecycleFailure);
    }
    logger.debug(
      'HTTP request',
      fields: {
        'method': request.method.name,
        'path': request.path,
        'isReplay': isReplay,
      },
    );

    Timer? deadlineTimer;
    try {
      final cancelToken = CancelToken();
      final cancellation = request.cancellation;
      if (cancellation != null) {
        unawaited(
          cancellation.whenCancelled.then((_) {
            if (!cancelToken.isCancelled) {
              cancelToken.cancel('network request cancelled');
            }
          }),
        );
      }
      final remaining = _remaining(request);
      if (remaining != null) {
        deadlineTimer = Timer(remaining, () {
          if (!cancelToken.isCancelled) {
            cancelToken.cancel('network request deadline exceeded');
          }
        });
      }
      final headers = <String, Object?>{
        for (final entry in request.headers.entries)
          if (entry.key.toLowerCase() != 'authorization')
            entry.key: entry.value,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };
      final response = await dio.request<Object?>(
        request.path,
        data: request.createBody(),
        queryParameters: request.queryParameters,
        options: Options(
          method: request.method.name.toUpperCase(),
          headers: headers,
          validateStatus: (_) => true,
        ),
        cancelToken: cancelToken,
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
      final lifecycleFailure = _lifecycleFailure(request);
      if (lifecycleFailure != null) {
        return Failure(lifecycleFailure);
      }
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
    } finally {
      deadlineTimer?.cancel();
    }
  }

  @override
  void close() => dio.close(force: true);

  bool _isUnauthorized(Result<NetworkResponse> result) => switch (result) {
    Failure<NetworkResponse>(failure: NetworkFailure(statusCode: 401)) => true,
    _ => false,
  };

  Future<Result<T>> _awaitWithLifecycle<T>(
    Future<Result<T>> operation,
    NetworkRequest request,
  ) {
    final alternatives = <Future<Result<T>>>[operation];
    final cancellation = request.cancellation;
    if (cancellation != null) {
      alternatives.add(
        cancellation.whenCancelled.then((_) => Failure<T>(_cancelledFailure())),
      );
    }
    final remaining = _remaining(request);
    if (remaining != null) {
      alternatives.add(
        Future<Result<T>>.delayed(
          remaining,
          () => Failure<T>(_deadlineFailure()),
        ),
      );
    }
    return Future.any(alternatives);
  }

  NetworkFailure? _lifecycleFailure(NetworkRequest request) {
    if (request.cancellation?.isCancelled ?? false) {
      return _cancelledFailure();
    }
    final remaining = _remaining(request);
    if (remaining != null && remaining <= Duration.zero) {
      return _deadlineFailure();
    }
    return null;
  }

  Duration? _remaining(NetworkRequest request) =>
      request.deadline?.toUtc().difference(clock().toUtc());

  NetworkFailure _cancelledFailure() => const NetworkFailure(
    kind: NetworkFailureKind.cancelled,
    code: 'network.cancelled',
    message: 'The HTTP request was cancelled.',
  );

  NetworkFailure _deadlineFailure() => const NetworkFailure(
    kind: NetworkFailureKind.timeout,
    code: 'network.deadline_exceeded',
    message: 'The HTTP request deadline was exceeded.',
  );

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
