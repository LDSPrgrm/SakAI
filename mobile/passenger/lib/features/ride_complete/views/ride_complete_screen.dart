import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';
import '../models/tip_option.dart';
import '../models/rating_state.dart';
import '../models/ride_completion_summary.dart' show PaymentMethod;
import '../view_models/ride_complete_notifier.dart'
    show rideCompleteNotifierProvider;

/// Ride completion screen showing trip summary, tip selector, and rating.
///
/// Features auto-close with visible countdown timer.
class RideCompleteScreen extends ConsumerStatefulWidget {
  const RideCompleteScreen({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<RideCompleteScreen> createState() => _RideCompleteScreenState();
}

class _RideCompleteScreenState extends ConsumerState<RideCompleteScreen>
    with TickerProviderStateMixin {
  final _feedbackController = TextEditingController();
  late AnimationController _completionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _completionController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _completionController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    final notifier = ref.read(rideCompleteNotifierProvider.notifier);
    notifier.init(widget.rideId);
    // Defer loadRide to avoid modifying provider state during widget build.
    Future.microtask(() => notifier.loadRide(widget.rideId));

    _completionController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _completionController.dispose();
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
        const SnackBar(
          content: Text('Thank you for your rating!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideCompleteNotifierProvider);
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    // Auto-navigate home when timer completes
    if (state.shouldNavigateHome && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.home);
      });
    }

    if (state.loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: tokens.spaceMd),
              Text(
                'Loading ride details...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
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
      body: CustomScrollView(
        slivers: [
          // Modern gradient app bar
          SliverAppBar(
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Ride Complete!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(tokens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Trip Summary Card with modern design
                  _ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: tokens.spaceSm),
                            Text(
                              'Trip Summary',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: tokens.spaceMd),
                        const Divider(),
                        SizedBox(height: tokens.spaceSm),
                        _SummaryRow(
                          icon: Icons.location_on,
                          label: 'From',
                          value: summary.pickupAddress,
                        ),
                        SizedBox(height: tokens.spaceSm),
                        _SummaryRow(
                          icon: Icons.flag,
                          label: 'To',
                          value: summary.destinationAddress,
                        ),
                        SizedBox(height: tokens.spaceMd),
                        _SummaryRow(
                          icon: Icons.person_outline,
                          label: 'Driver',
                          value: summary.driverName,
                        ),
                        SizedBox(height: tokens.spaceSm),
                        _SummaryRow(
                          icon: Icons.access_time,
                          label: 'Duration',
                          value: '${summary.tripDurationMinutes} min',
                        ),
                        const Divider(),
                        SizedBox(height: tokens.spaceSm),
                        _SummaryRow(
                          icon: Icons.attach_money,
                          label: 'Base Fare',
                          value: '\$${summary.baseFare.toStringAsFixed(2)}',
                          bold: true,
                        ),
                        if (state.selectedTip != null) ...[
                          SizedBox(height: tokens.spaceSm),
                          _SummaryRow(
                            icon: Icons.card_giftcard,
                            label: 'Tip',
                            value:
                                '\$${state.selectedTip!.amount.toStringAsFixed(2)}',
                            valueColor: theme.colorScheme.primary,
                          ),
                        ],
                        const Divider(),
                        SizedBox(height: tokens.spaceSm),
                        _SummaryRow(
                          icon: Icons.payments,
                          label: 'Total',
                          value: '\$${state.finalTotal.toStringAsFixed(2)}',
                          bold: true,
                          valueColor: theme.colorScheme.primary,
                          valueSize: 20,
                        ),
                      ],
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
                    onSkipped: () => ref
                        .read(rideCompleteNotifierProvider.notifier)
                        .skipTip(),
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
                    onSkip: () => ref
                        .read(rideCompleteNotifierProvider.notifier)
                        .skipRating(),
                  ),

                  if (state.showThankYou) ...[
                    SizedBox(height: tokens.spaceLg),
                    _ThankYouCard(
                      secondsRemaining: state.rating.secondsRemaining,
                      countdownActive: state.rating.countdownActive,
                      onGoHome: _onDone,
                    ),
                  ],

                  SizedBox(height: tokens.spaceXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern card with subtle shadow and rounded corners.
class _ModernCard extends StatelessWidget {
  const _ModernCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
    this.valueSize = 16,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            softWrap: true,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : null,
              fontSize: valueSize,
              color: valueColor,
            ),
          ),
        ),
      ],
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
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    if (isCash) {
      return _ModernCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.money,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: tokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tip your driver in cash',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: tokens.spaceXs),
                  Text(
                    'Tips are not processed digitally for cash rides',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final presets = TipOption.presets(baseFare);

    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, color: theme.colorScheme.primary),
              SizedBox(width: tokens.spaceSm),
              Text(
                'Add a Tip',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final preset in presets)
                ChoiceChip(
                  label: Text(
                    '${preset.label}\n\$${preset.amount.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                  selected: selectedTip?.percentage == preset.percentage,
                  selectedColor: theme.colorScheme.primaryContainer,
                  onSelected: (_) => onPresetSelected?.call(preset),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
          TextButton.icon(
            onPressed: onSkipped,
            icon: const Icon(Icons.not_interested),
            label: const Text('No tip, thanks'),
          ),
        ],
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
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rate_rounded, color: Colors.amber[700]),
              SizedBox(width: tokens.spaceSm),
              Text(
                'Rate Your Driver',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => onSelectStars?.call(i),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.all(i <= state.stars ? 4 : 0),
                    child: Semantics(
                      label: 'Rate $i star${i > 1 ? 's' : ''}',
                      child: Icon(
                        i <= state.stars
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 52,
                        color: i <= state.stars
                            ? Colors.amber[700]
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (state.stars > 0) ...[
            SizedBox(height: tokens.spaceMd),
            TextField(
              controller: feedbackController,
              onChanged: onFeedbackChanged,
              maxLength: 500,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Share feedback (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
          SizedBox(height: tokens.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onSkip, child: const Text('Skip')),
              SizedBox(width: tokens.spaceSm),
              ElevatedButton(
                onPressed: state.stars > 0 && !state.submitting
                    ? onSubmit
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: state.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Rating'),
              ),
            ],
          ),
          if (state.error != null)
            Padding(
              padding: EdgeInsets.only(top: tokens.spaceSm),
              child: Text(
                state.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}

/// Thank you card with countdown timer.
class _ThankYouCard extends StatelessWidget {
  const _ThankYouCard({
    required this.secondsRemaining,
    required this.countdownActive,
    required this.onGoHome,
  });

  final int secondsRemaining;
  final bool countdownActive;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    return _ModernCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              SizedBox(width: tokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thank you!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Your feedback helps improve SakAI.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (countdownActive && secondsRemaining > 0) ...[
            SizedBox(height: tokens.spaceMd),
            LinearProgressIndicator(
              value: secondsRemaining / 15.0,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            SizedBox(height: tokens.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Going home in $secondsRemaining seconds...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                TextButton(onPressed: onGoHome, child: const Text('Go Now')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
