import 'package:platform_foundation/platform_foundation.dart';

enum NotificationFailureKind {
  unsupported,
  permission,
  invalidPayload,
  persistence,
  unavailable,
  disposed,
}

final class NotificationFailure extends AppFailure {
  const NotificationFailure({
    required this.kind,
    required super.code,
    required super.message,
    super.cause,
    super.stackTrace,
  });

  final NotificationFailureKind kind;
}
