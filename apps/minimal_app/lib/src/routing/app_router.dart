import 'dart:async';

import 'package:auth_core/auth_core.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'destination_policy.dart';

final class AppRouter {
  AppRouter({required SessionManager sessionManager, String? initialLocation})
    : _sessionManager = sessionManager,
      _refresh = _AuthRouterRefresh(sessionManager.states) {
    router = GoRouter(
      routes: $appRoutes,
      initialLocation: initialLocation,
      refreshListenable: _refresh,
      redirect: _redirect,
    );
  }

  final SessionManager _sessionManager;
  final _AuthRouterRefresh _refresh;
  late final GoRouter router;
  String? _pendingDestination;
  var _pendingSignIn = false;

  void dispose() {
    router.dispose();
    _refresh.dispose();
  }

  String? _redirect(BuildContext _, GoRouterState state) {
    final authState = _sessionManager.current;
    final uri = state.uri;
    final isSplash = uri.path == '/splash';
    final isSignIn = uri.path == '/sign-in';
    final safeCurrent = AppDestinationPolicy.safeInternalDestination(
      uri.toString(),
    );

    if (authState is AuthUninitialized || authState is AuthRestoring) {
      if (isSignIn) {
        _pendingSignIn = true;
        _pendingDestination ??= AppDestinationPolicy.safeInternalDestination(
          uri.queryParameters['from'],
        );
      } else {
        _pendingDestination ??= safeCurrent;
      }
      return isSplash ? null : const SplashRoute().location;
    }

    if (authState case AuthAuthenticated() || AuthRefreshing()) {
      if (isSignIn) {
        final destination = AppDestinationPolicy.safeInternalDestination(
          uri.queryParameters['from'],
        );
        return _consumeDestination(destination) ?? const HomeRoute().location;
      }
      if (isSplash) {
        return _consumeDestination(null) ?? const HomeRoute().location;
      }
      return null;
    }

    if (isSplash) {
      final pending = _pendingDestination;
      if (_pendingSignIn || pending != null) {
        _pendingSignIn = false;
        return SignInRoute(from: pending).location;
      }
      return const HomeRoute().location;
    }
    if (AppDestinationPolicy.requiresAuthentication(uri)) {
      _pendingDestination = safeCurrent;
      return SignInRoute(from: safeCurrent).location;
    }
    if (!isSignIn) {
      _pendingSignIn = false;
      _pendingDestination = null;
    }
    return null;
  }

  String? _consumeDestination(String? routeDestination) {
    final destination = routeDestination ?? _pendingDestination;
    _pendingSignIn = false;
    _pendingDestination = null;
    return destination;
  }
}

final class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Stream<AuthState> states) {
    _subscription = states.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
