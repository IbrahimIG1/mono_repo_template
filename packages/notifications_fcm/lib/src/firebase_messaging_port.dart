import 'package:firebase_messaging/firebase_messaging.dart';

import 'fcm_port.dart';

final class FirebaseMessagingPort implements FcmPort {
  FirebaseMessagingPort(this._messaging);

  factory FirebaseMessagingPort.create() =>
      FirebaseMessagingPort(FirebaseMessaging.instance);

  final FirebaseMessaging _messaging;

  @override
  Stream<String> get tokenChanges => _messaging.onRegistered;

  @override
  Stream<FcmMessage> get foregroundMessages =>
      FirebaseMessaging.onMessage.map(_mapMessage);

  @override
  Stream<FcmMessage> get openedMessages =>
      FirebaseMessaging.onMessageOpenedApp.map(_mapMessage);

  @override
  Future<String?> getToken() async {
    final registration = _messaging.onRegistered.first;
    await _messaging.register();
    return registration.timeout(const Duration(seconds: 10));
  }

  @override
  Future<FcmMessage?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _mapMessage(message);
  }

  @override
  Future<FcmAuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized => FcmAuthorizationStatus.authorized,
      AuthorizationStatus.denied => FcmAuthorizationStatus.denied,
      AuthorizationStatus.deniedPermanently =>
        FcmAuthorizationStatus.deniedPermanently,
      AuthorizationStatus.notDetermined => FcmAuthorizationStatus.notDetermined,
      AuthorizationStatus.provisional => FcmAuthorizationStatus.provisional,
    };
  }
}

FcmMessage _mapMessage(RemoteMessage message) => FcmMessage(
  id: message.messageId,
  data: message.data.map(
    (key, value) => MapEntry(key, value is String ? value : value.toString()),
  ),
  title: message.notification?.title,
  body: message.notification?.body,
);
