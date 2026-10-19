import 'package:platform_foundation/platform_foundation.dart';
import 'package:realtime_core/realtime_core.dart';
import 'package:realtime_core/testing.dart';
import 'package:test/test.dart';

void main() {
  test('fake passes the shared realtime contract suite', () async {
    await verifyRealtimeContract(() async => _FakeDriver());
  });

  test(
    'connect cancellation is explicit and leaves the client disconnected',
    () async {
      final client = FakeRealtimeClient();
      final cancellation = RealtimeCancellationController()..cancel();

      final result = await client.connect(
        RealtimeConfiguration(endpoint: Uri.parse('ws://localhost')),
        cancellation: cancellation,
      );

      expect(result, isA<Failure<void>>());
      expect(client.currentState, RealtimeConnectionState.disconnected);
      await client.dispose();
    },
  );

  group('BoundedEventBuffer', () {
    test('drop-oldest retains the newest bounded events', () {
      final buffer =
          BoundedEventBuffer<int>(
              maximumSize: 2,
              overflowPolicy: RealtimeOverflowPolicy.dropOldest,
            )
            ..add(1)
            ..add(2);

      expect(buffer.add(3), BufferAddResult.accepted);
      expect(buffer.snapshot(), [2, 3]);
    });

    test('drop-newest leaves the queued events unchanged', () {
      final buffer = BoundedEventBuffer<int>(
        maximumSize: 1,
        overflowPolicy: RealtimeOverflowPolicy.dropNewest,
      )..add(1);

      expect(buffer.add(2), BufferAddResult.droppedNewest);
      expect(buffer.snapshot(), [1]);
    });

    test('disconnect reports overflow without growing the queue', () {
      final buffer = BoundedEventBuffer<int>(
        maximumSize: 1,
        overflowPolicy: RealtimeOverflowPolicy.disconnect,
      )..add(1);

      expect(buffer.add(2), BufferAddResult.disconnectRequired);
      expect(buffer.snapshot(), [1]);
    });
  });
}

final class _FakeDriver implements RealtimeContractDriver {
  final FakeRealtimeClient _client = FakeRealtimeClient();

  @override
  RealtimeClient get client => _client;

  @override
  RealtimeConfiguration get configuration =>
      RealtimeConfiguration(endpoint: Uri.parse('ws://localhost'));

  @override
  int get transportConnectAttempts => _client.connectAttempts;

  @override
  Future<void> forceTransportReconnect() => _client.simulateReconnect();

  @override
  Future<void> injectServerEvent(RealtimeEvent event) async {
    _client.addIncoming(event);
  }
}
