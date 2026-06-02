import 'package:flutter/material.dart';

import 'sakai_design_tokens.dart';

/// Central place to tune SakAI visual language (colors, spacing, radii).
/// Swap presets (`passenger` / `driver`) or construct a custom instance when
/// Stitch or brand guidelines change — apps only pass one config into
/// [SakaiTheme.light] / [SakaiTheme.dark].
@immutable
class SakaiThemeConfig {
  const SakaiThemeConfig({
    required this.primarySeed,
    this.secondarySeed,
    this.tokens = SakaiDesignTokens.defaults,
    this.useMaterial3 = true,
    this.successColor,
    this.dangerColor,
    this.warningColor,
    this.darkBackgroundColor,
    this.darkSurfaceColor,
    this.darkBorderColor,
  });

  /// Passenger app default: bold, energetic GoRide Green palette.
  factory SakaiThemeConfig.passenger() => SakaiThemeConfig(
    primarySeed: const Color(0xFF00DC82),
    secondarySeed: const Color(0xFF00B86C),
    tokens: SakaiDesignTokens.defaults,
  );

  /// Driver app default: same GoRide Green brand identity, with deep slate/charcoal dark theme.
  factory SakaiThemeConfig.driver() => SakaiThemeConfig(
    primarySeed: const Color(0xFF00DC82),
    secondarySeed: const Color(0xFF00B86C),
    successColor: const Color(0xFF00DC82),
    dangerColor: const Color(0xFFEA4335),
    warningColor: const Color(0xFFFBBC04),
    darkBackgroundColor: const Color(0xFF0F172A),
    darkSurfaceColor: const Color(0xFF1E293B),
    darkBorderColor: const Color(0xFF334155),
    tokens: SakaiDesignTokens.defaults,
  );

  final Color primarySeed;
  final Color? secondarySeed;
  final SakaiDesignTokens tokens;
  final bool useMaterial3;
  final Color? successColor;
  final Color? dangerColor;
  final Color? warningColor;
  final Color? darkBackgroundColor;
  final Color? darkSurfaceColor;
  final Color? darkBorderColor;

  SakaiThemeConfig copyWith({
    Color? primarySeed,
    Color? secondarySeed,
    SakaiDesignTokens? tokens,
    bool? useMaterial3,
    Color? successColor,
    Color? dangerColor,
    Color? warningColor,
    Color? darkBackgroundColor,
    Color? darkSurfaceColor,
    Color? darkBorderColor,
  }) {
    return SakaiThemeConfig(
      primarySeed: primarySeed ?? this.primarySeed,
      secondarySeed: secondarySeed ?? this.secondarySeed,
      tokens: tokens ?? this.tokens,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      successColor: successColor ?? this.successColor,
      dangerColor: dangerColor ?? this.dangerColor,
      warningColor: warningColor ?? this.warningColor,
      darkBackgroundColor: darkBackgroundColor ?? this.darkBackgroundColor,
      darkSurfaceColor: darkSurfaceColor ?? this.darkSurfaceColor,
      darkBorderColor: darkBorderColor ?? this.darkBorderColor,
    );
  }
}
