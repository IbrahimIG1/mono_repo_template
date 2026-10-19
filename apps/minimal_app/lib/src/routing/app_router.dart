import 'dart:async';

import 'package:auth_core/auth_core.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'destination_policy.dart';

typedef DestinationAuthorizer =
    bool Function(Uri destination, AuthSession session);

final class AppRouter {
  AppRouter({
    required SessionManager sessionManager,
    String? initialLocation,
    DestinationAuthorizer? destinationAuthorizer,
  }) : _sessionManager = sessionManager,
       _destinationAuthorizer =
           destinationAuthorizer ??
           ((destination, _) =>
               AppDestinationPolicy.requiresAuthentication(destination)),
       _refresh = _AuthRouterRefresh(sessionManager.states) {
    router = GoRouter(
      routes: $appRoutes,
      initialLocation: initialLocation,
      refreshListenable: _refresh,
      redirect: _redirect,
    );
  }

  final SessionManager _sessionManager;
  final DestinationAuthorizer _destinationAuthorizer;
  final _AuthRouterRefresh _refresh;
  late final GoRouter router;
  String? _pendingDestination;
  var _pendingSignIn = false;

  void dispose() {
    router.dispose();
    _refresh.dispose();
  }

  void openNotificationDestination(String source) {
    final destination = AppDestinationPolicy.safeInternalDestination(source);
    if (destination == null) {
      return;
    }
    final state = _sessionManager.current;
    final session = switch (state) {
      AuthAuthenticated(:final session) => session,
      AuthRefreshing(:final previousSession) => previousSession,
      _ => null,
    };
    if (session != null &&
        !_destinationAuthorizer(Uri.parse(destination), session)) {
      return;
    }
    router.go(destination);
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
          AppDestinationPolicy.singleQueryValue(uri, 'from'),
        );
      } else {
        _pendingDestination ??= safeCurrent;
      }
      return isSplash ? null : const SplashRoute().location;
    }

    if (authState case AuthAuthenticated() || AuthRefreshing()) {
      final session = switch (authState) {
        AuthAuthenticated(:final session) => session,
        AuthRefreshing(:final previousSession) => previousSession,
        _ => throw StateError('Authenticated state expected.'),
      };
      if (isSignIn) {
        final destination = AppDestinationPolicy.safeInternalDestination(
          AppDestinationPolicy.singleQueryValue(uri, 'from'),
        );
        return _consumeDestination(destination, session) ??
            const HomeRoute().location;
      }
      if (isSplash) {
        return _consumeDestination(null, session) ?? const HomeRoute().location;
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

  String? _consumeDestination(String? routeDestination, AuthSession session) {
    final candidate = routeDestination ?? _pendingDestination;
    _pendingSignIn = false;
    _pendingDestination = null;
    final destination = AppDestinationPolicy.safeInternalDestination(candidate);
    if (destination == null) {
      return null;
    }
    final uri = Uri.parse(destination);
    return _destinationAuthorizer(uri, session) ? destination : null;
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
