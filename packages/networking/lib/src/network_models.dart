import 'dart:async';

enum HttpMethod { delete, get, patch, post, put }

typedef RequestBodyFactory = Object? Function();
typedef NetworkClock = DateTime Function();

abstract interface class NetworkCancellation {
  bool get isCancelled;
  Future<void> get whenCancelled;
}

final class NetworkCancellationController implements NetworkCancellation {
  final Completer<void> _completer = Completer<void>();

  @override
  bool get isCancelled => _completer.isCompleted;

  @override
  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}

final class NetworkConfiguration {
  const NetworkConfiguration({
    required this.baseUri,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.defaultHeaders = const {},
  });

  final Uri baseUri;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final Map<String, Object?> defaultHeaders;
}

final class NetworkRequest {
  const NetworkRequest({
    required this.method,
    required this.path,
    this.headers = const {},
    this.queryParameters = const {},
    this.body,
    this.bodyFactory,
    this.requiresAuthorization = false,
    this.recoverFromUnauthorized = true,
    this.cancellation,
    this.deadline,
  }) : assert(
         body == null || bodyFactory == null,
         'Provide either body or bodyFactory, not both.',
       );

  final HttpMethod method;
  final String path;
  final Map<String, Object?> headers;
  final Map<String, Object?> queryParameters;
  final Object? body;
  final RequestBodyFactory? bodyFactory;
  final bool requiresAuthorization;
  final bool recoverFromUnauthorized;
  final NetworkCancellation? cancellation;
  final DateTime? deadline;

  bool get canReplayAfterUnauthorized => body == null || bodyFactory != null;

  Object? createBody() => bodyFactory?.call() ?? body;
}

final class NetworkResponse {
  const NetworkResponse({
    required this.statusCode,
    required this.data,
    required this.headers,
  });

  final int statusCode;
  final Object? data;
  final Map<String, List<String>> headers;
}
