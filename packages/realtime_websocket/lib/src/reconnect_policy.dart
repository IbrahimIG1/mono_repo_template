import 'dart:math';

final class WebSocketReconnectPolicy {
  const WebSocketReconnectPolicy({
    this.maximumAttempts = 5,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maximumDelay = const Duration(seconds: 15),
    this.jitterFactor = 0.2,
  }) : assert(maximumAttempts >= 0),
       assert(jitterFactor >= 0 && jitterFactor <= 1);

  final int maximumAttempts;
  final Duration baseDelay;
  final Duration maximumDelay;
  final double jitterFactor;

  Duration delayForAttempt(int attempt, double randomUnit) {
    final exponent = max(0, attempt - 1);
    final multiplier = pow(2, exponent).toInt();
    final uncapped = baseDelay.inMilliseconds * multiplier;
    final capped = min(uncapped, maximumDelay.inMilliseconds);
    final jitter = capped * jitterFactor * ((randomUnit * 2) - 1);
    return Duration(milliseconds: max(0, (capped + jitter).round()));
  }
}
