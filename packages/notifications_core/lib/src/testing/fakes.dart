import 'dart:async';

import 'package:platform_foundation/platform_foundation.dart';

import '../client.dart';
import '../interaction_deduplicator.dart';
import '../models.dart';

final class MemoryHandledInteractionStore implements HandledInteractionStore {
  MemoryHandledInteractionStore({Iterable<String> initialIds = const []})
    : ids = List.of(initialIds);

  List<String> ids;
  AppFailure? readFailure;
  AppFailure? writeFailure;

  @override
  Future<Result<List<String>>> read() async {
    final failure = readFailure;
    return failure == null ? Success(List.unmodifiable(ids)) : Failure(failure);
  }

  @override
  Future<Result<void>> write(List<String> value) async {
    final failure = writeFailure;
    if (failure != null) {
      return Failure(failure);
    }
    ids = List.of(value);
    return const Success(null);
  }
}

final class FakePushNotificationClient implements PushNotificationClient {
  final StreamController<PushToken> _tokens = StreamController.broadcast();
  final StreamController<PushMessage> _messages = StreamController.broadcast();
  final StreamController<NotificationInteraction> _interactions =
      StreamController.broadcast();

  NotificationCapability capability = NotificationCapability.supported;
  NotificationPermission permission = NotificationPermission.authorized;
  PushToken? token;
  bool isDisposed = false;

  @override
  Stream<PushToken> get tokenChanges => _tokens.stream;

  @override
  Stream<PushMessage> get foregroundMessages => _messages.stream;

  @override
  Stream<NotificationInteraction> get interactions => _interactions.stream;

  @override
  Future<Result<NotificationCapability>> initialize() async =>
      Success(capability);

  @override
  Future<Result<NotificationPermission>> requestPermission() async =>
      Success(permission);

  @override
  Future<Result<PushToken?>> getToken() async => Success(token);

  void addToken(PushToken value) {
    if (!isDisposed) {
      _tokens.add(value);
    }
  }

  void addMessage(PushMessage value) {
    if (!isDisposed) {
      _messages.add(value);
    }
  }

  void addInteraction(NotificationInteraction value) {
    if (!isDisposed) {
      _interactions.add(value);
    }
  }

  @override
  Future<void> dispose() async {
    if (isDisposed) {
      return;
    }
    isDisposed = true;
    await Future.wait([
      _tokens.close(),
      _messages.close(),
      _interactions.close(),
    ]);
  }
}
