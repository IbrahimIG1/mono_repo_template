import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class PlatformTheme {
  static ThemeData light({required Color seedColor}) =>
      _theme(ColorScheme.fromSeed(seedColor: seedColor));

  static ThemeData dark({required Color seedColor}) => _theme(
    ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
  );

  static ThemeData _theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    extensions: const [AppSpacing()],
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
