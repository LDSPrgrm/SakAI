import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';

/// Modal blocking loading overlay backed by an [OverlayEntry] inserted into
/// the root [Overlay]. Use [show] to display and [hide] to remove. Safe to
/// call [show] multiple times — duplicate calls are no-ops while an overlay
/// is already visible.
class SakaiLoadingOverlay {
  SakaiLoadingOverlay._();

  static OverlayEntry? _entry;

  /// Whether an overlay is currently inserted.
  static bool get isVisible => _entry != null;

  /// Insert the overlay. Optional [message] renders below the spinner.
  static void show(BuildContext context, {String? message}) {
    if (_entry != null) return;
    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    _entry = OverlayEntry(
      builder: (_) => Material(
        // Structural barrier color — not a brand color.
        color: scheme.scrim.withValues(alpha: 0.54),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(tokens.spaceLg),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: scheme.primary),
                if (message != null) ...[
                  SizedBox(height: tokens.spaceMd),
                  Text(message, style: textStyle),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  /// Remove the overlay (no-op if not visible).
  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
