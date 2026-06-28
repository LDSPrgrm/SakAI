import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../view_models/sos_notifier.dart';

/// Emergency SOS confirmation screen. Reached from the active-ride screen.
/// Starts a 5-second countdown that the user can cancel before it triggers.
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key, required this.rideId});
  final String rideId;

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sosNotifierProvider.notifier).startCountdown(widget.rideId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sosNotifierProvider);
    final notifier = ref.read(sosNotifierProvider.notifier);
    final theme = Theme.of(context);
    final t = SakaiDesignTokens.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.error,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(t.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 96, color: Colors.white),
              SizedBox(height: t.spaceLg),
              Text(
                _headline(state),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: t.spaceMd),
              Text(
                _subhead(state),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              SizedBox(height: t.spaceXl),
              if (state.isCountingDown)
                FilledButton.tonal(
                  onPressed: () {
                    notifier.cancelCountdown();
                    if (context.canPop()) context.pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Cancel'),
                  ),
                )
              else if (state.triggering)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else if (state.incident != null)
                Column(
                  children: [
                    Text(
                      'Emergency contacts and the platform team have been alerted.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: t.spaceMd),
                    FilledButton.tonal(
                      onPressed: () => context.pop(),
                      child: const Text('Back to ride'),
                    ),
                  ],
                )
              else if (state.errorMessage != null)
                Column(
                  children: [
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: t.spaceMd),
                    FilledButton.tonal(
                      onPressed: () =>
                          notifier.startCountdown(widget.rideId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _headline(SosState s) {
    if (s.isCountingDown) return 'Triggering in ${s.countdownSeconds}…';
    if (s.triggering) return 'Calling for help…';
    if (s.incident != null) return 'Help is on the way';
    if (s.errorMessage != null) return 'Couldn\'t trigger SOS';
    return 'SOS';
  }

  String _subhead(SosState s) {
    if (s.isCountingDown) return 'Tap cancel if this is a mistake.';
    return '';
  }
}
