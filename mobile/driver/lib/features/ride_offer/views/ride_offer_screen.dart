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
          child: Padding(
            padding: EdgeInsets.all(tokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Ride Offer',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spaceSm,
                        vertical: tokens.spaceXs,
                      ),
                      decoration: BoxDecoration(
                        color: _manager.countdownSeconds <= 10
                            ? SakaiSemanticColors.of(context).danger
                            : scheme.primary,
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                      ),
                      child: Text(
                        '${_manager.countdownSeconds}s',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
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
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Divider(height: tokens.spaceLg),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.circle, size: 12, color: scheme.primary),
                          SizedBox(width: tokens.spaceSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pickup',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                Text(
                                  offer.originAddress ??
                                      '(${offer.origin.lat.toStringAsFixed(4)}, ${offer.origin.lng.toStringAsFixed(4)})',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.spaceMd),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: scheme.error,
                          ),
                          SizedBox(width: tokens.spaceSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Destination',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                Text(
                                  offer.destinationAddress ??
                                      '(${offer.destination.lat.toStringAsFixed(4)}, ${offer.destination.lng.toStringAsFixed(4)})',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(height: tokens.spaceLg),
                      if (offer.notes != null)
                        Text(
                          'Note: ${offer.notes}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_manager.error != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: tokens.spaceSm),
                    child: Text(
                      _manager.error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SakaiSemanticColors.of(context).danger,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SakaiPrimaryButton(
                  label: _manager.accepting ? 'Accepting…' : 'Accept Ride',
                  icon: Icons.check_circle,
                  onPressed: _manager.accepting || _manager.declining
                      ? null
                      : () => _manager.acceptRide(),
                ),
                SizedBox(height: tokens.spaceSm),
                SakaiSecondaryButton(
                  label: _manager.declining ? 'Declining…' : 'Decline',
                  icon: Icons.cancel_outlined,
                  onPressed: _manager.accepting || _manager.declining
                      ? null
                      : () => _manager.declineRide(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
