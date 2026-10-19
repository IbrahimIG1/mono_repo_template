import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/showcase_auth.dart';
import '../auth/showcase_auth_screens.dart';

part 'showcase_routes.g.dart';

@TypedGoRoute<ShowcaseHomeRoute>(path: '/')
final class ShowcaseHomeRoute extends GoRouteData with $ShowcaseHomeRoute {
  const ShowcaseHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const _ShowcaseHomeScreen();
}

@TypedGoRoute<ShowcaseAboutRoute>(path: '/about')
final class ShowcaseAboutRoute extends GoRouteData with $ShowcaseAboutRoute {
  const ShowcaseAboutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const _ShowcaseAboutScreen();
}

@TypedGoRoute<ShowcaseSignInRoute>(path: '/sign-in')
final class ShowcaseSignInRoute extends GoRouteData with $ShowcaseSignInRoute {
  const ShowcaseSignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ShowcaseSignInScreen(
        onSignedIn: () => const ShowcaseAccountRoute().go(context),
      );
}

@TypedGoRoute<ShowcaseAccountRoute>(path: '/account')
final class ShowcaseAccountRoute extends GoRouteData
    with $ShowcaseAccountRoute {
  const ShowcaseAccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ShowcaseAccountScreen(
        onSignOut: () async {
          await ShowcaseAuthScope.of(context).signOut();
          if (context.mounted) {
            const ShowcaseHomeRoute().go(context);
          }
        },
      );
}

final class _ShowcaseHomeScreen extends StatelessWidget {
  const _ShowcaseHomeScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Showcase')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => const ShowcaseAboutRoute().go(context),
            child: const Text('About'),
          ),
          TextButton(
            onPressed: () => const ShowcaseAccountRoute().go(context),
            child: const Text('Account'),
          ),
        ],
      ),
    ),
  );
}

final class _ShowcaseAboutScreen extends StatelessWidget {
  const _ShowcaseAboutScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About')),
    body: const Center(child: Text('Showcase navigation shell')),
  );
}
