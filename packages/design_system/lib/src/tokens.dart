import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
final class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    this.compact = 8,
    this.standard = 16,
    this.comfortable = 24,
  });

  final double compact;
  final double standard;
  final double comfortable;

  @override
  AppSpacing copyWith({
    double? compact,
    double? standard,
    double? comfortable,
  }) => AppSpacing(
    compact: compact ?? this.compact,
    standard: standard ?? this.standard,
    comfortable: comfortable ?? this.comfortable,
  );

  @override
  AppSpacing lerp(covariant AppSpacing? other, double t) {
    if (other == null) {
      return this;
    }
    return AppSpacing(
      compact: lerpDouble(compact, other.compact, t)!,
      standard: lerpDouble(standard, other.standard, t)!,
      comfortable: lerpDouble(comfortable, other.comfortable, t)!,
    );
  }
}

extension AppSpacingContext on BuildContext {
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;
}
