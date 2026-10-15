# platform_foundation

Pure-Dart contracts shared by V2 capabilities.

Public API: sealed `Result<T>` with `Success<T>` / `Failure<T>`, externally extensible `AppFailure`, `AppLogger`, `StructuredLogger`, `NullLogger`, and `LogRedactor`.

This package has no Flutter, transport, storage, UI, or legacy dependency. Structured log fields and bearer/query secrets are redacted before reaching the injected sink. Raw causes and stack traces are diagnostic values and must not be shown to users.
