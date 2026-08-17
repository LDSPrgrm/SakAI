import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sakai_design_tokens.dart';
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
    // The brand green renders exactly as specified in both brightnesses — no
    // black toning. `#00B14F` on the shared dark surfaces measures 5.16:1
    // (#1E293B) and 6.29:1 (#0F172A), both above WCAG AA 4.5:1, so dark mode
    // needs no lightened variant.
    final scheme = base.copyWith(
      primary: config.primarySeed,
      onPrimary: Colors.white,
      secondary: config.secondarySeed ?? base.secondary,
    );

    final tokens = config.tokens;

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

    // Shared neutral-slate dark palette, applied to *both* apps. The config
    // fields stay as per-app escape hatches, but neither preset sets them —
    // so there is no algorithmic green-tinted dark path any more.
    final darkBackground =
        config.darkBackgroundColor ?? SakaiDesignTokens.darkBackground;
    final darkSurface = config.darkSurfaceColor ?? SakaiDesignTokens.darkSurface;
    final darkBorder = config.darkBorderColor ?? SakaiDesignTokens.darkBorder;

    final schemeWithOverrides = brightness == Brightness.dark
        ? scheme.copyWith(
            error: danger,
            surface: darkBackground,
            surfaceContainerLowest: darkBackground,
            surfaceContainerLow: darkSurface,
            surfaceContainer: darkSurface,
            surfaceContainerHigh: darkSurface,
            surfaceContainerHighest: darkSurface,
            scrim: darkBackground,
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

    // Brightness-correct app surfaces: light mode gets the Material
    // algorithmic light surfaces, dark mode the shared slate palette.
    final appBackground = brightness == Brightness.dark
        ? darkBackground
        : schemeWithOverrides.surface;
    final appSurface = brightness == Brightness.dark
        ? darkSurface
        : schemeWithOverrides.surfaceContainerLow;
    final appBorder = brightness == Brightness.dark
        ? darkBorder
        : schemeWithOverrides.outlineVariant;

    // Blend the subtle tints onto the real surface for this brightness (the
    // light branch used to hardcode `Colors.white`).
    Color tint(Color color) => Color.alphaBlend(
          color.withValues(
            alpha: brightness == Brightness.dark ? 0.24 : 0.12,
          ),
          appSurface,
        );

    final semantic = SakaiSemanticColors(
      success: success,
      danger: danger,
      accentBlue: accentBlue,
      warning: warning,
      appBackground: appBackground,
      appSurface: appSurface,
      appBorder: appBorder,
      neutral: neutral,
      neutralVariant: neutralVariant,
      disabledSurface: disabledSurface,
      disabledOnSurface: disabledOnSurface,
      dangerSubtle: tint(danger),
      warningSubtle: tint(warning),
      successSubtle: tint(success),
      primarySubtle: tint(schemeWithOverrides.primary),
      warningDark: brightness == Brightness.dark ? warningDark : null,
    );

    final scaffoldBackgroundColor = appBackground;

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
        // Suppress the M3 scroll-under tint shift by tinting with the actual
        // surface colour (light + dark).
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
