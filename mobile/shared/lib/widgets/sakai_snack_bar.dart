import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';
import '../theme/sakai_semantic_colors.dart';

/// Severity tier for [SakaiSnackBar]. Internal — callers go through the
/// named static helpers (`success`, `error`, `warning`, `info`).
enum _SakaiSnackSeverity { success, error, warning, info }

/// Static helpers for showing semantically-colored snack bars that match
/// the SakAI design tokens. Always prefer these over directly calling
/// `ScaffoldMessenger.of(context).showSnackBar(...)` so colors, radius, and
/// margins stay consistent across the app.
class SakaiSnackBar {
  SakaiSnackBar._();

  /// Shows a success (green) snack bar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) =>
      _show(context, message, _SakaiSnackSeverity.success, duration, action);

  /// Shows an error (danger / red) snack bar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) =>
      _show(context, message, _SakaiSnackSeverity.error, duration, action);

  /// Shows a warning (amber) snack bar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) =>
      _show(context, message, _SakaiSnackSeverity.warning, duration, action);

  /// Shows an info (accent blue) snack bar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) =>
      _show(context, message, _SakaiSnackSeverity.info, duration, action);

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _show(
    BuildContext context,
    String message,
    _SakaiSnackSeverity severity,
    Duration duration,
    SnackBarAction? action,
  ) {
    final semantic = SakaiSemanticColors.of(context);
    final tokens = SakaiDesignTokens.of(context);

    final background = switch (severity) {
      _SakaiSnackSeverity.success => semantic.success,
      _SakaiSnackSeverity.error => semantic.danger,
      _SakaiSnackSeverity.warning => semantic.warning,
      _SakaiSnackSeverity.info => semantic.accentBlue,
    };

    final snack = SnackBar(
      content: Text(message),
      backgroundColor: background,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      margin: EdgeInsets.all(tokens.spaceMd),
      duration: duration,
      action: action,
    );

    return ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
