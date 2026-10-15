# ADR-001: Foundation Results, Failures, and JSON

Status: Accepted for V2 spike and implementation.

## Context

Reusable packages need exhaustive result handling without forcing capability-specific failures into one foundation library. Models remain handwritten; typed routes are the only approved code generation.

## Decision

`Result<T>` is sealed. `AppFailure` is an externally extensible `abstract base class`, so capability packages can declare `final`, `base`, or `sealed` subtypes in their own libraries.

```dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);
  final AppFailure failure;
}

abstract base class AppFailure {
  const AppFailure({
    required this.code,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  final String code;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
}
```

Consumers exhaustively switch on `Success` and `Failure`. UI does not exhaustively switch on every failure subtype; presentation maps stable failure codes/categories to localized messages.

Raw causes and stack traces are diagnostic data. They are never serialized to users or logged without the redaction policy.

## Handwritten model rules

- Use immutable fields and `const` constructors where practical.
- Parse with `factory Type.fromJson(Map<String, Object?> json)`.
- Emit with `Map<String, Object?> toJson()` when outbound serialization is required.
- Reject missing or incorrectly typed required fields; do not coerce with `toString()`.
- Treat optional missing values as `null` or an explicitly documented default.
- Ignore unknown fields unless strict validation is required for security/protocol correctness.
- Give enums an `unknown` value and test unknown wire values.
- Normalize documented timestamps to UTC; do not use device time for server ordering.
- Preserve identifier wire types unless an explicit mapper changes them.
- Omit null output fields unless the endpoint requires explicit null.
- Implement value equality for domain/value models. DTO equality is required only when a real state/test consumer needs it.
- Map parse errors to a serialization failure at the repository/adapter boundary.
- A feature may share a wire/domain model only when their semantics are genuinely identical and documented.

Every DTO requires fixtures for valid data, missing required fields, nullable fields, unknown enums and additional unknown fields.

## Consequences

- Result switches remain exhaustive.
- Capability failures remain capability-owned.
- No Freezed, json_serializable or model builder is introduced.
- Failure codes become part of the internal contract and require stable naming.
