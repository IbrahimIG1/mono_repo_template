import 'dart:async';
import 'dart:math';

import 'package:platform_foundation/platform_foundation.dart';
import 'package:realtime_core/realtime_core.dart';

import 'protocol.dart';
import 'reconnect_policy.dart';
import 'websocket_connection.dart';

typedef ReconnectDelay = Future<void> Function(Duration duration);

final class RealtimeWebSocketClient implements RealtimeClient {
  RealtimeWebSocketClient({
    required this.codec,
    required this.authProvider,
    required this.protocol,
    this.connector = const IoWebSocketConnector(),
    this.reconnectPolicy = const WebSocketReconnectPolicy(),
    this.heartbeatInterval = const Duration(seconds: 20),
    this.heartbeatTimeout = const Duration(seconds: 45),
    this.connectionTimeout = const Duration(seconds: 15),
    Random? random,
    ReconnectDelay? delay,
  }) : _random = random ?? Random.secure(),
       _delay = delay ?? Future<void>.delayed;

  final RealtimeCodec codec;
  final RealtimeAuthProvider authProvider;
  final RealtimeWebSocketProtocol protocol;
  final WebSocketReconnectPolicy reconnectPolicy;
  final Duration heartbeatInterval;
  final Duration heartbeatTimeout;
  final Duration connectionTimeout;
  final WebSocketConnector connector;
  final Random _random;
  final ReconnectDelay _delay;

  final StreamController<RealtimeConnectionState> _states =
      StreamController.broadcast();
  final StreamController<RealtimeEvent> _events = StreamController.broadcast();
  final Set<_WebSocketRealtimeSubscription> _subscriptions = {};
  RealtimeConnectionState _state = RealtimeConnectionState.disconnected;
  RealtimeConfiguration? _configuration;
  WebSocketConnection? _connection;
  StreamSubscription<Object?>? _messageSubscription;
  Future<Result<void>>? _connectOperation;
  Future<Result<void>>? _reconnectOperation;
  Timer? _heartbeatTimer;
  DateTime _lastActivity = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  var _generation = 0;
  var _manualDisconnect = false;
  var _drainScheduled = false;
  var _transportConnectAttempts = 0;
  BoundedEventBuffer<String>? _buffer;

  int get transportConnectAttempts => _transportConnectAttempts;

  @override
  RealtimeConnectionState get currentState => _state;

  @override
  Stream<RealtimeConnectionState> get connectionStates => _states.stream;

  @override
  Stream<RealtimeEvent> get events => _events.stream;

  @override
  Future<Result<void>> connect(
    RealtimeConfiguration configuration, {
    RealtimeCancellation? cancellation,
  }) {
    if (_state == RealtimeConnectionState.disposed) {
      return Future.value(_failure(RealtimeFailureKind.disposed, 'disposed'));
    }
    if (_state == RealtimeConnectionState.connected) {
      if (_configuration?.endpoint != configuration.endpoint) {
        return Future.value(
          _failure(RealtimeFailureKind.protocol, 'configuration_changed'),
        );
      }
      return Future.value(const Success(null));
    }
    final existing = _connectOperation;
    if (existing != null) {
      return existing;
    }
    final reconnecting = _reconnectOperation;
    if (reconnecting != null) {
      if (_configuration?.endpoint != configuration.endpoint) {
        return Future.value(
          _failure(RealtimeFailureKind.protocol, 'configuration_changed'),
        );
      }
      return reconnecting;
    }
    _manualDisconnect = false;
    _configuration = configuration;
    _buffer = BoundedEventBuffer(
      maximumSize: configuration.maximumBufferedEvents,
      overflowPolicy: configuration.overflowPolicy,
    );
    final operation = _open(configuration, cancellation: cancellation);
    _connectOperation = operation;
    return operation.whenComplete(() => _connectOperation = null);
  }

  Future<Result<void>> _open(
    RealtimeConfiguration configuration, {
    RealtimeCancellation? cancellation,
    bool reconnecting = false,
  }) async {
    final generation = ++_generation;
    _setState(
      reconnecting
          ? RealtimeConnectionState.reconnecting
          : RealtimeConnectionState.connecting,
    );
    if (cancellation?.isCancelled ?? false) {
      _setState(RealtimeConnectionState.disconnected);
      return _failure(RealtimeFailureKind.cancelled, 'connect_cancelled');
    }

    final authorization = await authProvider.authorization();
    if (authorization case Failure<RealtimeAuthorization>(:final failure)) {
      _setState(RealtimeConnectionState.disconnected);
      return Failure(failure);
    }
    final auth = (authorization as Success<RealtimeAuthorization>).value;
    final endpoint = configuration.endpoint.replace(
      queryParameters: {
        ...configuration.endpoint.queryParameters,
        ...auth.queryParameters,
      },
    );
    try {
      _transportConnectAttempts++;
      final connectionFuture = connector.connect(
        endpoint,
        headers: auth.headers,
      );
      final connection = await _awaitConnection(connectionFuture, cancellation);
      if (connection == null) {
        _setState(RealtimeConnectionState.disconnected);
        return _failure(RealtimeFailureKind.cancelled, 'connect_cancelled');
      }
      if (_state == RealtimeConnectionState.disposed ||
          generation != _generation) {
        await connection.close();
        return _failure(RealtimeFailureKind.cancelled, 'stale_connection');
      }
      _connection = connection;
      _lastActivity = DateTime.now().toUtc();
      _messageSubscription = connection.messages.listen(
        (message) => _onMessage(message, generation),
        onError: (_, _) => _onTransportEnded(generation),
        onDone: () => _onTransportEnded(generation),
        cancelOnError: true,
      );
      _restoreSubscriptions();
      _startHeartbeat(generation);
      _setState(RealtimeConnectionState.connected);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      if (generation == _generation &&
          _state != RealtimeConnectionState.disposed) {
        _setState(RealtimeConnectionState.disconnected);
      }
      return Failure(
        RealtimeFailure(
          kind: RealtimeFailureKind.transport,
          code: 'realtime.websocket_connect_failed',
          message: 'WebSocket connection failed.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<WebSocketConnection?> _awaitConnection(
    Future<WebSocketConnection> connection,
    RealtimeCancellation? cancellation,
  ) async {
    var abandoned = false;
    final timedConnection = connection.timeout(
      connectionTimeout,
      onTimeout: () {
        abandoned = true;
        throw TimeoutException('WebSocket connection timed out.');
      },
    );
    if (cancellation == null) {
      try {
        return await timedConnection;
      } finally {
        if (abandoned) {
          _closeLateConnection(connection);
        }
      }
    }
    final cancelled = Object();
    late final Object winner;
    try {
      winner = await Future.any<Object>([
        timedConnection,
        cancellation.whenCancelled.then<Object>((_) => cancelled),
      ]);
    } finally {
      if (abandoned) {
        _closeLateConnection(connection);
      }
    }
    if (identical(winner, cancelled)) {
      abandoned = true;
      _closeLateConnection(connection);
      return null;
    }
    return winner as WebSocketConnection;
  }

  void _closeLateConnection(Future<WebSocketConnection> connection) {
    unawaited(
      connection.then<void>((late) => late.close(), onError: (_, _) {}),
    );
  }

  void _onMessage(Object? message, int generation) {
    if (generation != _generation ||
        _state == RealtimeConnectionState.disposed ||
        message is! String) {
      return;
    }
    _lastActivity = DateTime.now().toUtc();
    if (protocol.isHeartbeatAcknowledgement(message)) {
      return;
    }
    final result = _buffer!.add(message);
    if (result == BufferAddResult.disconnectRequired) {
      unawaited(_endCurrentConnection(triggerReconnect: true));
      return;
    }
    if (result == BufferAddResult.droppedNewest || _drainScheduled) {
      return;
    }
    _drainScheduled = true;
    scheduleMicrotask(_drainBuffer);
  }

  void _drainBuffer() {
    _drainScheduled = false;
    final buffer = _buffer;
    if (buffer == null || _state == RealtimeConnectionState.disposed) {
      return;
    }
    while (buffer.length > 0) {
      final decoded = codec.decode(buffer.removeFirst());
      if (decoded case Success<RealtimeEvent>(:final value)) {
        _events.add(value);
        for (final subscription in _subscriptions.toList(growable: false)) {
          subscription.add(value);
        }
      }
    }
  }

  void _onTransportEnded(int generation) {
    if (generation != _generation ||
        _manualDisconnect ||
        _state == RealtimeConnectionState.disposed) {
      return;
    }
    _heartbeatTimer?.cancel();
    _connection = null;
    _messageSubscription = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectOperation != null || _configuration == null) {
      return;
    }
    final operation = _runReconnect();
    _reconnectOperation = operation;
    unawaited(operation.whenComplete(() => _reconnectOperation = null));
  }

  Future<Result<void>> _runReconnect() async {
    final configuration = _configuration!;
    Result<void>? lastFailure;
    for (
      var attempt = 1;
      attempt <= reconnectPolicy.maximumAttempts;
      attempt++
    ) {
      if (_manualDisconnect || _state == RealtimeConnectionState.disposed) {
        return _failure(RealtimeFailureKind.cancelled, 'reconnect_cancelled');
      }
      _setState(RealtimeConnectionState.reconnecting);
      await _delay(
        reconnectPolicy.delayForAttempt(attempt, _random.nextDouble()),
      );
      if (_manualDisconnect || _state == RealtimeConnectionState.disposed) {
        return _failure(RealtimeFailureKind.cancelled, 'reconnect_cancelled');
      }
      final result = await _open(configuration, reconnecting: true);
      if (result is Success<void>) {
        return result;
      }
      lastFailure = result;
    }
    if (_state != RealtimeConnectionState.disposed) {
      _setState(RealtimeConnectionState.disconnected);
    }
    return lastFailure ??
        _failure(RealtimeFailureKind.transport, 'reconnect_exhausted');
  }

  void _startHeartbeat(int generation) {
    _heartbeatTimer?.cancel();
    if (heartbeatInterval <= Duration.zero) {
      return;
    }
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      if (generation != _generation ||
          _state != RealtimeConnectionState.connected) {
        return;
      }
      if (DateTime.now().toUtc().difference(_lastActivity) > heartbeatTimeout) {
        unawaited(_endCurrentConnection(triggerReconnect: true));
        return;
      }
      final frame = protocol.heartbeatFrame();
      if (frame.isNotEmpty) {
        _sendFrame(frame);
      }
    });
  }

  @override
  Future<Result<void>> emit(OutgoingRealtimeEvent event) async {
    if (_state == RealtimeConnectionState.disposed) {
      return _failure(RealtimeFailureKind.disposed, 'disposed');
    }
    if (_state != RealtimeConnectionState.connected || _connection == null) {
      return _failure(RealtimeFailureKind.notConnected, 'not_connected');
    }
    try {
      _sendFrame(codec.encode(event));
      return const Success(null);
    } on Object catch (error, stackTrace) {
      return Failure(
        RealtimeFailure(
          kind: RealtimeFailureKind.transport,
          code: 'realtime.websocket_emit_failed',
          message: 'WebSocket emit failed.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  RealtimeSubscription subscribe(RealtimeSubscriptionRequest request) {
    final subscription = _WebSocketRealtimeSubscription(request, () {});
    subscription.onCancel = () {
      _subscriptions.remove(subscription);
      if (_state == RealtimeConnectionState.connected) {
        for (final frame in protocol.unsubscribeFrames(request)) {
          _sendFrame(frame);
        }
      }
    };
    _subscriptions.add(subscription);
    if (_state == RealtimeConnectionState.connected) {
      for (final frame in protocol.subscribeFrames(request)) {
        _sendFrame(frame);
      }
    }
    return subscription;
  }

  void _restoreSubscriptions() {
    for (final subscription in _subscriptions) {
      for (final frame in protocol.subscribeFrames(subscription.request)) {
        _sendFrame(frame);
      }
    }
  }

  void _sendFrame(String frame) => _connection?.add(frame);

  Future<void> _endCurrentConnection({required bool triggerReconnect}) async {
    _heartbeatTimer?.cancel();
    final connection = _connection;
    _connection = null;
    await _messageSubscription?.cancel();
    _messageSubscription = null;
    if (connection != null) {
      await connection.close();
    }
    if (triggerReconnect && !_manualDisconnect) {
      _scheduleReconnect();
    }
  }

  @override
  Future<void> disconnect() async {
    if (_state == RealtimeConnectionState.disposed) {
      return;
    }
    _manualDisconnect = true;
    _generation++;
    await _endCurrentConnection(triggerReconnect: false);
    _buffer?.clear();
    _setState(RealtimeConnectionState.disconnected);
  }

  @override
  Future<void> dispose() async {
    if (_state == RealtimeConnectionState.disposed) {
      return;
    }
    _manualDisconnect = true;
    _generation++;
    _heartbeatTimer?.cancel();
    await _endCurrentConnection(triggerReconnect: false);
    _setState(RealtimeConnectionState.disposed);
    for (final subscription in _subscriptions.toList(growable: false)) {
      await subscription.cancel();
    }
    await Future.wait([_states.close(), _events.close()]);
  }

  void _setState(RealtimeConnectionState value) {
    if (_state == value || _state == RealtimeConnectionState.disposed) {
      return;
    }
    _state = value;
    _states.add(value);
  }

  Failure<void> _failure(RealtimeFailureKind kind, String suffix) => Failure(
    RealtimeFailure(
      kind: kind,
      code: 'realtime.$suffix',
      message: 'Realtime WebSocket operation failed.',
    ),
  );
}

final class _WebSocketRealtimeSubscription implements RealtimeSubscription {
  _WebSocketRealtimeSubscription(this.request, this.onCancel);

  final RealtimeSubscriptionRequest request;
  final StreamController<RealtimeEvent> _events = StreamController.broadcast();
  void Function() onCancel;
  var _cancelled = false;

  @override
  Stream<RealtimeEvent> get events => _events.stream;

  void add(RealtimeEvent event) {
    if (!_cancelled && request.matches(event)) {
      _events.add(event);
    }
  }

  @override
  Future<void> cancel() async {
    if (_cancelled) {
      return;
    }
    _cancelled = true;
    onCancel();
    await _events.close();
  }
}
