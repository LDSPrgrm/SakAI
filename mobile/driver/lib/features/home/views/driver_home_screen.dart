import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../view_models/driver_home_notifier.dart';

/// Driver home screen with online/offline toggle, GPS indicator, and earnings nav.
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  late final DriverHomeNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(driverHomeNotifierProvider.notifier);
    // Set up WS event callbacks.
    final wsClient = ref.read(wsClientProvider);
    _notifier.setupWsListener(wsClient);

    // When a ride offer arrives, navigate to the offer screen.
    _notifier.onRideOffer = (offer) {
      if (context.mounted) {
        context.push(Routes.rideOffer, extra: offer);
      }
    };

    // When the ride is cancelled while on home screen, show a message.
    _notifier.onRideCancelled = (rideId) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ride was cancelled.')));
      }
    };
  }

  @override
  void dispose() {
    _notifier.unsubscribeWs();
    _notifier.onRideOffer = null;
    _notifier.onRideCancelled = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverHomeNotifierProvider);
    final notifier = ref.read(driverHomeNotifierProvider.notifier);
    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    ref.listen<DriverHomeState>(driverHomeNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        }
        notifier.clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('SakAI · Driver'),
        actions: [
          // Online status indicator.
          Padding(
            padding: EdgeInsets.only(right: tokens.spaceMd),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.online
                        ? SakaiSemanticColors.of(context).success
                        : scheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
                SizedBox(width: tokens.spaceSm),
                Text(
                  state.online ? 'Available' : 'Unavailable',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: state.online
                        ? SakaiSemanticColors.of(context).success
                        : scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: scheme.primary),
              child: Text(
                'SakAI Driver\nMenu',
                style: TextStyle(color: scheme.onPrimary, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Earnings'),
              onTap: () {
                Navigator.pop(context);
                context.push(Routes.earnings);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () {
                // Clear WS connection and navigate to login.
                ref.read(wsClientProvider).disconnect();
                context.go(Routes.login);
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.1),
              scheme.surface,
              scheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(tokens.spaceMd),
          children: [
            // GPS warning banner.
            if (state.online && !state.gpsAvailable) ...[
              Container(
                padding: EdgeInsets.all(tokens.spaceSm),
                decoration: BoxDecoration(
                  color: SakaiSemanticColors.of(
                    context,
                  ).warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.signal_wifi_off,
                      color: SakaiSemanticColors.of(context).warning,
                      size: 20,
                    ),
                    SizedBox(width: tokens.spaceSm),
                    Expanded(
                      child: Text(
                        'Waiting for GPS signal…',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SakaiSemanticColors.of(context).warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.spaceSm),
            ],
            Text(
              'Driver workspace',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: tokens.spaceSm),
            SakaiGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.online ? 'You are available' : 'Go available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: tokens.spaceMd),
                  SakaiPrimaryButton(
                    label: state.loading
                        ? (state.online ? 'Going offline…' : 'Going online…')
                        : (state.online ? 'End shift' : 'Start shift'),
                    icon: state.online
                        ? Icons.stop_circle
                        : Icons.play_circle_outline,
                    onPressed: state.loading
                        ? null
                        : () => notifier.toggleStatus(),
                  ),
                  SizedBox(height: tokens.spaceSm),
                  SakaiSecondaryButton(
                    label: 'View earnings',
                    icon: Icons.payments_outlined,
                    onPressed: state.online
                        ? () => context.push(Routes.earnings)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
