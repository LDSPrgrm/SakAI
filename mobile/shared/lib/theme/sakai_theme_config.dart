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

  /// Passenger app default: Grab-style palette — one brand green
  /// ([SakaiDesignTokens.primary] `#00B14F`) on neutral-slate dark surfaces
  /// and neutral light surfaces.
  factory SakaiThemeConfig.passenger() => const SakaiThemeConfig(
    primarySeed: SakaiDesignTokens.primary,
    secondarySeed: SakaiDesignTokens.primaryDeep,
    successColor: SakaiDesignTokens.primary,
    dangerColor: SakaiDesignTokens.errorRed,
    warningColor: Color(0xFFFBBC04),
    tokens: SakaiDesignTokens.defaults,
  );

  /// Driver app default: identical Grab-style palette to
  /// [SakaiThemeConfig.passenger] — the slate dark surfaces that used to be
  /// pinned here now live in the shared build path
  /// ([SakaiDesignTokens.darkBackground] and friends) and apply to both apps.
  factory SakaiThemeConfig.driver() => const SakaiThemeConfig(
    primarySeed: SakaiDesignTokens.primary,
    secondarySeed: SakaiDesignTokens.primaryDeep,
    successColor: SakaiDesignTokens.primary,
    dangerColor: SakaiDesignTokens.errorRed,
    warningColor: Color(0xFFFBBC04),
    tokens: SakaiDesignTokens.defaults,
  );

  final Color primarySeed;
  final Color? secondarySeed;
  final SakaiDesignTokens tokens;
  final bool useMaterial3;
  final Color? successColor;
  final Color? dangerColor;
  final Color? warningColor;
  /// Optional per-app overrides of the shared dark palette. Left null by both
  /// presets so light and dark surfaces stay identical across the two apps;
  /// defaults come from [SakaiDesignTokens.darkBackground] /
  /// [SakaiDesignTokens.darkSurface] / [SakaiDesignTokens.darkBorder].
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
