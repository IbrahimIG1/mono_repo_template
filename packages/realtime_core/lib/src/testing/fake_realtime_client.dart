import 'dart:async';

import 'package:platform_foundation/platform_foundation.dart';

import '../client.dart';
import '../failure.dart';
import '../models.dart';

final class FakeRealtimeClient implements RealtimeClient {
  final StreamController<RealtimeConnectionState> _states =
      StreamController.broadcast();
  final StreamController<RealtimeEvent> _events = StreamController.broadcast();
  final Set<_FakeRealtimeSubscription> _subscriptions = {};
  Future<Result<void>>? _connectOperation;
  RealtimeConnectionState _state = RealtimeConnectionState.disconnected;
  RealtimeConfiguration? configuration;
  int connectAttempts = 0;
  final List<OutgoingRealtimeEvent> emittedEvents = [];

  @override
  RealtimeConnectionState get currentState => _state;

  @override
  Stream<RealtimeConnectionState> get connectionStates => _states.stream;

  @override
  Stream<RealtimeEvent> get events => _events.stream;

  @override
  Future<Result<void>> connect(
    RealtimeConfiguration value, {
    RealtimeCancellation? cancellation,
  }) {
    if (_state == RealtimeConnectionState.disposed) {
      return Future.value(_disposed());
    }
    if (_state == RealtimeConnectionState.connected) {
      return Future.value(const Success(null));
    }
    final existing = _connectOperation;
    if (existing != null) {
      return existing;
    }
    final operation = _performConnect(value, cancellation);
    _connectOperation = operation;
    return operation.whenComplete(() => _connectOperation = null);
  }

  Future<Result<void>> _performConnect(
    RealtimeConfiguration value,
    RealtimeCancellation? cancellation,
  ) async {
    connectAttempts++;
    configuration = value;
    _setState(RealtimeConnectionState.connecting);
    await Future<void>.delayed(Duration.zero);
    if (cancellation?.isCancelled ?? false) {
      _setState(RealtimeConnectionState.disconnected);
      return const Failure(
        RealtimeFailure(
          kind: RealtimeFailureKind.cancelled,
          code: 'realtime.connect_cancelled',
          message: 'Realtime connection was cancelled.',
        ),
      );
    }
    _setState(RealtimeConnectionState.connected);
    return const Success(null);
  }

  @override
  Future<Result<void>> emit(OutgoingRealtimeEvent event) async {
    if (_state == RealtimeConnectionState.disposed) {
      return _disposed();
    }
    if (_state != RealtimeConnectionState.connected) {
      return const Failure(
        RealtimeFailure(
          kind: RealtimeFailureKind.notConnected,
          code: 'realtime.not_connected',
          message: 'Connect before emitting an event.',
        ),
      );
    }
    emittedEvents.add(event);
    return const Success(null);
  }

  @override
  RealtimeSubscription subscribe(RealtimeSubscriptionRequest request) {
    final subscription = _FakeRealtimeSubscription(request, () {});
    subscription.onCancel = () => _subscriptions.remove(subscription);
    _subscriptions.add(subscription);
    return subscription;
  }

  void addIncoming(RealtimeEvent event) {
    if (_state != RealtimeConnectionState.connected) {
      return;
    }
    _events.add(event);
    for (final subscription in _subscriptions.toList(growable: false)) {
      subscription.add(event);
    }
  }

  Future<void> simulateReconnect() async {
    if (_state != RealtimeConnectionState.connected) {
      return;
    }
    _setState(RealtimeConnectionState.reconnecting);
    await Future<void>.delayed(Duration.zero);
    _setState(RealtimeConnectionState.connected);
  }

  @override
  Future<void> disconnect() async {
    if (_state == RealtimeConnectionState.disposed) {
      return;
    }
    _setState(RealtimeConnectionState.disconnected);
  }

  @override
  Future<void> dispose() async {
    if (_state == RealtimeConnectionState.disposed) {
      return;
    }
    _setState(RealtimeConnectionState.disposed);
    for (final subscription in _subscriptions.toList(growable: false)) {
      await subscription.cancel();
    }
    await Future.wait([_states.close(), _events.close()]);
  }

  void _setState(RealtimeConnectionState value) {
    if (_state == value) {
      return;
    }
    _state = value;
    _states.add(value);
  }

  Failure<void> _disposed() => const Failure(
    RealtimeFailure(
      kind: RealtimeFailureKind.disposed,
      code: 'realtime.disposed',
      message: 'Realtime client is disposed.',
    ),
  );
}

final class _FakeRealtimeSubscription implements RealtimeSubscription {
  _FakeRealtimeSubscription(this.request, this.onCancel);

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
