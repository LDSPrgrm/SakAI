import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart' hide DriverRatingState;

import '../../../app/router.dart';
import '../models/driver_rating_state.dart';
import '../view_models/driver_rating_notifier.dart';
import 'driver_rating_repository_provider.dart';

/// Driver rating screen — 5-star rating UI with optional feedback.
class DriverRatingScreen extends StatefulWidget {
  const DriverRatingScreen({
    super.key,
    required this.rideId,
    required this.passengerName,
  });

  final String rideId;
  final String passengerName;

  @override
  State<DriverRatingScreen> createState() => _DriverRatingScreenState();
}

class _DriverRatingScreenState extends State<DriverRatingScreen> {
  late final DriverRatingNotifier _notifier;
  final _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notifier = DriverRatingNotifier(
      repository: DriverRatingRepositoryProvider.of(context),
      initialState: DriverRatingState(
        rideId: widget.rideId,
        passengerName: widget.passengerName,
      ),
    );
    _feedbackController.addListener(() {
      _notifier.setFeedback(_feedbackController.text);
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    final success = await _notifier.submitRating();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your rating!')),
      );
    }
  }

  void _onDone() {
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _notifier,
      builder: (context, _) => _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    final state = _notifier.state;
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    if (state.isSubmitted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rating Submitted'),
          actions: [TextButton(onPressed: _onDone, child: const Text('Home'))],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: tokens.spaceMd),
              Text('Thank you!', style: theme.textTheme.headlineSmall),
              SizedBox(height: tokens.spaceSm),
              Text(
                'Your feedback helps improve SakAI.',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spaceLg),
              ElevatedButton.icon(
                onPressed: _onDone,
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Passenger'),
        actions: [TextButton(onPressed: _onDone, child: const Text('Skip'))],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: Column(
                  children: [
                    Icon(
                      Icons.person,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(height: tokens.spaceSm),
                    Text(
                      state.passengerName,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      'How was this passenger?',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: tokens.spaceLg),

            Card(
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rate this passenger',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: tokens.spaceMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 1; i <= 5; i++)
                          GestureDetector(
                            onTap: () => _notifier.setStars(i),
                            child: Semantics(
                              label: 'Rate $i star${i > 1 ? 's' : ''}',
                              child: Icon(
                                i <= state.stars
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 48,
                                color: i <= state.stars
                                    ? Colors.amber
                                    : Colors.grey,
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
                        decoration: const InputDecoration(
                          labelText: 'Share feedback (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    SizedBox(height: tokens.spaceMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _notifier.skipRating(),
                          child: const Text('Skip'),
                        ),
                        SizedBox(width: tokens.spaceSm),
                        ElevatedButton(
                          onPressed: state.stars > 0 && !state.isSubmitting
                              ? _submitRating
                              : null,
                          child: state.isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
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
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
