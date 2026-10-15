# networking

Framework-neutral HTTP contracts plus an injected Dio adapter.

- Import `package:networking/networking.dart` for `NetworkClient`, request/response models, configuration, and typed failures.
- Import `package:networking/dio.dart` only in an app composition root or adapter test.
- Provide endpoints, authentication headers, DTO parsing, retry policy, and token refresh from higher layers. Those policies are intentionally not hidden here.

The adapter logs method, path, status, and failure code only. It does not log request or response bodies. Call `close()` from the owning composition root.
