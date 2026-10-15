enum NotificationCapability { supported, unsupported }

enum NotificationPermission {
  notDetermined,
  denied,
  deniedPermanently,
  provisional,
  authorized,
}

final class PushToken {
  const PushToken(this.value) : assert(value != '');

  final String value;

  @override
  String toString() => 'PushToken(<redacted>)';
}

final class PushMessage {
  const PushMessage({
    required this.id,
    required this.data,
    required this.receivedAt,
    this.title,
    this.body,
  });

  final String id;
  final Map<String, String> data;
  final DateTime receivedAt;
  final String? title;
  final String? body;
}

final class NotificationInteraction {
  const NotificationInteraction({
    required this.id,
    required this.data,
    required this.occurredAt,
  });

  final String id;
  final Map<String, String> data;
  final DateTime occurredAt;
}

final class NotificationPayload {
  const NotificationPayload({
    required this.version,
    required this.type,
    required this.interactionId,
    required this.arguments,
  });

  final int version;
  final String type;
  final String interactionId;
  final Map<String, String> arguments;
}
