import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'app_composition.dart';
import 'app_scope.dart';

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
    unawaited(widget.composition.controller.load());
    unawaited(widget.composition.sessionManager.restore());
  }

  @override
  void dispose() {
    unawaited(widget.composition.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    composition: widget.composition,
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: widget.composition.config.title,
      theme: PlatformTheme.light(
        seedColor: widget.composition.config.themeSeed,
      ),
      darkTheme: PlatformTheme.dark(
        seedColor: widget.composition.config.themeSeed,
      ),
      routerConfig: widget.composition.appRouter.router,
    ),
  );
}
