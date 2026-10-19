import 'dart:async';

import 'package:auth_core/auth_core.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'showcase_routes.dart';

final class ShowcaseRouter {
  ShowcaseRouter({
    required SessionManager sessionManager,
    String? initialLocation,
  }) : _sessionManager = sessionManager,
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

  void dispose() {
    router.dispose();
    _refresh.dispose();
  }

  String? _redirect(BuildContext _, GoRouterState state) {
    final isSignIn = state.uri.path == '/sign-in';
    final isAccount = state.uri.path == '/account';
    final authenticated = _sessionManager.current is AuthAuthenticated;
    if (isAccount && !authenticated) {
      return const ShowcaseSignInRoute().location;
    }
    if (isSignIn && authenticated) {
      return const ShowcaseAccountRoute().location;
    }
    return null;
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
