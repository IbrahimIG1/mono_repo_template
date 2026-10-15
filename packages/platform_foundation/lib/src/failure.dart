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

  @override
  String toString() => 'AppFailure(code: $code, message: $message)';
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({
    required super.message,
    super.cause,
    super.stackTrace,
  }) : super(code: 'foundation.unexpected');
}
