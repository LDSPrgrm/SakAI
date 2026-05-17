import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';

/// Prominent fare display — large amount + optional subtitle (e.g. "estimate").
class SakaiFareChip extends StatelessWidget {
  const SakaiFareChip({
    super.key,
    required this.amount,
    this.subtitle,
    this.leading,
  });

  final String amount;
  final String? subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.spaceMd,
        vertical: t.spaceSm,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(t.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: t.spaceSm),
          ],
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Selectable chip for ride type (Standard / XL / Premium / Pool).
class SakaiRideTypeChip extends StatelessWidget {
  const SakaiRideTypeChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.subtitle,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = selected ? scheme.primary : scheme.surfaceContainerHighest;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(t.radiusLg),
      child: AnimatedContainer(
        duration: t.durationFast,
        padding: EdgeInsets.symmetric(
          horizontal: t.spaceMd,
          vertical: t.spaceSm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(t.radiusLg),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: t.borderThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              SizedBox(width: t.spaceSm),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: fg.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
