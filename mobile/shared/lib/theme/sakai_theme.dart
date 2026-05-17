import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sakai_semantic_colors.dart';
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

    final success = config.successColor ?? scheme.secondary;
    final danger = config.dangerColor ?? scheme.error;
    final warning = config.warningColor ?? const Color(0xFFFBBC04);
    final accentBlue = config.secondarySeed ?? scheme.secondary;

    // Only apply these overrides for the dark variant; for light we keep the
    // Material algorithmic surfaces generated from the seed.
    final darkBackground = config.darkBackgroundColor ?? scheme.surface;
    final darkSurface = config.darkSurfaceColor ?? scheme.surface;
    final darkBorder = config.darkBorderColor ?? scheme.outlineVariant;

    final schemeWithOverrides = brightness == Brightness.dark
        ? scheme.copyWith(
            error: danger,
            surface: darkSurface,
            surfaceContainerLow: darkSurface,
            surfaceContainerHighest: darkSurface,
            outlineVariant: darkBorder,
          )
        : scheme.copyWith(error: danger);

    final neutral = brightness == Brightness.dark
        ? const Color(0xFF8B949E)
        : const Color(0xFF6B7280);
    final neutralVariant = brightness == Brightness.dark
        ? const Color(0xFF6B7280)
        : const Color(0xFF9CA3AF);
    final disabledSurface = brightness == Brightness.dark
        ? const Color(0xFF21262D)
        : const Color(0xFFF3F4F6);
    final disabledOnSurface = brightness == Brightness.dark
        ? const Color(0xFF6B7280)
        : const Color(0xFF9CA3AF);

    Color tint(Color base) => brightness == Brightness.dark
        ? Color.alphaBlend(base.withValues(alpha: 0.24), darkSurface)
        : Color.alphaBlend(base.withValues(alpha: 0.12), Colors.white);

    final semantic = SakaiSemanticColors(
      success: success,
      danger: danger,
      accentBlue: accentBlue,
      warning: warning,
      darkBackground: darkBackground,
      darkSurface: darkSurface,
      darkBorder: darkBorder,
      neutral: neutral,
      neutralVariant: neutralVariant,
      disabledSurface: disabledSurface,
      disabledOnSurface: disabledOnSurface,
      dangerSubtle: tint(danger),
      warningSubtle: tint(warning),
      successSubtle: tint(success),
    );

    final scaffoldBackgroundColor = brightness == Brightness.dark
        ? darkBackground
        : schemeWithOverrides.surface;

    return ThemeData(
      useMaterial3: config.useMaterial3,
      colorScheme: schemeWithOverrides,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[tokens, semantic],
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: schemeWithOverrides.surface,
        foregroundColor: schemeWithOverrides.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
        color: schemeWithOverrides.surfaceContainerLow,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spaceLg,
            vertical: tokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusLg), // Or radiusXl if we want pills, but radiusLg (20px) is good. Mockups use 1.5rem (24px) for most buttons.
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
            borderRadius: BorderRadius.circular(tokens.radiusLg),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: schemeWithOverrides.surfaceContainerHighest.withValues(
          alpha: brightness == Brightness.dark ? 0.2 : 0.4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radii,
          borderSide: BorderSide(color: schemeWithOverrides.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radii,
          borderSide: BorderSide(color: schemeWithOverrides.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radii,
          borderSide: BorderSide(color: schemeWithOverrides.error),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spaceMd,
          vertical: tokens.spaceMd,
        ),
      ),
    );
  }
}
