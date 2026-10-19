// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'showcase_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$showcaseHomeRoute, $showcaseAboutRoute];

RouteBase get $showcaseHomeRoute => GoRouteData.$route(
  path: '/',
  hasOverriddenOnExit: false,
  factory: $ShowcaseHomeRoute._fromState,
);

mixin $ShowcaseHomeRoute on GoRouteData {
  static ShowcaseHomeRoute _fromState(GoRouterState state) =>
      const ShowcaseHomeRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $showcaseAboutRoute => GoRouteData.$route(
  path: '/about',
  hasOverriddenOnExit: false,
  factory: $ShowcaseAboutRoute._fromState,
);

mixin $ShowcaseAboutRoute on GoRouteData {
  static ShowcaseAboutRoute _fromState(GoRouterState state) =>
      const ShowcaseAboutRoute();

  @override
  String get location => GoRouteData.$location('/about');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
