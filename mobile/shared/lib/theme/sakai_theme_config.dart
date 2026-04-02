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
  });

  /// Passenger app default: cool, trust-forward palette.
  factory SakaiThemeConfig.passenger() => SakaiThemeConfig(
        primarySeed: const Color(0xFF0D9488),
        secondarySeed: const Color(0xFF0369A1),
        tokens: SakaiDesignTokens.defaults,
      );

  /// Driver app default: distinct accent while sharing the same token scale.
  factory SakaiThemeConfig.driver() => SakaiThemeConfig(
        primarySeed: const Color(0xFFC2410C),
        secondarySeed: const Color(0xFFB45309),
        tokens: SakaiDesignTokens.defaults,
      );

  final Color primarySeed;
  final Color? secondarySeed;
  final SakaiDesignTokens tokens;
  final bool useMaterial3;

  SakaiThemeConfig copyWith({
    Color? primarySeed,
    Color? secondarySeed,
    SakaiDesignTokens? tokens,
    bool? useMaterial3,
  }) {
    return SakaiThemeConfig(
      primarySeed: primarySeed ?? this.primarySeed,
      secondarySeed: secondarySeed ?? this.secondarySeed,
      tokens: tokens ?? this.tokens,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
    );
  }
}
