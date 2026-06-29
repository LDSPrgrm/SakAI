import 'package:flutter/material.dart';

import 'sos_ui_state.dart';

/// Compact emergency banner rendered above the active-ride content while
/// an SOS is in flight. Driven by [SosUiState].
///
/// Renders nothing while the state is idle, which makes it safe to insert
/// unconditionally at the top of any active-ride layout.
class SosBanner extends StatelessWidget {
  final SosUiState state;
  const SosBanner({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.active) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final assignee = state.assigneeDisplay;
    final waitingLabel = assignee == null
        ? 'Connecting you to safety operator…'
        : 'Operator $assignee is on the line';

    return Material(
      color: scheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: scheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency support active',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: scheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      waitingLabel,
                      style: TextStyle(
                        color: scheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
