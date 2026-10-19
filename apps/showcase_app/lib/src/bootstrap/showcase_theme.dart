import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Product-specific brand composition stays in the app. The shared design
/// system remains brand-neutral and supplies the theme mechanics/primitives.
abstract final class ShowcaseTheme {
  static const brandSeed = Color(0xFFB4953D);

  static ThemeData light() => PlatformTheme.light(seedColor: brandSeed);
}
