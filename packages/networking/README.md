# networking

Framework-neutral HTTP contracts plus an injected Dio adapter.

- Import `package:networking/networking.dart` for `NetworkClient`, request/response models, configuration, and typed failures.
- Import `package:networking/dio.dart` only in an app composition root or adapter test.
- Apps provide endpoints and DTO parsing. Authentication is connected through
  `AccessTokenProvider` and `UnauthorizedRecovery`; the networking package does
  not depend on auth models.

Unauthorized replay is limited to one attempt. A body is replayable only when
it is absent or supplied by `bodyFactory`. Refresh/revocation requests can opt
out, and cancellation plus one absolute deadline cover the initial request,
refresh wait, and replay. Non-auth retry policy remains app-owned.

The adapter logs method, path, status, and failure code only. It does not log request or response bodies. Call `close()` from the owning composition root.
