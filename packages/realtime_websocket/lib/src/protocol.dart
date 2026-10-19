import 'package:realtime_core/realtime_core.dart';

abstract interface class RealtimeWebSocketProtocol {
  String heartbeatFrame();
  bool isHeartbeatAcknowledgement(String frame);
  Iterable<String> subscribeFrames(RealtimeSubscriptionRequest request);
  Iterable<String> unsubscribeFrames(RealtimeSubscriptionRequest request);
}

final class NoControlFramesProtocol implements RealtimeWebSocketProtocol {
  const NoControlFramesProtocol();

  @override
  String heartbeatFrame() => '';

  @override
  bool isHeartbeatAcknowledgement(String frame) => false;

  @override
  Iterable<String> subscribeFrames(RealtimeSubscriptionRequest request) =>
      const [];

  @override
  Iterable<String> unsubscribeFrames(RealtimeSubscriptionRequest request) =>
      const [];
}
