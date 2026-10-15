import 'dart:async';

import 'package:platform_foundation/platform_foundation.dart';

import 'failure.dart';

abstract interface class HandledInteractionStore {
  Future<Result<List<String>>> read();
  Future<Result<void>> write(List<String> ids);
}

final class InteractionDeduplicator {
  InteractionDeduplicator({required this.store, this.maximumRetainedIds = 128})
    : assert(maximumRetainedIds > 0);

  final HandledInteractionStore store;
  final int maximumRetainedIds;
  Future<void> _tail = Future.value();

  Future<Result<bool>> claim(String interactionId) {
    final completer = Completer<Result<bool>>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await _claim(interactionId));
      } on Object catch (error, stackTrace) {
        completer.complete(
          Failure(
            NotificationFailure(
              kind: NotificationFailureKind.persistence,
              code: 'notifications.deduplication_failed',
              message: 'Unable to persist notification interaction state.',
              cause: error,
              stackTrace: stackTrace,
            ),
          ),
        );
      }
    });
    return completer.future;
  }

  Future<Result<bool>> _claim(String interactionId) async {
    if (interactionId.isEmpty) {
      return const Failure(
        NotificationFailure(
          kind: NotificationFailureKind.invalidPayload,
          code: 'notifications.empty_interaction_id',
          message: 'Interaction ID cannot be empty.',
        ),
      );
    }
    final stored = await store.read();
    switch (stored) {
      case Failure<List<String>>(:final failure):
        return Failure(failure);
      case Success<List<String>>(:final value):
        if (value.contains(interactionId)) {
          return const Success(false);
        }
        final next = [...value, interactionId];
        final overflow = next.length - maximumRetainedIds;
        final bounded = overflow > 0 ? next.sublist(overflow) : next;
        final written = await store.write(List.unmodifiable(bounded));
        return switch (written) {
          Success<void>() => const Success(true),
          Failure<void>(:final failure) => Failure(failure),
        };
    }
  }
}
