import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';

/// Internal variant tag used to defer token lookups (which require a
/// [BuildContext]) until [SakaiAppBar.build]. Factory constructors set this
/// instead of passing magic numeric sentinels through [elevation].
enum _Variant { normal, transparent, elevated }

/// App bar aligned with shared elevation/spacing tokens.
///
/// Wraps Material's [AppBar] with sensible defaults:
/// * Uses [SakaiDesignTokens.elevationAppBar] when [elevation] is null.
/// * Adds a `BackButton` when [showBack] is true, a custom [leading] is not
///   supplied, and there is something to pop. Otherwise renders no leading
///   so callers can opt out cleanly.
/// * Sets [AppBar.surfaceTintColor] to the current scheme surface to avoid
///   Material 3 tint drift across light/dark themes.
///
/// The [SakaiAppBar.transparent] / [SakaiAppBar.elevated] factories preset
/// elevation + background for the two most common variants.
class SakaiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SakaiAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.showBack = true,
    this.onBack,
    this.bottom,
    this.elevation,
    this.backgroundColor,
  }) : _variant = _Variant.normal;

  const SakaiAppBar._({
    super.key,
    required _Variant variant,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.showBack = true,
    this.onBack,
    this.bottom,
  })  : _variant = variant,
        elevation = null,
        backgroundColor = null;

  /// Elevation-0, transparent background variant — typically for screens
  /// where the body owns the chrome (e.g. full-bleed maps or hero images).
  factory SakaiAppBar.transparent({
    Key? key,
    Widget? title,
    Widget? leading,
    List<Widget>? actions,
    bool centerTitle = false,
    bool showBack = true,
    VoidCallback? onBack,
    PreferredSizeWidget? bottom,
  }) {
    return SakaiAppBar._(
      key: key,
      variant: _Variant.transparent,
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      showBack: showBack,
      onBack: onBack,
      bottom: bottom,
    );
  }

  /// Elevated variant matching modal-level depth. Background falls back to
  /// the current `ColorScheme.surface` so it reads correctly in both modes.
  factory SakaiAppBar.elevated({
    Key? key,
    Widget? title,
    Widget? leading,
    List<Widget>? actions,
    bool centerTitle = false,
    bool showBack = true,
    VoidCallback? onBack,
    PreferredSizeWidget? bottom,
  }) {
    return SakaiAppBar._(
      key: key,
      variant: _Variant.elevated,
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      showBack: showBack,
      onBack: onBack,
      bottom: bottom,
    );
  }

  final _Variant _variant;
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBack;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final Color? backgroundColor;

  @override
  Size get preferredSize {
    final base = kToolbarHeight;
    final extra = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(base + extra);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    final resolvedElevation = switch (_variant) {
      _Variant.transparent => 0.0,
      _Variant.elevated => tokens.elevationModal,
      _Variant.normal => elevation ?? tokens.elevationAppBar,
    };
    final resolvedBg = switch (_variant) {
      _Variant.transparent => Colors.transparent,
      _Variant.elevated => backgroundColor,
      _Variant.normal => backgroundColor,
    };

    Widget? resolvedLeading;
    if (leading != null) {
      resolvedLeading = leading;
    } else if (showBack && Navigator.canPop(context)) {
      resolvedLeading = BackButton(
        onPressed: onBack ?? () => Navigator.maybePop(context),
      );
    }

    return AppBar(
      title: title,
      leading: resolvedLeading,
      automaticallyImplyLeading: false,
      actions: actions,
      centerTitle: centerTitle,
      elevation: resolvedElevation,
      surfaceTintColor: theme.colorScheme.surface,
      backgroundColor: resolvedBg,
      titleSpacing: tokens.spaceMd,
      bottom: bottom,
    );
  }
}
