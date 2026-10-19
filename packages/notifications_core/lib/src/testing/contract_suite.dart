import 'package:platform_foundation/platform_foundation.dart';

import '../client.dart';
import '../models.dart';

abstract interface class NotificationContractDriver {
  PushNotificationClient get client;

  Future<void> injectInteraction(NotificationInteraction interaction);
}

typedef NotificationContractDriverFactory =
    Future<NotificationContractDriver> Function();

Future<void> verifyNotificationClientContract(
  NotificationContractDriverFactory create,
) async {
  final driver = await create();
  final received = <NotificationInteraction>[];
  final subscription = driver.client.interactions.listen(received.add);
  try {
    final first = await driver.client.initialize();
    final second = await driver.client.initialize();
    _check(
      first is Success<NotificationCapability> &&
          first.value == NotificationCapability.supported,
      'initialization must report supported',
    );
    _check(
      second is Success<NotificationCapability> &&
          second.value == NotificationCapability.supported,
      'initialization must be idempotent',
    );
    _check(
      await driver.client.requestPermission()
          is Success<NotificationPermission>,
      'permission request must return a typed result',
    );
    _check(
      await driver.client.getToken() is Success<PushToken?>,
      'token lookup must return a typed result',
    );

    final interaction = NotificationInteraction(
      id: 'contract-tap',
      data: const {
        'v': '1',
        'type': 'contract',
        'interaction_id': 'contract-tap',
      },
      occurredAt: DateTime.utc(2026, 10, 19),
    );
    await driver.injectInteraction(interaction);
    await Future<void>.delayed(Duration.zero);
    _check(received.length == 1, 'interaction stream must deliver once');

    await driver.client.dispose();
    await driver.injectInteraction(interaction);
    await Future<void>.delayed(Duration.zero);
    _check(received.length == 1, 'no interaction may arrive after dispose');
  } finally {
    await subscription.cancel();
    await driver.client.dispose();
  }
}

void _check(bool condition, String message) {
  if (!condition) {
    throw StateError('Notification contract violation: $message');
  }
}
