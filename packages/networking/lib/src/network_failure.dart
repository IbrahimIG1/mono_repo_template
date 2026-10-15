import 'package:platform_foundation/platform_foundation.dart';

enum NetworkFailureKind {
  authorization,
  cancelled,
  connection,
  invalidResponse,
  requestNotReplayable,
  timeout,
  transport,
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure({
    required this.kind,
    required super.code,
    required super.message,
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  final NetworkFailureKind kind;
  final int? statusCode;
}
