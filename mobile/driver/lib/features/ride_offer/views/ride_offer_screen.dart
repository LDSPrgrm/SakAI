import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../models/ride_offer_state.dart';
import '../view_models/ride_offer_notifier.dart';

/// Full-screen ride offer displayed to an online driver.
class RideOfferScreen extends ConsumerStatefulWidget {
  final WsEventRideRequested offerEvent;
  const RideOfferScreen({super.key, required this.offerEvent});

  @override
  ConsumerState<RideOfferScreen> createState() => _RideOfferScreenState();
}

class _RideOfferScreenState extends ConsumerState<RideOfferScreen> {
  late final RideOfferManager _manager;

  @override
  void initState() {
    super.initState();
    final apiClient = ref.read(apiClientProvider);
    _manager = RideOfferManager(
      apiClient: apiClient,
      offer: RideOfferState.fromEvent(widget.offerEvent),
    );
    _manager.startCountdown();
    _manager.onAccepted = (rideId) {
      if (context.mounted) context.go(Routes.rideActive);
    };
    _manager.onDeclined = () {
      if (context.mounted) context.pop();
    };
    _manager.onExpired = () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer expired'),
            duration: Duration(seconds: 2),
          ),
        );
        context.pop();
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
    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final offer = _manager.offer;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.primary.withValues(alpha: 0.15), scheme.surface],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(tokens.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'New Ride Offer',
                            style:
                                Theme.of(context).textTheme.headlineSmall,
                          ),
                          SakaiCountdownChip(
                            deadline: _manager.offer.expiresAt,
                            dangerThreshold: const Duration(seconds: 10),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.spaceLg),
                      SakaiGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: scheme.primaryContainer,
                                  child: Icon(
                                    Icons.person,
                                    color: scheme.onPrimaryContainer,
                                  ),
                                ),
                                SizedBox(width: tokens.spaceSm),
                                Text(
                                  offer.passenger.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ],
                            ),
                            Divider(height: tokens.spaceLg),
                            Wrap(
                              spacing: tokens.spaceSm,
                              runSpacing: tokens.spaceSm,
                              children: [
                                if (offer.estimatedFare != null)
                                  SakaiFareChip(
                                    amount:
                                        'P${offer.estimatedFare!.toStringAsFixed(2)}',
                                    subtitle: 'estimate',
                                  ),
                                if (offer.rideType != null)
                                  SakaiRideTypeChip(
                                    label: _rideTypeLabel(offer.rideType!),
                                    icon: _rideTypeIcon(offer.rideType!),
                                  ),
                              ],
                            ),
                            SizedBox(height: tokens.spaceMd),
                            _LocationRow(
                              icon: Icons.circle,
                              iconColor: scheme.primary,
                              label: 'Pickup',
                              value: offer.originAddress ??
                                  '(${offer.origin.lat.toStringAsFixed(4)}, ${offer.origin.lng.toStringAsFixed(4)})',
                            ),
                            SizedBox(height: tokens.spaceMd),
                            _LocationRow(
                              icon: Icons.location_on,
                              iconColor: scheme.error,
                              label: 'Destination',
                              value: offer.destinationAddress ??
                                  '(${offer.destination.lat.toStringAsFixed(4)}, ${offer.destination.lng.toStringAsFixed(4)})',
                            ),
                            if (offer.notes != null) ...[
                              Divider(height: tokens.spaceLg),
                              Text(
                                'Note: ${offer.notes}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_manager.error != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spaceMd,
                    vertical: tokens.spaceSm,
                  ),
                  child: Text(
                    _manager.error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SakaiSemanticColors.of(context).danger,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SakaiBottomActionBar(
                actions: [
                  SakaiSecondaryButton(
                    label: _manager.declining ? 'Declining…' : 'Decline',
                    icon: Icons.cancel_outlined,
                    onPressed: _manager.accepting || _manager.declining
                        ? null
                        : () => _manager.declineRide(),
                  ),
                  SakaiPrimaryButton(
                    label: _manager.accepting ? 'Accepting…' : 'Accept Ride',
                    icon: Icons.check_circle,
                    onPressed: _manager.accepting || _manager.declining
                        ? null
                        : () => _manager.acceptRide(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _rideTypeIcon(String rideType) {
    switch (rideType.toLowerCase()) {
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'tricycle':
        return Icons.pest_control_rodent;
      default:
        return Icons.directions_car;
    }
  }

  String _rideTypeLabel(String rideType) {
    switch (rideType.toLowerCase()) {
      case 'motorcycle':
        return 'Motorcycle';
      case 'tricycle':
        return 'Tricycle';
      default:
        return 'Car';
    }
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 12, color: iconColor),
        SizedBox(width: tokens.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
