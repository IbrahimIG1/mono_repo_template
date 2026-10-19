import 'dart:async';

import 'package:auth_core/auth_core.dart';
import 'package:notifications_core/notifications_core.dart';
import 'package:platform_foundation/platform_foundation.dart';

import '../routing/app_router.dart';
import '../routing/destination_policy.dart';
import 'notification_destination_mapper.dart';

abstract interface class NotificationNavigator {
  void go(String destination);
}

final class AppRouterNotificationNavigator implements NotificationNavigator {
  const AppRouterNotificationNavigator(this.appRouter);

  final AppRouter appRouter;

  @override
  void go(String destination) =>
      appRouter.openNotificationDestination(destination);
}

final class PendingInteractionCoordinator {
  PendingInteractionCoordinator({
    required this.client,
    required this.decoder,
    required this.mapper,
    required this.deduplicator,
    required this.sessionManager,
    required this.navigator,
    required this.routerReady,
  });

  final PushNotificationClient client;
  final NotificationPayloadDecoder decoder;
  final NotificationDestinationMapper mapper;
  final InteractionDeduplicator deduplicator;
  final SessionManager sessionManager;
  final NotificationNavigator navigator;
  final Future<void> routerReady;

  StreamSubscription<NotificationInteraction>? _subscription;
  Future<void> _tail = Future.value();
  var _disposed = false;

  void start() {
    if (_subscription != null) {
      return;
    }
    _subscription = client.interactions.listen((interaction) {
      _tail = _tail.then((_) => _handle(interaction));
    });
  }

  Future<void> _handle(NotificationInteraction interaction) async {
    if (_disposed) {
      return;
    }
    final decoded = decoder.decode(interaction.data);
    if (decoded case Failure<NotificationPayload>()) {
      return;
    }
    final payload = (decoded as Success<NotificationPayload>).value;
    if (payload.interactionId != interaction.id) {
      return;
    }
    final mapped = mapper.map(payload);
    if (mapped case Failure<String>()) {
      return;
    }
    final destination = (mapped as Success<String>).value;
    if (AppDestinationPolicy.safeInternalDestination(destination) == null) {
      return;
    }

    await routerReady;
    await _waitForSessionReadiness();
    if (_disposed ||
        AppDestinationPolicy.safeInternalDestination(destination) == null) {
      return;
    }

    final claimed = await deduplicator.claim(interaction.id);
    if (_disposed || claimed is! Success<bool> || !claimed.value) {
      return;
    }
    navigator.go(destination);
  }

  Future<void> _waitForSessionReadiness() async {
    if (_isSessionReady(sessionManager.current)) {
      return;
    }
    await sessionManager.states.firstWhere(_isSessionReady);
  }

  bool _isSessionReady(AuthState state) =>
      state is! AuthUninitialized && state is! AuthRestoring;

  Future<void> dispose() {
    if (_disposed) {
      return Future.value();
    }
    _disposed = true;
    unawaited(_subscription?.cancel());
    return Future.value();
  }
}
