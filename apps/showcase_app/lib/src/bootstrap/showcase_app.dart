import 'package:flutter/material.dart';
import 'package:platform_foundation/platform_foundation.dart';

import '../localization/showcase_localizations.dart';
import '../routing/showcase_router.dart';
import 'showcase_config.dart';
import 'showcase_theme.dart';

final class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({required this.config, required this.logger, super.key});

  final ShowcaseConfig config;
  final AppLogger logger;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

final class _ShowcaseAppState extends State<ShowcaseApp> {
  late final ShowcaseRouter _showcaseRouter;

  @override
  void initState() {
    super.initState();
    _showcaseRouter = ShowcaseRouter();
  }

  @override
  void dispose() {
    _showcaseRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => ShowcaseLocalizations.of(
      context,
    ).appTitle(widget.config.environment.name),
    localizationsDelegates: const [ShowcaseLocalizations.delegate],
    supportedLocales: ShowcaseLocalizations.supportedLocales,
    theme: ShowcaseTheme.light(),
    routerConfig: _showcaseRouter.router,
  );
}
