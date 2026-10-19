import 'dart:convert';

import 'package:notifications_core/notifications_core.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:storage/storage.dart';

final class KeyValueHandledInteractionStore implements HandledInteractionStore {
  const KeyValueHandledInteractionStore({
    required this.store,
    this.storageKey = 'v2.handled_notification_interactions',
  });

  final KeyValueStore store;
  final String storageKey;

  @override
  Future<Result<List<String>>> read() async {
    final result = await store.readString(storageKey);
    return switch (result) {
      Failure<String?>(:final failure) => Failure(failure),
      Success<String?>(value: null) => const Success([]),
      Success<String?>(:final value) => _decode(value!),
    };
  }

  Result<List<String>> _decode(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! List<Object?> ||
          decoded.any((value) => value is! String)) {
        throw const FormatException('Expected a string list.');
      }
      return Success(List.unmodifiable(decoded.cast<String>()));
    } on Object catch (error, stackTrace) {
      return Failure(
        NotificationFailure(
          kind: NotificationFailureKind.persistence,
          code: 'notifications.invalid_handled_interactions',
          message: 'Handled notification interaction data is corrupt.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> write(List<String> ids) =>
      store.writeString(storageKey, jsonEncode(ids));
}
