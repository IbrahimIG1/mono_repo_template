import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'app_composition.dart';
import 'app_controller.dart';

final class MinimalApp extends StatefulWidget {
  const MinimalApp({required this.composition, super.key});

  final AppComposition composition;

  @override
  State<MinimalApp> createState() => _MinimalAppState();
}

final class _MinimalAppState extends State<MinimalApp> {
  @override
  void initState() {
    super.initState();
    widget.composition.controller.addListener(_onStateChanged);
    unawaited(widget.composition.controller.load());
  }

  @override
  void dispose() {
    widget.composition.controller.removeListener(_onStateChanged);
    widget.composition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: widget.composition.config.title,
    theme: PlatformTheme.light(seedColor: widget.composition.config.themeSeed),
    darkTheme: PlatformTheme.dark(
      seedColor: widget.composition.config.themeSeed,
    ),
    home: _HomeScreen(
      title: widget.composition.config.title,
      apiBaseUri: widget.composition.config.apiBaseUri,
      state: widget.composition.controller.state,
    ),
  );

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}

final class _HomeScreen extends StatelessWidget {
  const _HomeScreen({
    required this.title,
    required this.apiBaseUri,
    required this.state,
  });

  final String title;
  final Uri apiBaseUri;
  final AppLoadState state;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: EdgeInsets.all(context.spacing.standard),
      children: [
        Text(
          'V2 foundation',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: context.spacing.compact),
        Text(_summary),
        SizedBox(height: context.spacing.comfortable),
        const StatusCard(
          title: 'Foundation',
          description:
              'Typed results, extensible failures, and redacted logging.',
          icon: Icons.account_tree_outlined,
        ),
        const StatusCard(
          title: 'Storage',
          description: 'Injected preferences with typed failures.',
          icon: Icons.storage_outlined,
        ),
        StatusCard(
          title: 'Networking',
          description:
              'Injected HTTP client configured for ${apiBaseUri.host}.',
          icon: Icons.cloud_outlined,
        ),
        const StatusCard(
          title: 'Design system',
          description: 'Brand-neutral Material 3 tokens and components.',
          icon: Icons.palette_outlined,
        ),
      ],
    ),
  );

  String get _summary => switch (state) {
    AppLoading() => 'Loading local state...',
    AppReady(:final launchCount) => 'Successful launches: $launchCount',
    AppLoadFailed(:final failure) => 'Unable to load: ${failure.code}',
  };
}
