import 'dart:async';
import 'dart:io';

import 'package:notifications_core/notifications_core.dart';
import 'package:platform_foundation/platform_foundation.dart';

import 'fcm_port.dart';
import 'firebase_messaging_port.dart';

final class FcmPushNotificationClient implements PushNotificationClient {
  factory FcmPushNotificationClient({
    required FcmPort port,
    bool? isMobilePlatform,
  }) => FcmPushNotificationClient._(
    port,
    isMobilePlatform ?? (Platform.isAndroid || Platform.isIOS),
  );

  FcmPushNotificationClient._(this._port, this._isMobilePlatform) {
    _interactions = StreamController.broadcast(
      onListen: _flushPendingInteractions,
    );
  }

  factory FcmPushNotificationClient.create() =>
      FcmPushNotificationClient(port: FirebaseMessagingPort.create());

  final FcmPort _port;
  final bool _isMobilePlatform;
  final StreamController<PushToken> _tokens = StreamController.broadcast();
  final StreamController<PushMessage> _messages = StreamController.broadcast();
  late final StreamController<NotificationInteraction> _interactions;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final List<NotificationInteraction> _pendingInteractions = [];
  Future<Result<NotificationCapability>>? _initializeOperation;
  var _initialized = false;
  var _disposed = false;

  @override
  Stream<PushToken> get tokenChanges => _tokens.stream;

  @override
  Stream<PushMessage> get foregroundMessages => _messages.stream;

  @override
  Stream<NotificationInteraction> get interactions => _interactions.stream;

  @override
  Future<Result<NotificationCapability>> initialize() {
    if (_disposed) {
      return Future.value(
        _failure(
          NotificationFailureKind.disposed,
          'notifications.client_disposed',
          'Notification client is disposed.',
        ),
      );
    }
    if (!_isMobilePlatform) {
      return Future.value(const Success(NotificationCapability.unsupported));
    }
    if (_initialized) {
      return Future.value(const Success(NotificationCapability.supported));
    }
    final existing = _initializeOperation;
    if (existing != null) {
      return existing;
    }
    final operation = _performInitialize();
    _initializeOperation = operation;
    return operation.whenComplete(() {
      if (identical(_initializeOperation, operation)) {
        _initializeOperation = null;
      }
    });
  }

  Future<Result<NotificationCapability>> _performInitialize() async {
    final added = <StreamSubscription<Object?>>[
      _port.tokenChanges.listen(_onToken),
      _port.foregroundMessages.listen(_onForegroundMessage),
      _port.openedMessages.listen(_onInteraction),
    ];
    _subscriptions.addAll(added);
    try {
      final initial = await _port.getInitialMessage();
      if (initial != null) {
        _onInteraction(initial);
      }
      if (_disposed) {
        await _cancelSubscriptions(added);
        return _failure(
          NotificationFailureKind.disposed,
          'notifications.client_disposed',
          'Notification client is disposed.',
        );
      }
      _initialized = true;
      return const Success(NotificationCapability.supported);
    } on Object catch (error, stackTrace) {
      await _cancelSubscriptions(added);
      return _unavailable('initialize', error, stackTrace);
    }
  }

  Future<void> _cancelSubscriptions(
    Iterable<StreamSubscription<Object?>> subscriptions,
  ) async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
      _subscriptions.remove(subscription);
    }
  }

  @override
  Future<Result<NotificationPermission>> requestPermission() async {
    if (!_isMobilePlatform) {
      return _failure(
        NotificationFailureKind.unsupported,
        'notifications.unsupported_platform',
        'FCM notifications are supported only on Android and iOS in V2.',
      );
    }
    try {
      final permission = await _port.requestPermission();
      return Success(switch (permission) {
        FcmAuthorizationStatus.authorized => NotificationPermission.authorized,
        FcmAuthorizationStatus.denied => NotificationPermission.denied,
        FcmAuthorizationStatus.deniedPermanently =>
          NotificationPermission.deniedPermanently,
        FcmAuthorizationStatus.notDetermined =>
          NotificationPermission.notDetermined,
        FcmAuthorizationStatus.provisional =>
          NotificationPermission.provisional,
      });
    } on Object catch (error, stackTrace) {
      return _unavailable('request_permission', error, stackTrace);
    }
  }

  @override
  Future<Result<PushToken?>> getToken() async {
    if (!_isMobilePlatform) {
      return _failure(
        NotificationFailureKind.unsupported,
        'notifications.unsupported_platform',
        'FCM notifications are supported only on Android and iOS in V2.',
      );
    }
    try {
      final token = await _port.getToken();
      return Success(token == null || token.isEmpty ? null : PushToken(token));
    } on Object catch (error, stackTrace) {
      return _unavailable('get_token', error, stackTrace);
    }
  }

  void _onToken(String token) {
    if (!_disposed && token.isNotEmpty) {
      _tokens.add(PushToken(token));
    }
  }

  void _onForegroundMessage(FcmMessage message) {
    if (!_disposed) {
      _messages.add(
        PushMessage(
          id: _messageId(message),
          data: Map.unmodifiable(message.data),
          receivedAt: DateTime.now().toUtc(),
          title: message.title,
          body: message.body,
        ),
      );
    }
  }

  void _onInteraction(FcmMessage message) {
    if (!_disposed) {
      final id = message.data['interaction_id'] ?? _messageId(message);
      final interaction = NotificationInteraction(
        id: id,
        data: Map.unmodifiable(message.data),
        occurredAt: DateTime.now().toUtc(),
      );
      if (_interactions.hasListener) {
        _flushPendingInteractions();
        _interactions.add(interaction);
      } else {
        if (_pendingInteractions.length == 16) {
          _pendingInteractions.removeAt(0);
        }
        _pendingInteractions.add(interaction);
      }
    }
  }

  void _flushPendingInteractions() {
    if (!_interactions.hasListener || _pendingInteractions.isEmpty) {
      return;
    }
    final pending = List.of(_pendingInteractions);
    _pendingInteractions.clear();
    for (final interaction in pending) {
      _interactions.add(interaction);
    }
  }

  String _messageId(FcmMessage message) =>
      message.id ?? message.data['interaction_id'] ?? 'unidentified-message';

  Failure<T> _failure<T>(
    NotificationFailureKind kind,
    String code,
    String message,
  ) => Failure(NotificationFailure(kind: kind, code: code, message: message));

  Failure<T> _unavailable<T>(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) => Failure(
    NotificationFailure(
      kind: NotificationFailureKind.unavailable,
      code: 'notifications.fcm_$operation',
      message: 'Firebase messaging operation failed.',
      cause: error,
      stackTrace: stackTrace,
    ),
  );

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _pendingInteractions.clear();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await Future.wait([
      _tokens.close(),
      _messages.close(),
      _interactions.close(),
    ]);
  }
}
