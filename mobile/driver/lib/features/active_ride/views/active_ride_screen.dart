import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../earnings/view_models/earnings_notifier.dart';
import '../models/active_ride_step.dart';
import '../view_models/active_ride_notifier.dart';

/// Active ride screen with state-driven action buttons.
class ActiveRideScreen extends ConsumerStatefulWidget {
  final RideResponse initialRide;
  const ActiveRideScreen({super.key, required this.initialRide});

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen> {
  late final ActiveRideManager _manager;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(activeRideRepositoryProvider);
    _manager = ActiveRideManager(repo: repo, initialRide: widget.initialRide);
    _manager.onCompleted = (ride) {
      // Wire earnings: extract actual fare and record the ride.
      final actualFare = ride.fare ?? 0.0;
      ref
          .read(earningsNotifierProvider.notifier)
          .addRide(
            rideId: ride.id,
            fare: actualFare,
            completedAt: DateTime.now(),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ride completed')));
        // Navigate to rating screen instead of going directly home.
        context.push(
          Routes.rideRating,
          extra: <String, String>{
            'rideId': ride.id,
            'passengerName': ride.passenger.name,
          },
        );
      }
    };
    _manager.onCancelled = () {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ride cancelled')));
        context.go(Routes.home);
      }
    };
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _manager,
      builder: (context, _) => _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    final state = _manager.state;
    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ride = state.ride;
    final statusLabel = _statusLabel(state.currentStep);
    final statusColor = _statusColor(state.currentStep, context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Ride'),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ride == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(tokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SakaiGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Passenger',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        SizedBox(height: tokens.spaceXs),
                        Text(
                          ride.passenger.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.spaceMd),
                  SakaiGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, size: 12, color: scheme.primary),
                            SizedBox(width: tokens.spaceSm),
                            Text(
                              'Pickup',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                        SizedBox(height: tokens.spaceXs),
                        Text(
                          ride.originAddress ??
                              '(${ride.origin.lat.toStringAsFixed(4)}, ${ride.origin.lng.toStringAsFixed(4)})',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.spaceMd),
                  SakaiGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: scheme.error,
                            ),
                            SizedBox(width: tokens.spaceSm),
                            Text(
                              'Destination',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                        SizedBox(height: tokens.spaceXs),
                        Text(
                          ride.destinationAddress ??
                              '(${ride.destination.lat.toStringAsFixed(4)}, ${ride.destination.lng.toStringAsFixed(4)})',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (state.isTransitioning)
                    const Center(child: CircularProgressIndicator()),
                  if (!state.isTransitioning) ...[
                    if (state.currentStep == ActiveRideStep.enRoute) ...[
                      SakaiSecondaryButton(
                        label: 'Navigate',
                        icon: Icons.directions,
                        onPressed: () => _openNavigation(context),
                      ),
                      SizedBox(height: tokens.spaceSm),
                    ],
                    if (state.currentStep == ActiveRideStep.enRoute)
                      SakaiPrimaryButton(
                        label: "I've Arrived",
                        icon: Icons.flag,
                        onPressed: () => _manager.arriveAtPickup(),
                      ),
                    if (state.currentStep == ActiveRideStep.arrived)
                      SakaiPrimaryButton(
                        label: 'Start Ride',
                        icon: Icons.play_arrow,
                        onPressed: () => _manager.startRide(),
                      ),
                    if (state.currentStep == ActiveRideStep.inProgress)
                      SakaiPrimaryButton(
                        label: 'Complete Ride',
                        icon: Icons.check_circle,
                        onPressed: () => _manager.completeRide(),
                      ),
                    if (state.currentStep != ActiveRideStep.inProgress) ...[
                      SizedBox(height: tokens.spaceSm),
                      SakaiSecondaryButton(
                        label: 'Cancel Ride',
                        icon: Icons.cancel_outlined,
                        onPressed: () => _showCancelConfirmation(context),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }

  Future<void> _openNavigation(BuildContext context) async {
    final ride = widget.initialRide;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${ride.destination.lat},${ride.destination.lng}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showCancelConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      _manager.cancelRide();
    }
  }

  String _statusLabel(ActiveRideStep step) {
    switch (step) {
      case ActiveRideStep.enRoute:
        return 'En Route';
      case ActiveRideStep.arrived:
        return 'Arrived';
      case ActiveRideStep.inProgress:
        return 'In Progress';
    }
  }

  Color _statusColor(ActiveRideStep step, BuildContext context) {
    switch (step) {
      case ActiveRideStep.enRoute:
        return Theme.of(context).colorScheme.primary;
      case ActiveRideStep.arrived:
        return SakaiSemanticColors.of(context).warning;
      case ActiveRideStep.inProgress:
        return SakaiSemanticColors.of(context).success;
    }
  }
}
