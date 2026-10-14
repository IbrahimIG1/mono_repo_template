import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scratch_package/scratch_package.dart';

part 'routes.g.dart';

final spikeRouter = GoRouter(routes: $appRoutes);

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SpikeHomeScreen();
}

@TypedGoRoute<ProbeRoute>(path: '/probe/:probeId')
class ProbeRoute extends GoRouteData with $ProbeRoute {
  const ProbeRoute({required this.probeId, this.source = 'direct'});

  final String probeId;
  final String source;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ProbeScreen(probeId: probeId, source: source);
}

class SpikeHomeScreen extends StatelessWidget {
  const SpikeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goal 2 spike')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(describeWorkspaceResolution('/')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => const ProbeRoute(
                probeId: 'typed-route',
                source: 'home',
              ).go(context),
              child: const Text('Open typed route'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProbeScreen extends StatelessWidget {
  const ProbeScreen({required this.probeId, required this.source, super.key});

  final String probeId;
  final String source;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Typed route')),
      body: Center(child: Text('$probeId:$source')),
    );
  }
}
