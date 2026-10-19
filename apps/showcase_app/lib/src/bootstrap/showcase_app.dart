import 'package:flutter/material.dart';
import 'package:platform_foundation/platform_foundation.dart';

import 'showcase_config.dart';
import 'showcase_theme.dart';
import '../localization/showcase_localizations.dart';

final class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({required this.config, required this.logger, super.key});

  final ShowcaseConfig config;
  final AppLogger logger;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) =>
        ShowcaseLocalizations.of(context).appTitle(config.environment.name),
    localizationsDelegates: const [ShowcaseLocalizations.delegate],
    supportedLocales: ShowcaseLocalizations.supportedLocales,
    theme: ShowcaseTheme.light(),
    home: _BootstrapScreen(config: config),
  );
}

final class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen({required this.config});

  final ShowcaseConfig config;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(config.appTitle)),
    body: Center(
      child: Text(
        ShowcaseLocalizations.of(
          context,
        ).bootstrapReady(config.environment.name),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
