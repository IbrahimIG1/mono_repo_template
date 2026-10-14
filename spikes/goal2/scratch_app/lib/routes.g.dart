// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$homeRoute, $probeRoute];

RouteBase get $homeRoute => GoRouteData.$route(
  path: '/',
  hasOverriddenOnExit: false,
  factory: $HomeRoute._fromState,
);

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

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

RouteBase get $probeRoute => GoRouteData.$route(
  path: '/probe/:probeId',
  hasOverriddenOnExit: false,
  factory: $ProbeRoute._fromState,
);

mixin $ProbeRoute on GoRouteData {
  static ProbeRoute _fromState(GoRouterState state) => ProbeRoute(
    probeId: state.pathParameters['probeId']!,
    source: state.uri.queryParameters['source'] ?? 'direct',
  );

  ProbeRoute get _self => this as ProbeRoute;

  @override
  String get location => GoRouteData.$location(
    '/probe/${Uri.encodeComponent(_self.probeId)}',
    queryParams: {if (_self.source != 'direct') 'source': _self.source},
  );

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
