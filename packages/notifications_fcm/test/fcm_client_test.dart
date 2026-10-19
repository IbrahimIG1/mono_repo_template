import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_core/notifications_core.dart';
import 'package:notifications_core/testing.dart';
import 'package:notifications_fcm/notifications_fcm.dart';
import 'package:notifications_fcm/testing.dart';
import 'package:platform_foundation/platform_foundation.dart';

void main() {
  test('FCM adapter passes the shared notification client contract', () async {
    final driver = _FcmNotificationContractDriver();
    await verifyNotificationClientContract(() async => driver);
    await driver.port.dispose();
  });

  test('initialization is idempotent and maps opened messages', () async {
    final port = FakeFcmPort()
      ..initialMessage = const FcmMessage(
        id: 'message-1',
        data: {'v': '1', 'type': 'protected_item', 'interaction_id': 'tap-1'},
      );
    final client = FcmPushNotificationClient(
      port: port,
      isMobilePlatform: true,
    );
    expect(await client.initialize(), isA<Success<NotificationCapability>>());
    expect(await client.initialize(), isA<Success<NotificationCapability>>());
    final interactions = <NotificationInteraction>[];
    final subscription = client.interactions.listen(interactions.add);
    port.openedController.add(
      const FcmMessage(id: 'message-2', data: {'interaction_id': 'tap-2'}),
    );
    await Future<void>.delayed(Duration.zero);

    expect(interactions.map((value) => value.id), ['tap-1', 'tap-2']);
    await subscription.cancel();
    await client.dispose();
    await port.dispose();
  });

  test(
    'permission request covers Android 13 and iOS authorization flow',
    () async {
      final port = FakeFcmPort()
        ..permission = FcmAuthorizationStatus.provisional;
      final client = FcmPushNotificationClient(
        port: port,
        isMobilePlatform: true,
      );

      final result = await client.requestPermission();

      expect(
        (result as Success<NotificationPermission>).value,
        NotificationPermission.provisional,
      );
      expect(port.permissionRequests, 1);
      await client.dispose();
      await port.dispose();
    },
  );

  test('unsupported platforms do not call the Firebase port', () async {
    final port = FakeFcmPort();
    final client = FcmPushNotificationClient(
      port: port,
      isMobilePlatform: false,
    );

    expect(
      (await client.initialize() as Success<NotificationCapability>).value,
      NotificationCapability.unsupported,
    );
    expect(
      await client.requestPermission(),
      isA<Failure<NotificationPermission>>(),
    );
    expect(port.permissionRequests, 0);
    await client.dispose();
    await port.dispose();
  });

  test('dispose cancels delivery and closes public streams', () async {
    final port = FakeFcmPort();
    final client = FcmPushNotificationClient(
      port: port,
      isMobilePlatform: true,
    );
    await client.initialize();
    var delivered = 0;
    final subscription = client.foregroundMessages.listen((_) => delivered++);

    await client.dispose();
    port.foregroundController.add(
      const FcmMessage(id: 'late', data: {'interaction_id': 'late'}),
    );
    await Future<void>.delayed(Duration.zero);

    expect(delivered, 0);
    await subscription.cancel();
    await port.dispose();
  });
}

final class _FcmNotificationContractDriver
    implements NotificationContractDriver {
  _FcmNotificationContractDriver() : port = FakeFcmPort() {
    port.token = 'contract-token';
    _client = FcmPushNotificationClient(port: port, isMobilePlatform: true);
  }

  final FakeFcmPort port;
  late final FcmPushNotificationClient _client;

  @override
  PushNotificationClient get client => _client;

  @override
  Future<void> injectInteraction(NotificationInteraction interaction) async {
    if (!port.openedController.isClosed) {
      port.openedController.add(
        FcmMessage(id: interaction.id, data: interaction.data),
      );
    }
  }
}
