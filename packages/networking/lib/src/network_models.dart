enum HttpMethod { delete, get, patch, post, put }

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
  });

  final HttpMethod method;
  final String path;
  final Map<String, Object?> headers;
  final Map<String, Object?> queryParameters;
  final Object? body;
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
