import 'dart:async';

import 'package:platform_foundation/platform_foundation.dart';

import '../client.dart';
import '../models.dart';

abstract interface class RealtimeContractDriver {
  RealtimeClient get client;
  RealtimeConfiguration get configuration;
  int get transportConnectAttempts;

  Future<void> injectServerEvent(RealtimeEvent event);
  Future<void> forceTransportReconnect();
}

typedef RealtimeContractDriverFactory =
    Future<RealtimeContractDriver> Function();

Future<void> verifyRealtimeContract(
  RealtimeContractDriverFactory create,
) async {
  final beforeConnect = await create();
  try {
    final emitted = await beforeConnect.client.emit(
      const OutgoingRealtimeEvent(name: 'message', payload: {}),
    );
    _check(emitted is Failure<void>, 'emit-before-connect must fail');
  } finally {
    await beforeConnect.client.dispose();
  }

  final driver = await create();
  final received = <RealtimeEvent>[];
  final subscription = driver.client.subscribe(
    const RealtimeSubscriptionRequest(eventNames: {'message'}),
  );
  final streamSubscription = subscription.events.listen(received.add);
  try {
    final results = await Future.wait([
      driver.client.connect(driver.configuration),
      driver.client.connect(driver.configuration),
    ]);
    _check(
      results.every((result) => result is Success<void>),
      'concurrent connect calls must both succeed',
    );
    _check(
      driver.transportConnectAttempts == 1,
      'concurrent connect calls must share one transport attempt',
    );

    await driver.injectServerEvent(
      const RealtimeEvent(name: 'message', payload: {'value': 1}, sequence: 1),
    );
    await driver.injectServerEvent(
      const RealtimeEvent(name: 'message', payload: {'value': 2}, sequence: 2),
    );
    await driver.forceTransportReconnect();
    await driver.injectServerEvent(
      const RealtimeEvent(name: 'message', payload: {'value': 3}, sequence: 3),
    );
    await Future<void>.delayed(Duration.zero);
    _check(
      received.map((event) => event.sequence).toList().join(',') == '1,2,3',
      'subscription must preserve per-connection order and survive reconnect',
    );

    await driver.client.dispose();
    await driver.injectServerEvent(
      const RealtimeEvent(name: 'message', payload: {'value': 4}, sequence: 4),
    );
    await Future<void>.delayed(Duration.zero);
    _check(received.length == 3, 'no event may be delivered after dispose');
  } finally {
    await streamSubscription.cancel();
    await subscription.cancel();
    await driver.client.dispose();
  }
}

void _check(bool condition, String message) {
  if (!condition) {
    throw StateError('Realtime contract violation: $message');
  }
}
