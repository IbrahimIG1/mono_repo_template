import 'package:go_router/go_router.dart';

import 'showcase_routes.dart';

final class ShowcaseRouter {
  ShowcaseRouter({String? initialLocation}) {
    router = GoRouter(
      routes: $appRoutes,
      initialLocation: initialLocation,
    );
  }

  late final GoRouter router;

  void dispose() => router.dispose();
}
