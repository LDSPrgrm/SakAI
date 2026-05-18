import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';
import '../theme/sakai_semantic_colors.dart';

enum SakaiStatus { neutral, info, success, warning, danger, pending }

/// Compact pill badge for ride status, online/offline state, payment status, etc.
/// Colors map from [SakaiStatus] so callers never pick hex.
class SakaiStatusBadge extends StatelessWidget {
  const SakaiStatusBadge({
    super.key,
    required this.status,
    required this.label,
    this.icon,
    this.dense = false,
  });

  final SakaiStatus status;
  final String label;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final s = SakaiSemanticColors.of(context);
    final theme = Theme.of(context);
    final (fg, bg) = _palette(s, theme.colorScheme);

    final pad = dense
        ? EdgeInsets.symmetric(horizontal: t.spaceSm, vertical: t.spaceXs)
        : EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceSm);

    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: fg),
            SizedBox(width: t.spaceXs),
          ],
          Text(
            label,
            style: (dense
                    ? theme.textTheme.labelSmall
                    : theme.textTheme.labelMedium)
                ?.copyWith(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  (Color fg, Color bg) _palette(SakaiSemanticColors s, ColorScheme c) {
    switch (status) {
      case SakaiStatus.success:
        return (s.success, s.successSubtle);
      case SakaiStatus.warning:
      case SakaiStatus.pending:
        return (s.warning, s.warningSubtle);
      case SakaiStatus.danger:
        return (s.danger, s.dangerSubtle);
      case SakaiStatus.info:
        return (s.accentBlue, c.surfaceContainerHighest);
      case SakaiStatus.neutral:
        return (s.neutral, s.disabledSurface);
    }
  }
}
