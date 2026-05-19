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
    // Tone down the primary brand color slightly (22% in light, 28% in dark) to prevent neon harshness,
    // keeping the exact red brand hue but making it more premium and comfortable to the eyes.
    final tonedPrimary = brightness == Brightness.dark
        ? Color.lerp(config.primarySeed, Colors.black, 0.28) ?? config.primarySeed
        : Color.lerp(config.primarySeed, Colors.black, 0.22) ?? config.primarySeed;

    final scheme = base.copyWith(
      primary: tonedPrimary,
      onPrimary: Colors.white,
      secondary: config.secondarySeed ?? base.secondary,
    );

    final tokens = config.tokens;
    final radii = BorderRadius.circular(tokens.radiusMd);

    final success = config.successColor ?? scheme.secondary;
    final danger = config.dangerColor ?? scheme.error;
    final warning = config.warningColor ?? const Color(0xFFFBBC04);
    // Brighter dark-mode warning (+8% lightness) so amber retains contrast
    // on dark surfaces. Light mode keeps the base warning.
    final warningHsl = HSLColor.fromColor(warning);
    final warningDark = warningHsl
        .withLightness((warningHsl.lightness + 0.08).clamp(0.0, 1.0))
        .toColor();
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
      warningDark: brightness == Brightness.dark ? warningDark : null,
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
        elevation: tokens.elevationAppBar,
        scrolledUnderElevation: 1,
        backgroundColor: schemeWithOverrides.surface,
        foregroundColor: schemeWithOverrides.onSurface,
        // Suppress M3 scroll-under purple shift on the red seed by tinting
        // with the actual surface colour (light + dark).
        surfaceTintColor: schemeWithOverrides.surface,
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
            borderRadius: BorderRadius.circular(tokens.radiusFull),
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
            borderRadius: BorderRadius.circular(tokens.radiusFull),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent, // transparent for a clean outline look
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusFull),
          borderSide: BorderSide(color: schemeWithOverrides.outlineVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusFull),
          borderSide: BorderSide(color: schemeWithOverrides.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusFull),
          borderSide: BorderSide(color: schemeWithOverrides.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusFull),
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
