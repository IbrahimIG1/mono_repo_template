import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_scope.dart';
import '../ui/home_screen.dart';
import '../ui/protected_screen.dart';
import '../ui/sign_in_screen.dart';
import '../ui/splash_screen.dart';

part 'app_routes.g.dart';

@TypedGoRoute<SplashRoute>(path: '/splash')
final class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SplashScreen();
}

@TypedGoRoute<HomeRoute>(path: '/')
final class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => HomeScreen(
    controller: AppScope.of(context).controller,
    signOut: AppScope.of(context).signOut,
  );
}

@TypedGoRoute<ProtectedRoute>(path: '/protected/:itemId')
final class ProtectedRoute extends GoRouteData with $ProtectedRoute {
  const ProtectedRoute({required this.itemId, this.tab});

  final String itemId;
  final String? tab;

  @override
  Widget build(BuildContext context, GoRouterState state) => ProtectedScreen(
    itemId: itemId,
    tab: tab,
    signOut: AppScope.of(context).signOut,
  );
}

@TypedGoRoute<SignInRoute>(path: '/sign-in')
final class SignInRoute extends GoRouteData with $SignInRoute {
  const SignInRoute({this.from});

  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) => SignInScreen(
    signIn: AppScope.of(context).signIn,
    intendedDestination: from,
  );
}
