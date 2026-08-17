import 'package:flutter/material.dart';

/// Semantic color overrides intended to match Stitch/brand palettes.
///
/// Note: these are *not* part of Material's `ColorScheme` computation. They
/// exist so custom widgets/screens can use explicit success/danger/border
/// values (e.g. Stitch exports with `text-success`, `bg-primary`, etc.).
@immutable
class SakaiSemanticColors extends ThemeExtension<SakaiSemanticColors> {
  const SakaiSemanticColors({
    required this.success,
    required this.danger,
    required this.accentBlue,
    required this.appBackground,
    required this.appSurface,
    required this.appBorder,
    required this.warning,
    required this.neutral,
    required this.neutralVariant,
    required this.disabledSurface,
    required this.disabledOnSurface,
    required this.dangerSubtle,
    required this.warningSubtle,
    required this.successSubtle,
    required this.primarySubtle,
    this.warningDark,
    this.glassTintLight = const Color(0x0A000000),
    this.glassTintDark = const Color(0x0FFFFFFF),
  });

  static SakaiSemanticColors of(BuildContext context) {
    final ext = Theme.of(context).extension<SakaiSemanticColors>();
    assert(
      ext != null,
      'SakaiSemanticColors missing — use SakaiTheme.light/dark',
    );
    return ext!;
  }

  final Color success;
  final Color danger;
  final Color accentBlue;
  /// Page background for the current brightness (the light surface in light
  /// mode, `SakaiDesignTokens.darkBackground` in dark mode). Formerly named
  /// `darkBackground`, which held light values in light mode.
  final Color appBackground;

  /// Card/sheet surface for the current brightness. Formerly `darkSurface`.
  final Color appSurface;

  /// Outline/divider color for the current brightness. Formerly `darkBorder`.
  final Color appBorder;
  final Color warning;
  final Color neutral;
  final Color neutralVariant;
  final Color disabledSurface;
  final Color disabledOnSurface;
  final Color dangerSubtle;
  final Color warningSubtle;
  final Color successSubtle;

  /// Low-emphasis brand-green wash (primary blended onto the current surface),
  /// for selected chips/rows and badge backgrounds.
  final Color primarySubtle;

  /// Brighter dark-mode warning (~+8% lightness vs [warning]) so amber holds
  /// contrast on dark surfaces. Null in light mode — fall back to [warning].
  final Color? warningDark;

  /// Tint overlays used by `SakaiGlassCard` to keep frosted surfaces legible
  /// against arbitrary backgrounds.
  final Color glassTintLight;
  final Color glassTintDark;

  @override
  SakaiSemanticColors copyWith({
    Color? success,
    Color? danger,
    Color? accentBlue,
    Color? appBackground,
    Color? appSurface,
    Color? appBorder,
    Color? warning,
    Color? neutral,
    Color? neutralVariant,
    Color? disabledSurface,
    Color? disabledOnSurface,
    Color? dangerSubtle,
    Color? warningSubtle,
    Color? successSubtle,
    Color? primarySubtle,
    Color? warningDark,
    Color? glassTintLight,
    Color? glassTintDark,
  }) {
    return SakaiSemanticColors(
      success: success ?? this.success,
      danger: danger ?? this.danger,
      accentBlue: accentBlue ?? this.accentBlue,
      appBackground: appBackground ?? this.appBackground,
      appSurface: appSurface ?? this.appSurface,
      appBorder: appBorder ?? this.appBorder,
      warning: warning ?? this.warning,
      neutral: neutral ?? this.neutral,
      neutralVariant: neutralVariant ?? this.neutralVariant,
      disabledSurface: disabledSurface ?? this.disabledSurface,
      disabledOnSurface: disabledOnSurface ?? this.disabledOnSurface,
      dangerSubtle: dangerSubtle ?? this.dangerSubtle,
      warningSubtle: warningSubtle ?? this.warningSubtle,
      successSubtle: successSubtle ?? this.successSubtle,
      primarySubtle: primarySubtle ?? this.primarySubtle,
      warningDark: warningDark ?? this.warningDark,
      glassTintLight: glassTintLight ?? this.glassTintLight,
      glassTintDark: glassTintDark ?? this.glassTintDark,
    );
  }

  @override
  ThemeExtension<SakaiSemanticColors> lerp(
    covariant ThemeExtension<SakaiSemanticColors>? other,
    double t,
  ) {
    if (other is! SakaiSemanticColors) return this;
    return SakaiSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t) ?? accentBlue,
      appBackground:
          Color.lerp(appBackground, other.appBackground, t) ?? appBackground,
      appSurface: Color.lerp(appSurface, other.appSurface, t) ?? appSurface,
      appBorder: Color.lerp(appBorder, other.appBorder, t) ?? appBorder,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      neutral: Color.lerp(neutral, other.neutral, t) ?? neutral,
      neutralVariant:
          Color.lerp(neutralVariant, other.neutralVariant, t) ?? neutralVariant,
      disabledSurface: Color.lerp(disabledSurface, other.disabledSurface, t) ??
          disabledSurface,
      disabledOnSurface:
          Color.lerp(disabledOnSurface, other.disabledOnSurface, t) ??
              disabledOnSurface,
      dangerSubtle:
          Color.lerp(dangerSubtle, other.dangerSubtle, t) ?? dangerSubtle,
      warningSubtle:
          Color.lerp(warningSubtle, other.warningSubtle, t) ?? warningSubtle,
      successSubtle:
          Color.lerp(successSubtle, other.successSubtle, t) ?? successSubtle,
      primarySubtle:
          Color.lerp(primarySubtle, other.primarySubtle, t) ?? primarySubtle,
      warningDark: Color.lerp(warningDark, other.warningDark, t),
      glassTintLight:
          Color.lerp(glassTintLight, other.glassTintLight, t) ?? glassTintLight,
      glassTintDark:
          Color.lerp(glassTintDark, other.glassTintDark, t) ?? glassTintDark,
    );
  }
}

