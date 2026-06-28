import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';
import '../theme/sakai_semantic_colors.dart';

/// Severity bucket for [SakaiErrorAlert]. Maps to danger/warning semantic
/// tokens so the inline alert reads as either a hard failure or a soft
/// caution.
enum SakaiAlertSeverity { error, warning }

/// Inline alert with optional retry + dismiss actions. Wrapped in [Semantics]
/// as a live region so assistive tech announces the message.
class SakaiErrorAlert extends StatelessWidget {
  const SakaiErrorAlert({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.severity = SakaiAlertSeverity.error,
  });

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final SakaiAlertSeverity severity;

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final semantic = SakaiSemanticColors.of(context);
    final isError = severity == SakaiAlertSeverity.error;
    final fg = isError ? semantic.danger : semantic.warning;
    final bg = isError ? semantic.dangerSubtle : semantic.warningSubtle;
    final icon = isError ? Icons.error_outline : Icons.warning_amber_rounded;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: EdgeInsets.all(tokens.spaceMd),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(
            color: fg.withValues(alpha: 0.4),
            width: tokens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: fg, size: tokens.iconMd),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: fg),
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(width: tokens.spaceSm),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
            if (onDismiss != null) ...[
              SizedBox(width: tokens.spaceXs),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(Icons.close, color: fg),
                iconSize: tokens.iconSm,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
