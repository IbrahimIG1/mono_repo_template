# ADR-004: Chat Event-Source Boundary

Status: Accepted design constraint; implementation is deferred to V2.1.

## Context

Chat must support history/API-only operation, fakes, WebSocket and possible future transports. Depending directly on `realtime_core` would make transport orchestration part of the chat engine and contradict optional capability boundaries.

## Decision

`chat_core` depends on `platform_foundation` only. It owns typed chat events and an event-source port:

```dart
abstract interface class ChatEventSource {
  Stream<ChatEvent> get events;
  Future<Result<void>> start();
  Future<void> stop();
}
```

The app may provide:

- a realtime-backed adapter that maps `RealtimeEvent` to `ChatEvent`;
- a polling adapter;
- a fake/test source;
- a no-event source for history-only behavior.

Transport names, payload codecs and connection state never appear in `chat_core` public models.

## V2.1 admission constraints

- Durable automatic resend requires a server idempotency key or equivalent reconciliation lookup.
- Message acceptance, delivery, read and typing semantics must be documented before outbox implementation.
- Socket events are hints; API/history reconciliation remains authoritative.
- Client FIFO is not represented as a cross-device guarantee without server sequence enforcement.

## Consequences

- Chat works without realtime.
- Transport packages remain independently optional.
- Apps own backend event mapping and authorization.
