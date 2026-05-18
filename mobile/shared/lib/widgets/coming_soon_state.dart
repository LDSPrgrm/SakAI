import 'package:flutter/material.dart';

import 'sakai_empty_state.dart';

/// "Coming soon — backend pending" empty state. Thin preset over
/// [SakaiEmptyState] so views catching [BackendUnavailableException] can
/// surface a consistent placeholder.
class ComingSoonState extends StatelessWidget {
  const ComingSoonState({
    super.key,
    required this.feature,
    this.title = 'Coming soon',
    this.message,
    this.onBack,
  });

  /// Human-readable feature name, e.g. `'Wallet'`.
  final String feature;
  final String title;
  final String? message;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SakaiEmptyState(
      icon: Icons.construction_rounded,
      title: title,
      message: message ?? '$feature is awaiting backend support. Check back soon.',
      primaryLabel: onBack != null ? 'Back' : null,
      onPrimary: onBack,
    );
  }
}
