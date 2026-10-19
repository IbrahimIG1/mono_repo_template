# realtime_websocket

Android/iOS `dart:io` WebSocket adapter for `realtime_core`. It implements
serialized connect, cancellation generation guards, heartbeat timeout, bounded
reconnect with jitter, subscription restoration, bounded inbound buffering, and
terminal disposal.

Apps inject the codec, authorization provider, endpoint, event/control-frame
names, and resynchronization behavior. Authentication material is applied to the
handshake but never logged. A reconnect restores logical subscriptions; it does
not promise missed-event recovery or cross-connection ordering.
