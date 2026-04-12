import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart' hide PaymentMethod;

import '../../../app/routes.dart';
import '../models/tip_option.dart';
import '../models/rating_state.dart';
import '../models/ride_completion_summary.dart' show PaymentMethod;
import '../view_models/ride_complete_notifier.dart'
    show rideCompleteNotifierProvider;

/// Ride completion screen showing trip summary, tip selector, and rating.
class RideCompleteScreen extends ConsumerStatefulWidget {
  const RideCompleteScreen({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<RideCompleteScreen> createState() => _RideCompleteScreenState();
}

class _RideCompleteScreenState extends ConsumerState<RideCompleteScreen> {
  final _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(rideCompleteNotifierProvider.notifier).loadRide(widget.rideId);
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _onDone() {
    context.go(Routes.home);
  }

  Future<void> _submitRating() async {
    final notifier = ref.read(rideCompleteNotifierProvider.notifier);
    final success = await notifier.submitRating(widget.rideId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your rating!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideCompleteNotifierProvider);
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    if (state.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null && state.summary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(rideCompleteNotifierProvider.notifier)
                    .loadRide(widget.rideId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final summary = state.summary!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Complete'),
        actions: [TextButton(onPressed: _onDone, child: const Text('Done'))],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trip Summary Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trip Summary', style: theme.textTheme.titleMedium),
                    const Divider(),
                    _SummaryRow(label: 'From', value: summary.pickupAddress),
                    _SummaryRow(label: 'To', value: summary.destinationAddress),
                    _SummaryRow(
                      label: 'Base Fare',
                      value: '\$${summary.baseFare.toStringAsFixed(2)}',
                    ),
                    if (state.selectedTip != null)
                      _SummaryRow(
                        label: 'Tip',
                        value:
                            '\$${state.selectedTip!.amount.toStringAsFixed(2)}',
                      ),
                    const Divider(),
                    _SummaryRow(
                      label: 'Total',
                      value: '\$${state.finalTotal.toStringAsFixed(2)}',
                      bold: true,
                    ),
                    _SummaryRow(label: 'Driver', value: summary.driverName),
                    _SummaryRow(
                      label: 'Duration',
                      value: '${summary.tripDurationMinutes} min',
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: tokens.spaceLg),

            // Tip Selector
            _TipSelectorSection(
              baseFare: summary.baseFare,
              isCash: summary.paymentMethod == PaymentMethod.cash,
              selectedTip: state.selectedTip,
              onPresetSelected: (tip) => ref
                  .read(rideCompleteNotifierProvider.notifier)
                  .selectPresetTip(tip),
              onCustomTipChanged: (amount) => ref
                  .read(rideCompleteNotifierProvider.notifier)
                  .setCustomTip(amount),
              onSkipped: () =>
                  ref.read(rideCompleteNotifierProvider.notifier).skipTip(),
            ),

            SizedBox(height: tokens.spaceLg),

            // Rating Selector
            _RatingSelectorSection(
              state: state.rating,
              feedbackController: _feedbackController,
              onSelectStars: (stars) => ref
                  .read(rideCompleteNotifierProvider.notifier)
                  .setStars(stars),
              onFeedbackChanged: (text) => ref
                  .read(rideCompleteNotifierProvider.notifier)
                  .setFeedback(text),
              onSubmit: _submitRating,
              onSkip: () =>
                  ref.read(rideCompleteNotifierProvider.notifier).skipRating(),
            ),

            if (state.showThankYou) ...[
              SizedBox(height: tokens.spaceLg),
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: EdgeInsets.all(tokens.spaceMd),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: tokens.spaceSm),
                      const Text(
                        'Thank you! Your feedback helps improve SakAI.',
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: tokens.spaceXl),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
          ),
        ],
      ),
    );
  }
}

class _TipSelectorSection extends StatelessWidget {
  const _TipSelectorSection({
    required this.baseFare,
    required this.isCash,
    this.selectedTip,
    this.onPresetSelected,
    this.onCustomTipChanged,
    this.onSkipped,
  });

  final double baseFare;
  final bool isCash;
  final TipOption? selectedTip;
  final void Function(TipOption)? onPresetSelected;
  final void Function(double)? onCustomTipChanged;
  final VoidCallback? onSkipped;

  @override
  Widget build(BuildContext context) {
    if (isCash) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.money, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tip your driver in cash',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Tips are not processed digitally for cash rides',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final presets = TipOption.presets(baseFare);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a Tip',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in presets)
                  ChoiceChip(
                    label: Text(
                      '${preset.label} (\$${preset.amount.toStringAsFixed(2)})',
                    ),
                    selected: selectedTip?.percentage == preset.percentage,
                    onSelected: (_) => onPresetSelected?.call(preset),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onSkipped,
              icon: const Icon(Icons.not_interested),
              label: const Text('No tip, thanks'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingSelectorSection extends StatelessWidget {
  const _RatingSelectorSection({
    required this.state,
    required this.feedbackController,
    this.onSelectStars,
    this.onFeedbackChanged,
    this.onSubmit,
    this.onSkip,
  });

  final RatingState state;
  final TextEditingController feedbackController;
  final void Function(int)? onSelectStars;
  final void Function(String)? onFeedbackChanged;
  final VoidCallback? onSubmit;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate Your Driver',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () => onSelectStars?.call(i),
                    child: Semantics(
                      label: 'Rate $i star${i > 1 ? 's' : ''}',
                      child: Icon(
                        i <= state.stars ? Icons.star : Icons.star_border,
                        size: 44,
                        color: i <= state.stars ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
            if (state.stars > 0) ...[
              const SizedBox(height: 12),
              TextField(
                controller: feedbackController,
                onChanged: onFeedbackChanged,
                maxLength: 500,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Share feedback (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onSkip, child: const Text('Skip')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: state.stars > 0 && !state.submitting
                      ? onSubmit
                      : null,
                  child: state.submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Rating'),
                ),
              ],
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
