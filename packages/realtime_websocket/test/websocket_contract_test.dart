import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:platform_foundation/platform_foundation.dart';
import 'package:realtime_core/realtime_core.dart';
import 'package:realtime_core/testing.dart';
import 'package:realtime_websocket/realtime_websocket.dart';
import 'package:realtime_websocket/testing.dart';
import 'package:test/test.dart';

void main() {
  test('real local WebSocket passes the shared realtime contract', () async {
    await verifyRealtimeContract(() async {
      final server = await _LocalRealtimeServer.start();
      return _WebSocketDriver(server);
    });
  });

  test(
    'handshake auth, heartbeat, and subscription restoration are app-owned',
    () async {
      final server = await _LocalRealtimeServer.start();
      final driver = _WebSocketDriver(server);
      final subscription = driver.client.subscribe(
        const RealtimeSubscriptionRequest(eventNames: {'message'}),
      );

      try {
        expect(
          await driver.client.connect(driver.configuration),
          isA<Success<void>>(),
        );
        await server.waitFor(() => server.heartbeatCount > 0);

        expect(server.lastAuthorization, 'Bearer test-token');
        expect(server.subscriptionCount, 1);

        await driver.forceTransportReconnect();
        await server.waitFor(() => server.subscriptionCount == 2);
        expect(server.subscriptionCount, 2);
      } finally {
        await subscription.cancel();
        await driver.client.dispose();
        await server.close();
      }
    },
  );

  test('in-flight connection cancellation closes a late socket', () async {
    final connector = _BlockingConnector();
    final client = RealtimeWebSocketClient(
      codec: const _JsonRealtimeCodec(),
      authProvider: const _TestAuthProvider(),
      protocol: const _TestProtocol(),
      connector: connector,
      heartbeatInterval: Duration.zero,
    );
    final cancellation = RealtimeCancellationController();

    final connecting = client.connect(
      RealtimeConfiguration(endpoint: Uri.parse('ws://localhost')),
      cancellation: cancellation,
    );
    cancellation.cancel();
    final result = await connecting;
    final lateConnection = _MemoryConnection();
    connector.complete(lateConnection);
    await Future<void>.delayed(Duration.zero);

    expect(result, isA<Failure<void>>());
    expect(lateConnection.closed, isTrue);
    expect(client.currentState, RealtimeConnectionState.disconnected);
    await client.dispose();
  });

  test('reconnect attempts are bounded after the server disappears', () async {
    final server = await _LocalRealtimeServer.start();
    final client = _createClient(
      reconnectPolicy: const WebSocketReconnectPolicy(
        maximumAttempts: 2,
        baseDelay: Duration(milliseconds: 20),
        maximumDelay: Duration(milliseconds: 20),
        jitterFactor: 0,
      ),
    );
    await client.connect(RealtimeConfiguration(endpoint: server.endpoint));

    await server.waitFor(() => server.connectionCount == 1);
    await server.dropCurrentConnection();
    await server.stopAccepting();
    await _waitFor(
      () => client.currentState == RealtimeConnectionState.disconnected,
      description: 'reconnect attempts did not finish',
      diagnostic: () =>
          'state=${client.currentState}, attempts=${client.transportConnectAttempts}',
    );

    expect(client.currentState, RealtimeConnectionState.disconnected);
    await client.dispose();
  });
}

RealtimeWebSocketClient _createClient({
  WebSocketReconnectPolicy reconnectPolicy = const WebSocketReconnectPolicy(
    maximumAttempts: 3,
    baseDelay: Duration(milliseconds: 1),
    maximumDelay: Duration(milliseconds: 2),
    jitterFactor: 0,
  ),
}) => RealtimeWebSocketClient(
  codec: const _JsonRealtimeCodec(),
  authProvider: const _TestAuthProvider(),
  protocol: const _TestProtocol(),
  reconnectPolicy: reconnectPolicy,
  heartbeatInterval: const Duration(milliseconds: 10),
  heartbeatTimeout: const Duration(milliseconds: 100),
  connectionTimeout: const Duration(milliseconds: 50),
  random: Random(1),
);

final class _WebSocketDriver implements RealtimeContractDriver {
  _WebSocketDriver(this.server) : _client = _createClient() {
    _client.events.listen((_) => _observedEvents++);
  }

  final _LocalRealtimeServer server;
  final RealtimeWebSocketClient _client;
  var _observedEvents = 0;
  var _injectedEvents = 0;

  @override
  RealtimeClient get client => _client;

  @override
  RealtimeConfiguration get configuration =>
      RealtimeConfiguration(endpoint: server.endpoint);

  @override
  int get transportConnectAttempts => _client.transportConnectAttempts;

  @override
  Future<void> injectServerEvent(RealtimeEvent event) async {
    _injectedEvents++;
    await server.send(event);
    if (_client.currentState == RealtimeConnectionState.disposed) {
      await Future<void>.delayed(Duration.zero);
      return;
    }
    await _waitFor(
      () => _observedEvents >= _injectedEvents,
      description: 'server event $_injectedEvents was not observed',
    );
  }

  @override
  Future<void> forceTransportReconnect() async {
    final previous = server.connectionCount;
    await server.dropCurrentConnection();
    await server.waitFor(() => server.connectionCount > previous);
    await _waitFor(
      () => _client.currentState == RealtimeConnectionState.connected,
    );
  }
}

final class _LocalRealtimeServer {
  _LocalRealtimeServer._(this._server) {
    _subscription = _server.listen(_onRequest);
  }

  static Future<_LocalRealtimeServer> start() async => _LocalRealtimeServer._(
    await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
  );

  final HttpServer _server;
  late final StreamSubscription<HttpRequest> _subscription;
  final List<WebSocket> _connections = [];
  int connectionCount = 0;
  int subscriptionCount = 0;
  int heartbeatCount = 0;
  String? lastAuthorization;

  Uri get endpoint => Uri.parse('ws://${_server.address.host}:${_server.port}');

  Future<void> _onRequest(HttpRequest request) async {
    lastAuthorization = request.headers.value(HttpHeaders.authorizationHeader);
    final socket = await WebSocketTransformer.upgrade(request);
    connectionCount++;
    _connections.add(socket);
    socket.listen((frame) {
      if (frame == 'heartbeat') {
        heartbeatCount++;
        if (socket.readyState == WebSocket.open) {
          try {
            socket.add('heartbeat_ack');
          } on StateError {
            // The peer can close between the ready-state check and the add.
          }
        }
      } else if (frame == 'subscribe:message') {
        subscriptionCount++;
      }
    });
  }

  Future<void> send(RealtimeEvent event) async {
    await waitFor(() => _connections.isNotEmpty);
    final socket = _connections.last;
    if (socket.readyState != WebSocket.open) {
      return;
    }
    socket.add(
      jsonEncode({
        'name': event.name,
        'payload': event.payload,
        if (event.sequence != null) 'sequence': event.sequence,
      }),
    );
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> dropCurrentConnection() async {
    final socket = _connections.isEmpty ? null : _connections.last;
    if (socket != null) {
      await socket.close(WebSocketStatus.goingAway, 'test reconnect');
    }
  }

  Future<void> stopAccepting() async {
    await _subscription.cancel();
    await _server.close(force: true);
  }

  Future<void> waitFor(bool Function() condition) => _waitFor(condition);

  Future<void> close() async {
    await _subscription.cancel();
    await _server.close(force: true);
    for (final connection in _connections) {
      await connection.close();
    }
  }
}

final class _JsonRealtimeCodec implements RealtimeCodec {
  const _JsonRealtimeCodec();

  @override
  Result<RealtimeEvent> decode(String frame) {
    try {
      final json = jsonDecode(frame);
      if (json is! Map<String, Object?> ||
          json['name'] is! String ||
          json['payload'] is! Map<String, Object?>) {
        throw const FormatException('Invalid event frame.');
      }
      return Success(
        RealtimeEvent(
          name: json['name']! as String,
          payload: Map.unmodifiable(json['payload']! as Map<String, Object?>),
          sequence: json['sequence'] as int?,
        ),
      );
    } on Object catch (error, stackTrace) {
      return Failure(
        RealtimeFailure(
          kind: RealtimeFailureKind.protocol,
          code: 'realtime.invalid_test_frame',
          message: 'Invalid test frame.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  String encode(OutgoingRealtimeEvent event) =>
      jsonEncode({'name': event.name, 'payload': event.payload});
}

final class _TestAuthProvider implements RealtimeAuthProvider {
  const _TestAuthProvider();

  @override
  Future<Result<RealtimeAuthorization>> authorization() async => const Success(
    RealtimeAuthorization(headers: {'Authorization': 'Bearer test-token'}),
  );
}

final class _TestProtocol implements RealtimeWebSocketProtocol {
  const _TestProtocol();

  @override
  String heartbeatFrame() => 'heartbeat';

  @override
  bool isHeartbeatAcknowledgement(String frame) => frame == 'heartbeat_ack';

  @override
  Iterable<String> subscribeFrames(RealtimeSubscriptionRequest request) =>
      request.eventNames.map((name) => 'subscribe:$name');

  @override
  Iterable<String> unsubscribeFrames(RealtimeSubscriptionRequest request) =>
      request.eventNames.map((name) => 'unsubscribe:$name');
}

final class _BlockingConnector implements WebSocketConnector {
  final Completer<WebSocketConnection> _connection = Completer();

  @override
  Future<WebSocketConnection> connect(
    Uri endpoint, {
    required Map<String, String> headers,
  }) => _connection.future;

  void complete(WebSocketConnection connection) =>
      _connection.complete(connection);
}

final class _MemoryConnection implements WebSocketConnection {
  final StreamController<Object?> _messages = StreamController.broadcast();
  bool closed = false;

  @override
  Stream<Object?> get messages => _messages.stream;

  @override
  void add(String frame) {}

  @override
  Future<void> close() async {
    closed = true;
    await _messages.close();
  }
}

Future<void> _waitFor(
  bool Function() condition, {
  String description = 'condition was not met',
  String Function()? diagnostic,
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      final details = diagnostic?.call();
      throw TimeoutException(
        details == null ? description : '$description; $details',
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}
