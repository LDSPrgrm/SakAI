import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';
import 'sakai_primary_button.dart';
import 'sakai_secondary_button.dart';

/// Full-bleed empty / error / no-results state. Centers an icon, headline,
/// optional subtitle, and up to two CTAs.
class SakaiEmptyState extends StatelessWidget {
  const SakaiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: t.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(t.spaceLg),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: scheme.primary,
                ),
              ),
            ),
            SizedBox(height: t.spaceLg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            if (message != null) ...[
              SizedBox(height: t.spaceSm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (primaryLabel != null) ...[
              SizedBox(height: t.spaceLg),
              SakaiPrimaryButton(
                label: primaryLabel!,
                onPressed: onPrimary,
              ),
            ],
            if (secondaryLabel != null) ...[
              SizedBox(height: t.spaceSm),
              SakaiSecondaryButton(
                label: secondaryLabel!,
                onPressed: onSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
