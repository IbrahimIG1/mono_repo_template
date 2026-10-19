import 'package:platform_foundation/platform_foundation.dart';

import 'models.dart';

abstract interface class PushNotificationClient {
  Stream<PushToken> get tokenChanges;
  Stream<PushMessage> get foregroundMessages;
  Stream<NotificationInteraction> get interactions;

  Future<Result<NotificationCapability>> initialize();
  Future<Result<NotificationPermission>> requestPermission();
  Future<Result<PushToken?>> getToken();
  Future<void> dispose();
}
