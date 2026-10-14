import 'package:flutter/material.dart';

import 'routes.dart';

void main() {
  runApp(const SpikeApp());
}

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Goal 2 spike',
      routerConfig: spikeRouter,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
    );
  }
}
