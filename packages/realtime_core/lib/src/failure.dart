import 'package:platform_foundation/platform_foundation.dart';

enum RealtimeFailureKind {
  notConnected,
  cancelled,
  transport,
  protocol,
  overflow,
  disposed,
}

final class RealtimeFailure extends AppFailure {
  const RealtimeFailure({
    required this.kind,
    required super.code,
    required super.message,
    super.cause,
    super.stackTrace,
  });

  final RealtimeFailureKind kind;
}
