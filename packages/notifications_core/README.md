# notifications_core

Pure-Dart notification contracts, strict versioned payload decoding, test fakes,
and a race-safe bounded interaction deduplicator. Platform delivery and app
navigation do not belong in this package.

`InteractionDeduplicator.claim` persists an ID before navigation is allowed.
That gives at-most-once handling for a shared store, including concurrent taps.
The deliberate trade-off is that a process failure after the claim but before
navigation can lose that interaction. Apps that require crash-safe delivery
must add a durable pending-inbox state machine rather than weakening deduplication.
