import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';

/// Consistent section title with optional trailing action label (e.g. "See all").
class SakaiSectionHeader extends StatelessWidget {
  const SakaiSectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
    this.padding,
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceSm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailingLabel != null)
            TextButton(
              onPressed: onTrailingTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: t.spaceSm,
                  vertical: t.spaceXs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(trailingLabel!),
            ),
        ],
      ),
    );
  }
}
