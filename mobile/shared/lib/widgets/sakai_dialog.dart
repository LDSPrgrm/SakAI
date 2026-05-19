import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';
import '../theme/sakai_semantic_colors.dart';

/// Static helper for showing themed confirmation dialogs that match the
/// SakAI design tokens (radius, elevation, semantic danger color).
///
/// Use [confirm] in place of bespoke [AlertDialog] call sites so the chrome
/// stays consistent and destructive flows always reach for the semantic
/// danger token instead of a raw material color.
class SakaiDialog {
  SakaiDialog._();

  /// Opens a confirmation dialog with [title] / [message] and returns the
  /// user's choice. Tapping outside or popping with `null` resolves to
  /// `false` (i.e. cancelled).
  ///
  /// Set [destructive] to `true` for irreversible actions (logout, delete,
  /// cancel ride). The confirm button is then tinted with the semantic
  /// danger token.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final tokens = SakaiDesignTokens.of(context);
    final semantic = SakaiSemanticColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
        elevation: tokens.elevationDialog,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: semantic.danger,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
