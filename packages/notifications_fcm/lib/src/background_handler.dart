import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications_core/notifications_core.dart';

/// Safe default registration target for data-only background validation.
///
/// It is deliberately top-level and constructs its decoder locally. It never
/// reads an app service locator or foreground composition root. Apps that need
/// background persistence should provide their own top-level handler and build
/// only isolate-safe, app-owned dependencies inside it.
@pragma('vm:entry-point')
Future<void> mobileFcmBackgroundHandler(RemoteMessage message) async {
  const decoder = NotificationPayloadDecoder();
  decoder.decode(
    message.data.map(
      (key, value) => MapEntry(key, value is String ? value : value.toString()),
    ),
  );
}

void registerMobileFcmBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(mobileFcmBackgroundHandler);
}
