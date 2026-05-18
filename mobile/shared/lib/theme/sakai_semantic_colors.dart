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
    required this.darkBackground,
    required this.darkSurface,
    required this.darkBorder,
    required this.warning,
    required this.neutral,
    required this.neutralVariant,
    required this.disabledSurface,
    required this.disabledOnSurface,
    required this.dangerSubtle,
    required this.warningSubtle,
    required this.successSubtle,
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
  final Color darkBackground;
  final Color darkSurface;
  final Color darkBorder;
  final Color warning;
  final Color neutral;
  final Color neutralVariant;
  final Color disabledSurface;
  final Color disabledOnSurface;
  final Color dangerSubtle;
  final Color warningSubtle;
  final Color successSubtle;

  @override
  SakaiSemanticColors copyWith({
    Color? success,
    Color? danger,
    Color? accentBlue,
    Color? darkBackground,
    Color? darkSurface,
    Color? darkBorder,
    Color? warning,
    Color? neutral,
    Color? neutralVariant,
    Color? disabledSurface,
    Color? disabledOnSurface,
    Color? dangerSubtle,
    Color? warningSubtle,
    Color? successSubtle,
  }) {
    return SakaiSemanticColors(
      success: success ?? this.success,
      danger: danger ?? this.danger,
      accentBlue: accentBlue ?? this.accentBlue,
      darkBackground: darkBackground ?? this.darkBackground,
      darkSurface: darkSurface ?? this.darkSurface,
      darkBorder: darkBorder ?? this.darkBorder,
      warning: warning ?? this.warning,
      neutral: neutral ?? this.neutral,
      neutralVariant: neutralVariant ?? this.neutralVariant,
      disabledSurface: disabledSurface ?? this.disabledSurface,
      disabledOnSurface: disabledOnSurface ?? this.disabledOnSurface,
      dangerSubtle: dangerSubtle ?? this.dangerSubtle,
      warningSubtle: warningSubtle ?? this.warningSubtle,
      successSubtle: successSubtle ?? this.successSubtle,
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
      darkBackground:
          Color.lerp(darkBackground, other.darkBackground, t) ?? darkBackground,
      darkSurface: Color.lerp(darkSurface, other.darkSurface, t) ?? darkSurface,
      darkBorder: Color.lerp(darkBorder, other.darkBorder, t) ?? darkBorder,
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
    );
  }
}

