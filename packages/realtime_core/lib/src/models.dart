import 'dart:async';

import 'package:platform_foundation/platform_foundation.dart';

enum RealtimeConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  disposed,
}

enum RealtimeOverflowPolicy { dropOldest, dropNewest, disconnect }

final class RealtimeConfiguration {
  const RealtimeConfiguration({
    required this.endpoint,
    this.maximumBufferedEvents = 256,
    this.overflowPolicy = RealtimeOverflowPolicy.disconnect,
  }) : assert(maximumBufferedEvents > 0);

  final Uri endpoint;
  final int maximumBufferedEvents;
  final RealtimeOverflowPolicy overflowPolicy;
}

final class RealtimeEvent {
  const RealtimeEvent({
    required this.name,
    required this.payload,
    this.sequence,
  });

  final String name;
  final Map<String, Object?> payload;
  final int? sequence;
}

final class OutgoingRealtimeEvent {
  const OutgoingRealtimeEvent({required this.name, required this.payload});

  final String name;
  final Map<String, Object?> payload;
}

final class RealtimeSubscriptionRequest {
  const RealtimeSubscriptionRequest({required this.eventNames});

  final Set<String> eventNames;

  bool matches(RealtimeEvent event) => eventNames.contains(event.name);
}

final class RealtimeAuthorization {
  const RealtimeAuthorization({
    this.headers = const {},
    this.queryParameters = const {},
  });

  final Map<String, String> headers;
  final Map<String, String> queryParameters;
}

abstract interface class RealtimeAuthProvider {
  Future<Result<RealtimeAuthorization>> authorization();
}

abstract interface class RealtimeCodec {
  String encode(OutgoingRealtimeEvent event);
  Result<RealtimeEvent> decode(String frame);
}

abstract interface class RealtimeCancellation {
  bool get isCancelled;
  Future<void> get whenCancelled;
}

final class RealtimeCancellationController implements RealtimeCancellation {
  final Completer<void> _cancelled = Completer<void>();

  @override
  bool get isCancelled => _cancelled.isCompleted;

  @override
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (!_cancelled.isCompleted) {
      _cancelled.complete();
    }
  }
}
