# realtime_core

Pure-Dart realtime contracts, lifecycle policy, bounded buffering, a fake client,
and a transport-neutral contract suite.

Contract semantics:

- `connect()` is idempotent while connected and concurrent callers share one
  in-flight attempt.
- `emit()` before a successful connection returns `realtime.not_connected`; it
  is never silently queued.
- logical subscriptions remain registered across transport reconnects until
  explicitly cancelled.
- decoded events retain transport arrival order within one connection. No
  ordering or gap-free guarantee crosses a reconnect; consumers resynchronize
  authoritative state through their API.
- inbound adapter buffers are bounded. `dropOldest`, `dropNewest`, and
  `disconnect` are explicit policies; `disconnect` is the safe default.
- cancellation stops an in-flight connect for that client. Disposal is terminal
  and no event may be emitted afterward.

Event names, payload schemas, codecs, authentication, and resynchronization are
app-owned.
