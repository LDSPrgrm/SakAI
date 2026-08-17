import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart' hide DriverRatingState;

import '../../../app/router.dart';
import '../view_models/driver_rating_notifier.dart'
    show driverRatingNotifierProvider;

/// Driver rating screen — 5-star rating UI with optional feedback.
///
/// Features auto-close with visible countdown timer.
class DriverRatingScreen extends ConsumerStatefulWidget {
  const DriverRatingScreen({
    super.key,
    required this.rideId,
    required this.passengerName,
  });

  final String rideId;
  final String passengerName;

  @override
  ConsumerState<DriverRatingScreen> createState() => _DriverRatingScreenState();
}

class _DriverRatingScreenState extends ConsumerState<DriverRatingScreen>
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

    // Defer initialization until after widget build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(driverRatingNotifierProvider.notifier)
            .init(rideId: widget.rideId, passengerName: widget.passengerName);
      }
    });

    _completionController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    final notifier = ref.read(driverRatingNotifierProvider.notifier);
    final success = await notifier.submitRating();
    if (success && mounted) {
      SakaiSnackBar.success(context, 'Thank you for your rating!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverRatingNotifierProvider);
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);
    final warning = SakaiSemanticColors.of(context).warning;

    // Auto-navigate home when timer completes
    if (state.shouldNavigateHome && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.home);
      });
    }

    // Success state after submission
    if (state.isSubmitted) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
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
                            padding: EdgeInsets.all(tokens.spaceMd),
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
                            'Rating Submitted!',
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
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceXl),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ModernCard(
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 72,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(height: tokens.spaceMd),
                            Text(
                              'Thank you!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: tokens.spaceSm),
                            Text(
                              'Your feedback helps improve SakAI.',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: tokens.spaceLg),
                            if (state.countdownActive &&
                                state.secondsRemaining > 0) ...[
                              LinearProgressIndicator(
                                value: state.secondsRemaining / 15.0,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              SizedBox(height: tokens.spaceSm),
                              Text(
                                'Going home in ${state.secondsRemaining} seconds...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ),
                              SizedBox(height: tokens.spaceMd),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => ref
                                      .read(
                                        driverRatingNotifierProvider.notifier,
                                      )
                                      .navigateHome(),
                                  icon: const Icon(Icons.home),
                                  label: const Text('Go Home Now'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                          padding: EdgeInsets.all(tokens.spaceMd),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Rate Your Passenger',
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
                  // Passenger info card
                  _ModernCard(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: tokens.spaceMd),
                        Text(
                          state.passengerName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: tokens.spaceSm),
                        Text(
                          'How was this passenger?',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: tokens.spaceLg),

                  // Rating card
                  _ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rate_rounded,
                              color: SakaiSemanticColors.of(context).warning,
                            ),
                            SizedBox(width: tokens.spaceSm),
                            Text(
                              'Rate this passenger',
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
                                onTap: () => ref
                                    .read(driverRatingNotifierProvider.notifier)
                                    .setStars(i),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  padding: EdgeInsets.all(
                                    i <= state.stars ? 4 : 0,
                                  ),
                                  child: Semantics(
                                    label: 'Rate $i star${i > 1 ? 's' : ''}',
                                    child: Icon(
                                      i <= state.stars
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      size: 52,
                                      color: i <= state.stars
                                          ? warning
                                          : theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (state.stars > 0) ...[
                          SizedBox(height: tokens.spaceMd),
                          TextField(
                            controller: _feedbackController,
                            maxLength: 500,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Share feedback (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ],
                        SizedBox(height: tokens.spaceMd),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => ref
                                  .read(driverRatingNotifierProvider.notifier)
                                  .skipRating(),
                              child: const Text('Skip'),
                            ),
                            SizedBox(width: tokens.spaceSm),
                            ElevatedButton(
                              onPressed: state.stars > 0 && !state.isSubmitting
                                  ? _submitRating
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
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
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

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
    final tokens = SakaiDesignTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(
                  alpha: 0.05,
                ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(tokens.spaceLg),
      child: child,
    );
  }
}
