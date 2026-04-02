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

  @override
  SakaiSemanticColors copyWith({
    Color? success,
    Color? danger,
    Color? accentBlue,
    Color? darkBackground,
    Color? darkSurface,
    Color? darkBorder,
  }) {
    return SakaiSemanticColors(
      success: success ?? this.success,
      danger: danger ?? this.danger,
      accentBlue: accentBlue ?? this.accentBlue,
      darkBackground: darkBackground ?? this.darkBackground,
      darkSurface: darkSurface ?? this.darkSurface,
      darkBorder: darkBorder ?? this.darkBorder,
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
    );
  }
}

