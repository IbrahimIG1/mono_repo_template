# ADR-010: Notifications and realtime boundaries

Status: Accepted for Goal 5.

## Decision

`notifications_core` and `realtime_core` are pure-Dart capability packages.
They may depend only on `platform_foundation`; architecture checks reject
Flutter, Firebase, router, `dart:io`, and WebSocket library dependencies in
either core. Platform adapters point inward:

```text
app mapping/coordinator -> notifications_core -> platform_foundation
notifications_fcm ------> notifications_core -> platform_foundation

app codec/auth/protocol -> realtime_core -> platform_foundation
realtime_websocket -----> realtime_core -> platform_foundation
```

Firebase configuration, APNs material, payload destination mapping, routing,
event names, codecs, authorization shape, and resynchronization remain app-owned.
`notifications_fcm` and `realtime_websocket` target Android and iOS only in V2.

## Notification interaction policy

Payloads carry a strict version plus validated type and interaction identity.
The app maps the validated payload to an allow-listed internal destination, then
reuses the existing destination policy and session-aware router. The coordinator
serializes interactions, waits for router and session readiness, re-authorizes
protected destinations, and durably claims the interaction ID before navigation.

The claim ledger is bounded. Claim-before-navigation prevents duplicate routing
but can lose an interaction if the process dies between those two operations.
A product needing crash-safe exactly-once workflow must add a durable pending
inbox; it must not silently turn navigation into an unbounded retry loop.

The FCM background entry point is top-level and constructs only its own payload
decoder. It never assumes foreground DI or navigation. Apps requiring background
persistence provide an app-owned top-level handler with isolate-safe dependencies.

## Realtime lifecycle policy

- Concurrent `connect()` calls share one attempt; a connected call is idempotent
  for the same endpoint.
- `emit()` before connection fails and is not queued implicitly.
- Connect cancellation and timeout abandon the generation; a late socket is
  closed and cannot publish state.
- Subscriptions are logical registrations and their app-defined control frames
  are restored after reconnect.
- Events preserve arrival order within one connection. Reconnect creates a gap
  boundary and requires authoritative API resynchronization.
- Inbound buffering is bounded with explicit drop-oldest, drop-newest, or
  disconnect policy. Disconnect is the default because silent data loss is a
  poor default for stateful events.
- Reconnect uses capped exponential delay, injected jitter, a maximum attempt
  count, and cancellation on manual disconnect/disposal.
- Heartbeat names and acknowledgement matching are protocol inputs, not fixed
  package constants.
- Disposal is terminal; generation checks prevent late callbacks and events.

## Evidence and limits

The same transport-neutral contract suite runs against the fake and a real
`dart:io` WebSocket connected to a deterministic local server. This proves the
specified process behavior, not real mobile network/background reliability.
Those transport and push claims remain `Manual-validation-required` until
physical-device results are recorded.
