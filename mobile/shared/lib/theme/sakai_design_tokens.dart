import 'dart:ui';

import 'package:flutter/material.dart';

/// Layout tokens exposed via [ThemeExtension] so widgets stay decoupled from
/// raw numbers. Adjust in [SakaiThemeConfig] or here as the design system evolves.
@immutable
class SakaiDesignTokens extends ThemeExtension<SakaiDesignTokens> {
  const SakaiDesignTokens({
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusFull,
  });

  static const SakaiDesignTokens defaults = SakaiDesignTokens(
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 16,
    spaceLg: 24,
    spaceXl: 32,
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 20,
    radiusFull: 999,
  );

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusFull;

  static SakaiDesignTokens of(BuildContext context) {
    final ext = Theme.of(context).extension<SakaiDesignTokens>();
    assert(ext != null, 'SakaiDesignTokens missing — use SakaiTheme.light/dark');
    return ext!;
  }

  @override
  SakaiDesignTokens copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusFull,
  }) {
    return SakaiDesignTokens(
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusFull: radiusFull ?? this.radiusFull,
    );
  }

  @override
  ThemeExtension<SakaiDesignTokens> lerp(
    covariant ThemeExtension<SakaiDesignTokens>? other,
    double t,
  ) {
    if (other is! SakaiDesignTokens) return this;
    return SakaiDesignTokens(
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t)!,
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t)!,
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t)!,
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t)!,
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusFull: lerpDouble(radiusFull, other.radiusFull, t)!,
    );
  }
}
