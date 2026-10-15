import 'package:platform_foundation/platform_foundation.dart';

enum StorageOperation { read, remove, write }

final class StorageFailure extends AppFailure {
  const StorageFailure({
    required this.operation,
    required super.code,
    required super.message,
    super.cause,
    super.stackTrace,
  });

  final StorageOperation operation;
}
