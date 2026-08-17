import 'dart:ui';

import 'package:flutter/material.dart';

/// Layout tokens exposed via [ThemeExtension] so widgets stay decoupled from
/// raw numbers. Adjust in [SakaiThemeConfig] or here as the design system evolves.
@immutable
class SakaiDesignTokens extends ThemeExtension<SakaiDesignTokens> {
  const SakaiDesignTokens({
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusFull,
    required this.elevationSm,
    required this.elevationMd,
    required this.elevationLg,
    // Material elevation values (dp) — AppBar / modals / dialogs.
    this.elevationAppBar = 0,
    this.elevationModal = 3,
    this.elevationDialog = 6,
    // Motion durations
    this.durationMicro = const Duration(milliseconds: 80),
    this.durationFast = const Duration(milliseconds: 150),
    this.durationStandard = const Duration(milliseconds: 250),
    this.durationSlow = const Duration(milliseconds: 400),
    // Motion curves
    this.curveStandard = Curves.easeOutCubic,
    this.curveEmphasized = Curves.easeOutQuint,
    this.curveDecelerate = Curves.easeOut,
    // Borders
    this.borderHairline = 0.5,
    this.borderThin = 1,
    this.borderMedium = 2,
    // Interaction-state opacities (Material 3 aligned).
    this.opacityDisabled = 0.38,
    this.opacityHover = 0.08,
    this.opacityFocus = 0.12,
    this.opacityPressed = 0.16,
    this.opacitySubtle = 0.6,
    // Icon sizes
    this.iconSm = 16,
    this.iconMd = 24,
    this.iconLg = 32,
    // Accessibility — minimum touch target.
    this.touchTargetMin = 48,
    // Compact spacing step between [spaceSm] (8) and [spaceMd] (16).
    this.spacing12 = 12,
  });

  /// Grab-style brand green ramp. Every green in the design system derives
  /// from [primary]; there are no independent green literals.
  ///
  /// * [primary] `#00B14F` is the literal rendered `colorScheme.primary` in
  ///   both brightnesses. WCAG contrast against the shared dark surfaces is
  ///   5.16:1 on [darkSurface] (`#1E293B`) and 6.29:1 on [darkBackground]
  ///   (`#0F172A`) — both clear AA (4.5:1) for normal text, so no lightened
  ///   dark-mode variant is needed.
  /// * [primaryBright] / [primaryDeep] are +9% / -7% HSL lightness stops off
  ///   [primary] (same hue 146.8deg, same saturation). They exist only for
  ///   brand gradients.
  static const Color primary = Color(0xFF00B14F);
  static const Color primaryBright = Color(0xFF00DF63);
  static const Color primaryDeep = Color(0xFF008D3F);

  /// Shared neutral-slate dark palette applied to *both* apps (previously a
  /// driver-only override, with passenger falling back to algorithmic
  /// green-tinted M3 surfaces).
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  /// Single error red for both apps, surfaced as `colorScheme.error`.
  static const Color errorRed = Color(0xFFEA4335);

  /// Fixed categorical accent palette for service/category tiles (e.g. the
  /// passenger home services grid). These are brand-level category accents,
  /// not theme roles — they stay constant across light/dark brightness so
  /// each service category keeps a recognizable identity color.
  static const Color serviceFood = Color(0xFFFF6B35);
  static const Color serviceMart = Color(0xFF0284C7);
  static const Color serviceExpress = Color(0xFFEAB308);
  static const Color serviceShopping = Color(0xFF9333EA);
  static const Color serviceOffers = Color(0xFFEC4899);
  static const Color serviceGiftCards = Color(0xFFEF4444);
  static const Color serviceMore = Color(0xFF6B7280);

  /// Wallet/loyalty card gradient accents (home dashboard "My Wallet"
  /// section). Brand-level card identities, not theme roles — held fixed
  /// across brightness like [serviceFood] etc. The pay-card gradient is the
  /// brand ramp; the points card keeps its own violet identity.
  static const Color walletPayGradientStart = primaryBright;
  static const Color walletPayGradientEnd = primaryDeep;
  static const Color walletPointsGradientStart = Color(0xFF7C3AED);
  static const Color walletPointsGradientEnd = Color(0xFF5B21B6);

  /// Booking "Confirm" CTA gradient — brand accent, held fixed across
  /// brightness like the other gradient tokens above.
  static const Color confirmCtaGradientStart = primaryBright;
  static const Color confirmCtaGradientEnd = primaryDeep;

  static const SakaiDesignTokens defaults = SakaiDesignTokens(
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 16,
    spaceLg: 24,
    spaceXl: 32,
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 20,
    radiusFull: 999,
    elevationSm: [
      BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
    elevationMd: [
      BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
    elevationLg: [
      BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 8)),
    ],
  );

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusFull;
  final List<BoxShadow> elevationSm;
  final List<BoxShadow> elevationMd;
  final List<BoxShadow> elevationLg;
  final Duration durationFast;
  final Duration durationStandard;
  final Duration durationSlow;
  final double borderHairline;
  final double borderThin;
  final double borderMedium;
  // Material elevation (dp)
  final double elevationAppBar;
  final double elevationModal;
  final double elevationDialog;
  // Motion
  final Duration durationMicro;
  final Curve curveStandard;
  final Curve curveEmphasized;
  final Curve curveDecelerate;
  // Interaction-state opacities
  final double opacityDisabled;
  final double opacityHover;
  final double opacityFocus;
  final double opacityPressed;
  final double opacitySubtle;
  // Icon sizes
  final double iconSm;
  final double iconMd;
  final double iconLg;
  // Accessibility floor
  final double touchTargetMin;

  /// Compact spacing step (12dp) between [spaceSm] and [spaceMd]. Named after
  /// its value rather than the `space*` t-shirt scale because the screen sweep
  /// greps for it by number.
  final double spacing12;

  static SakaiDesignTokens of(BuildContext context) {
    final ext = Theme.of(context).extension<SakaiDesignTokens>();
    assert(
      ext != null,
      'SakaiDesignTokens missing — use SakaiTheme.light/dark',
    );
    return ext!;
  }

  @override
  SakaiDesignTokens copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusFull,
    List<BoxShadow>? elevationSm,
    List<BoxShadow>? elevationMd,
    List<BoxShadow>? elevationLg,
    double? elevationAppBar,
    double? elevationModal,
    double? elevationDialog,
    Duration? durationMicro,
    Duration? durationFast,
    Duration? durationStandard,
    Duration? durationSlow,
    Curve? curveStandard,
    Curve? curveEmphasized,
    Curve? curveDecelerate,
    double? borderHairline,
    double? borderThin,
    double? borderMedium,
    double? opacityDisabled,
    double? opacityHover,
    double? opacityFocus,
    double? opacityPressed,
    double? opacitySubtle,
    double? iconSm,
    double? iconMd,
    double? iconLg,
    double? touchTargetMin,
    double? spacing12,
  }) {
    return SakaiDesignTokens(
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusFull: radiusFull ?? this.radiusFull,
      elevationSm: elevationSm ?? this.elevationSm,
      elevationMd: elevationMd ?? this.elevationMd,
      elevationLg: elevationLg ?? this.elevationLg,
      elevationAppBar: elevationAppBar ?? this.elevationAppBar,
      elevationModal: elevationModal ?? this.elevationModal,
      elevationDialog: elevationDialog ?? this.elevationDialog,
      durationMicro: durationMicro ?? this.durationMicro,
      durationFast: durationFast ?? this.durationFast,
      durationStandard: durationStandard ?? this.durationStandard,
      durationSlow: durationSlow ?? this.durationSlow,
      curveStandard: curveStandard ?? this.curveStandard,
      curveEmphasized: curveEmphasized ?? this.curveEmphasized,
      curveDecelerate: curveDecelerate ?? this.curveDecelerate,
      borderHairline: borderHairline ?? this.borderHairline,
      borderThin: borderThin ?? this.borderThin,
      borderMedium: borderMedium ?? this.borderMedium,
      opacityDisabled: opacityDisabled ?? this.opacityDisabled,
      opacityHover: opacityHover ?? this.opacityHover,
      opacityFocus: opacityFocus ?? this.opacityFocus,
      opacityPressed: opacityPressed ?? this.opacityPressed,
      opacitySubtle: opacitySubtle ?? this.opacitySubtle,
      iconSm: iconSm ?? this.iconSm,
      iconMd: iconMd ?? this.iconMd,
      iconLg: iconLg ?? this.iconLg,
      touchTargetMin: touchTargetMin ?? this.touchTargetMin,
      spacing12: spacing12 ?? this.spacing12,
    );
  }

  @override
  ThemeExtension<SakaiDesignTokens> lerp(
    covariant ThemeExtension<SakaiDesignTokens>? other,
    double t,
  ) {
    if (other is! SakaiDesignTokens) return this;
    return SakaiDesignTokens(
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t)!,
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t)!,
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t)!,
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t)!,
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusFull: lerpDouble(radiusFull, other.radiusFull, t)!,
      elevationSm:
          BoxShadow.lerpList(elevationSm, other.elevationSm, t) ?? elevationSm,
      elevationMd:
          BoxShadow.lerpList(elevationMd, other.elevationMd, t) ?? elevationMd,
      elevationLg:
          BoxShadow.lerpList(elevationLg, other.elevationLg, t) ?? elevationLg,
      elevationAppBar:
          lerpDouble(elevationAppBar, other.elevationAppBar, t)!,
      elevationModal: lerpDouble(elevationModal, other.elevationModal, t)!,
      elevationDialog: lerpDouble(elevationDialog, other.elevationDialog, t)!,
      durationMicro: t < 0.5 ? durationMicro : other.durationMicro,
      durationFast: t < 0.5 ? durationFast : other.durationFast,
      durationStandard: t < 0.5 ? durationStandard : other.durationStandard,
      durationSlow: t < 0.5 ? durationSlow : other.durationSlow,
      curveStandard: t < 0.5 ? curveStandard : other.curveStandard,
      curveEmphasized: t < 0.5 ? curveEmphasized : other.curveEmphasized,
      curveDecelerate: t < 0.5 ? curveDecelerate : other.curveDecelerate,
      borderHairline: lerpDouble(borderHairline, other.borderHairline, t)!,
      borderThin: lerpDouble(borderThin, other.borderThin, t)!,
      borderMedium: lerpDouble(borderMedium, other.borderMedium, t)!,
      opacityDisabled: lerpDouble(opacityDisabled, other.opacityDisabled, t)!,
      opacityHover: lerpDouble(opacityHover, other.opacityHover, t)!,
      opacityFocus: lerpDouble(opacityFocus, other.opacityFocus, t)!,
      opacityPressed: lerpDouble(opacityPressed, other.opacityPressed, t)!,
      opacitySubtle: lerpDouble(opacitySubtle, other.opacitySubtle, t)!,
      iconSm: lerpDouble(iconSm, other.iconSm, t)!,
      iconMd: lerpDouble(iconMd, other.iconMd, t)!,
      iconLg: lerpDouble(iconLg, other.iconLg, t)!,
      touchTargetMin: lerpDouble(touchTargetMin, other.touchTargetMin, t)!,
      spacing12: lerpDouble(spacing12, other.spacing12, t)!,
    );
  }
}
