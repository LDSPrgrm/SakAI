import 'package:flutter/material.dart';

import 'sakai_empty_state.dart';

/// Error-styled variant of [SakaiEmptyState] with a retry CTA.
/// Wraps [SakaiEmptyState] to reuse layout / spacing logic — no fork.
class SakaiErrorState extends StatelessWidget {
  const SakaiErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.retryLabel = 'Retry',
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return SakaiEmptyState(
      icon: icon,
      title: title,
      message: message,
      primaryLabel: onRetry != null ? retryLabel : null,
      onPrimary: onRetry,
    );
  }
}
