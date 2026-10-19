import 'package:platform_foundation/platform_foundation.dart';

import 'models.dart';

abstract interface class RealtimeSubscription {
  Stream<RealtimeEvent> get events;
  Future<void> cancel();
}

abstract interface class RealtimeClient {
  RealtimeConnectionState get currentState;
  Stream<RealtimeConnectionState> get connectionStates;
  Stream<RealtimeEvent> get events;

  Future<Result<void>> connect(
    RealtimeConfiguration configuration, {
    RealtimeCancellation? cancellation,
  });
  Future<Result<void>> emit(OutgoingRealtimeEvent event);
  RealtimeSubscription subscribe(RealtimeSubscriptionRequest request);
  Future<void> disconnect();
  Future<void> dispose();
}
