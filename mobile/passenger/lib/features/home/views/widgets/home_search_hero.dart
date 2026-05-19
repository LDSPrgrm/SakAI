import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

class HomeSearchHero extends StatelessWidget {
  const HomeSearchHero({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
      child: Semantics(
        button: true,
        label: 'Search destination',
        child: SakaiTactile(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spaceMd,
              vertical: tokens.spaceMd,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: scheme.outlineVariant),
              boxShadow: tokens.elevationSm,
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: tokens.iconMd, color: scheme.primary),
                SizedBox(width: tokens.spaceMd),
                Expanded(
                  child: Text(
                    'Where to?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: tokens.iconMd,
                  color: scheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
