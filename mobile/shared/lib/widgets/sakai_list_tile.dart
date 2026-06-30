import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/sakai_design_tokens.dart';

/// Themed row used in settings, account, and history lists. Provides a
/// consistent minimum touch target, haptic feedback on tap, and a subtle
/// background tint when [selected].
///
/// Prefer this over Material's [ListTile] when the surrounding screen is
/// composed from SakAI primitives so spacing and motion read uniformly.
class SakaiListTile extends StatelessWidget {
  const SakaiListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.dense = false,
    this.selected = false,
    this.enabled = true,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final bgColor = selected
        ? scheme.primaryContainer.withValues(alpha: tokens.opacityHover * 4)
        : Colors.transparent;

    final isInteractive = enabled && onTap != null;
    final titleStyle = theme.textTheme.bodyLarge ?? const TextStyle();
    final subtitleStyle = (theme.textTheme.bodySmall ?? const TextStyle())
        .copyWith(color: scheme.onSurfaceVariant);

    final body = Container(
      color: bgColor,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spaceMd,
        vertical: dense ? tokens.spaceSm : tokens.spaceMd,
      ),
      constraints: BoxConstraints(minHeight: tokens.touchTargetMin),
      child: Row(
        children: [
          if (leading != null) ...[
            Opacity(
              opacity: enabled ? 1.0 : tokens.opacityDisabled,
              child: leading,
            ),
            SizedBox(width: tokens.spaceMd),
          ],
          Expanded(
            child: Opacity(
              opacity: enabled ? 1.0 : tokens.opacityDisabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DefaultTextStyle(style: titleStyle, child: title),
                  if (subtitle != null) ...[
                    SizedBox(height: tokens.spaceXs / 2),
                    DefaultTextStyle(style: subtitleStyle, child: subtitle!),
                  ],
                ],
              ),
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: tokens.spaceMd),
            Opacity(
              opacity: enabled ? 1.0 : tokens.opacityDisabled,
              child: trailing,
            ),
          ],
        ],
      ),
    );

    if (!isInteractive) return body;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap!();
      },
      child: body,
    );
  }
}
