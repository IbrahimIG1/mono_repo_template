import 'dart:async';

import 'package:auth_core/auth_core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../routing/app_routes.dart';

final class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.controller,
    required this.signOut,
    super.key,
  });

  final AppController controller;
  final SignOut signOut;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Flutter Platform Minimal')),
    body: AnimatedBuilder(
      animation: controller,
      builder: (context, _) => ListView(
        padding: EdgeInsets.all(context.spacing.standard),
        children: [
          Text(
            'V2 authentication',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: context.spacing.compact),
          Text(_summary(controller.state)),
          SizedBox(height: context.spacing.comfortable),
          const StatusCard(
            title: 'Typed authentication',
            description:
                'Gateways are bound to typed use cases at composition.',
            icon: Icons.lock_outline,
          ),
          const StatusCard(
            title: 'Protected deep links',
            description:
                'Internal destinations survive sign-in and are validated.',
            icon: Icons.link_outlined,
          ),
          SizedBox(height: context.spacing.standard),
          FilledButton(
            onPressed: () => const ProtectedRoute(
              itemId: 'account',
              tab: 'overview',
            ).go(context),
            child: const Text('Open protected destination'),
          ),
          TextButton(
            onPressed: () => unawaited(signOut()),
            child: const Text('Sign out locally'),
          ),
        ],
      ),
    ),
  );

  String _summary(AppLoadState state) => switch (state) {
    AppLoading() => 'Loading local state...',
    AppReady(:final launchCount) => 'Successful launches: $launchCount',
    AppLoadFailed(:final failure) => 'Unable to load: ${failure.code}',
  };
}
