import 'package:flutter/material.dart';

import 'sakai_theme_config.dart';

/// Builds [ThemeData] for SakAI apps from [SakaiThemeConfig].
abstract final class SakaiTheme {
  static ThemeData light(SakaiThemeConfig config) =>
      _build(config, Brightness.light);

  static ThemeData dark(SakaiThemeConfig config) =>
      _build(config, Brightness.dark);

  static ThemeData _build(SakaiThemeConfig config, Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: config.primarySeed,
      brightness: brightness,
    );
    final scheme = config.secondarySeed != null
        ? base.copyWith(secondary: config.secondarySeed)
        : base;

    final tokens = config.tokens;
    final radii = BorderRadius.circular(tokens.radiusMd);

    return ThemeData(
      useMaterial3: config.useMaterial3,
      colorScheme: scheme,
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[tokens],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
        color: scheme.surfaceContainerLow,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spaceLg,
            vertical: tokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spaceLg,
            vertical: tokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(borderRadius: radii),
        enabledBorder: OutlineInputBorder(
          borderRadius: radii,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radii,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radii,
          borderSide: BorderSide(color: scheme.error),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spaceMd,
          vertical: tokens.spaceMd,
        ),
      ),
    );
  }
}
