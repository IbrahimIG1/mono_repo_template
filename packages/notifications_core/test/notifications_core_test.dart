import 'dart:async';

import 'package:notifications_core/notifications_core.dart';
import 'package:notifications_core/testing.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:test/test.dart';

void main() {
  test('fake passes the shared notification client contract', () async {
    await verifyNotificationClientContract(
      () async => _FakeNotificationContractDriver(),
    );
  });

  group('NotificationPayloadDecoder', () {
    const decoder = NotificationPayloadDecoder();

    test('accepts a valid versioned payload and ignores no fields', () {
      final result = decoder.decode(const {
        'v': '1',
        'type': 'order.details',
        'interaction_id': 'message-42:tap',
        'order_id': '42',
      });

      final payload = (result as Success<NotificationPayload>).value;
      expect(payload.version, 1);
      expect(payload.type, 'order.details');
      expect(payload.interactionId, 'message-42:tap');
      expect(payload.arguments, {'order_id': '42'});
    });

    test('rejects missing, malformed, and unsupported versions', () {
      for (final data in [
        const {'type': 'order.details', 'interaction_id': 'one'},
        const {'v': 'x', 'type': 'order.details', 'interaction_id': 'two'},
        const {'v': '2', 'type': 'order.details', 'interaction_id': 'three'},
      ]) {
        expect(decoder.decode(data), isA<Failure<NotificationPayload>>());
      }
    });

    test('rejects invalid identity, oversized payload, and argument abuse', () {
      expect(
        decoder.decode(const {
          'v': '1',
          'type': '../route',
          'interaction_id': 'id',
        }),
        isA<Failure<NotificationPayload>>(),
      );
      expect(
        const NotificationPayloadDecoder(
          maximumEncodedBytes: 10,
        ).decode(const {'v': '1', 'type': 'type', 'interaction_id': 'id'}),
        isA<Failure<NotificationPayload>>(),
      );
      expect(
        const NotificationPayloadDecoder(maximumArguments: 0).decode(const {
          'v': '1',
          'type': 'type',
          'interaction_id': 'id',
          'extra': 'value',
        }),
        isA<Failure<NotificationPayload>>(),
      );
    });
  });

  group('InteractionDeduplicator', () {
    test(
      'claims duplicate interactions exactly once under concurrency',
      () async {
        final store = MemoryHandledInteractionStore();
        final deduplicator = InteractionDeduplicator(store: store);

        final results = await Future.wait(
          List.generate(20, (_) => deduplicator.claim('same-interaction')),
        );

        expect(
          results.where((result) => (result as Success<bool>).value),
          hasLength(1),
        );
        expect(store.ids, ['same-interaction']);
      },
    );

    test('retains only the newest bounded number of handled IDs', () async {
      final store = MemoryHandledInteractionStore();
      final deduplicator = InteractionDeduplicator(
        store: store,
        maximumRetainedIds: 3,
      );

      for (final id in ['one', 'two', 'three', 'four']) {
        expect((await deduplicator.claim(id) as Success<bool>).value, isTrue);
      }

      expect(store.ids, ['two', 'three', 'four']);
      expect(
        (await deduplicator.claim('three') as Success<bool>).value,
        isFalse,
      );
    });

    test('does not claim when durable persistence fails', () async {
      final store = MemoryHandledInteractionStore()
        ..writeFailure = const UnexpectedFailure(message: 'unavailable');
      final deduplicator = InteractionDeduplicator(store: store);

      expect(await deduplicator.claim('interaction'), isA<Failure<bool>>());
      expect(store.ids, isEmpty);
    });
  });

  test('fake client exposes deterministic contract streams', () async {
    final client = FakePushNotificationClient();
    final interaction = NotificationInteraction(
      id: 'tap-1',
      data: const {'v': '1'},
      occurredAt: DateTime.utc(2026, 10, 15),
    );
    final received = Completer<NotificationInteraction>();
    final subscription = client.interactions.listen(received.complete);

    client.addInteraction(interaction);

    expect(await received.future, same(interaction));
    await subscription.cancel();
    await client.dispose();
    expect(client.isDisposed, isTrue);
  });

  test('push token diagnostics redact the token value', () {
    expect(
      const PushToken('secret-token').toString(),
      isNot(contains('secret')),
    );
  });
}

final class _FakeNotificationContractDriver
    implements NotificationContractDriver {
  final FakePushNotificationClient _client = FakePushNotificationClient()
    ..token = const PushToken('contract-token');

  @override
  PushNotificationClient get client => _client;

  @override
  Future<void> injectInteraction(NotificationInteraction interaction) async {
    _client.addInteraction(interaction);
  }
}
