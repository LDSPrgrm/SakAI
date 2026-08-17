import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/e2e_mode_stub.dart'
    if (dart.library.js_interop) '../../../app/e2e_mode_web.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import 'package:passenger/features/active_ride/models/active_ride_state.dart';

/// Active ride screen showing real-time driver tracking.
///
/// Pure UI layer — reads state from [ActiveRideController] via
/// [activeRideProvider] and dispatches actions through the controller.
/// WebSocket parsing is handled entirely within the controller.
class ActiveRideScreen extends ConsumerWidget {
  const ActiveRideScreen({super.key, required this.rideId});

  final String rideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(activeRideProvider(rideId));
    ActiveRideStep? previousStep;

    return StreamBuilder<AsyncValue<ActiveRideState>>(
      stream: controller.stateStream,
      initialData: controller.state,
      builder: (context, snapshot) {
        final rideStateAsync =
            snapshot.data ?? const AsyncValue<ActiveRideState>.loading();

        // Show snackbar when transitioning to arrived
        final currentStep = rideStateAsync.value?.currentStep;
        if (previousStep != null &&
            previousStep != ActiveRideStep.arrived &&
            currentStep == ActiveRideStep.arrived) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              SakaiSnackBar.success(context, 'Your driver has arrived!');
            }
          });
        }
        previousStep = currentStep;

        return rideStateAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => Scaffold(
            body: SakaiErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(activeRideProvider(rideId)),
            ),
          ),
          data: (rideState) =>
              _ActiveRideContent(controller: controller, rideState: rideState),
        );
      },
    );
  }
}

class _ActiveRideContent extends StatefulWidget {
  const _ActiveRideContent({required this.controller, required this.rideState});

  final ActiveRideController controller;
  final ActiveRideState rideState;

  @override
  State<_ActiveRideContent> createState() => _ActiveRideContentState();
}

class _ActiveRideContentState extends State<_ActiveRideContent> {
  gmaps.GoogleMapController? _mapController;
  final Set<gmaps.Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Set up navigation callbacks on the controller
    widget.controller.onCompleted = _navigateToRideComplete;
    widget.controller.onCancelled = _navigateToRideCancelled;
  }

  @override
  void didUpdateWidget(covariant _ActiveRideContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _updateMarkers() {
    final rideData = widget.rideState;
    final ride = rideData.ride;
    if (ride == null) return;

    _markers.clear();

    _markers.add(
      gmaps.Marker(
        markerId: const gmaps.MarkerId('pickup'),
        position: gmaps.LatLng(ride.origin.lat, ride.origin.lng),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueGreen,
        ),
        infoWindow: gmaps.InfoWindow(
          title: 'Pickup',
          snippet: ride.originAddress ?? '',
        ),
      ),
    );

    _markers.add(
      gmaps.Marker(
        markerId: const gmaps.MarkerId('destination'),
        position: gmaps.LatLng(ride.destination.lat, ride.destination.lng),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueRed,
        ),
        infoWindow: gmaps.InfoWindow(
          title: 'Destination',
          snippet: ride.destinationAddress ?? '',
        ),
      ),
    );

    // Driver marker from state
    final driverLocation = rideData.driverLocation;
    if (driverLocation != null) {
      _markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('driver'),
          position: driverLocation,
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueAzure,
          ),
          infoWindow: const gmaps.InfoWindow(title: 'Your Driver'),
        ),
      );
    }
  }

  void _navigateToRideComplete(String rideId) {
    if (!mounted) return;
    // Defer navigation to avoid mutating providers during the build phase.
    // This callback is invoked from StreamBuilder.builder, which runs during
    // widget build; pushing a route synchronously would mount the destination
    // screen (and its initState provider mutations) before build completes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.push(Routes.rideComplete, extra: rideId);
      }
    });
  }

  void _navigateToRideCancelled(String rideId) {
    if (!mounted) return;
    // Defer navigation to avoid mutating providers during the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go('/ride/cancelled/$rideId');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for snackbar events via stream
    final rideState = widget.rideState;
    final ride = rideState.ride;
    if (ride == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final gmaps.LatLng initialTarget;
    if (rideState.driverLocation != null) {
      initialTarget = rideState.driverLocation!;
    } else {
      initialTarget = gmaps.LatLng(ride.origin.lat, ride.origin.lng);
    }

    final mapWidget = (kIsWeb && isE2EMode())
        ? Container(
            key: const ValueKey('e2e-map-placeholder'),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: const Text('Map (E2E placeholder)'),
          )
        : gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
              target: initialTarget,
              zoom: 14,
            ),
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );

    return Scaffold(
      body: Stack(
        children: [
          mapWidget,

          // P6 SOS banner — anchored at the top so it sits above the
          // driver card. Renders an empty SizedBox when sos.active==false.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SosBanner(state: rideState.sos),
          ),

          if (rideState.driverName != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            child: Icon(Icons.person, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rideState.driverName!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                if (rideState.driverVehicle != null)
                                  Text(
                                    rideState.driverVehicle!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          _buildStatusIndicator(rideState.currentStep),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        _statusText(rideState.currentStep),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            right: 16,
            bottom: 220, // Sit above the bottom card
            child: FloatingActionButton(
              heroTag: 'sos_button',
              onPressed: () => _showSOSConfirmation(context),
              backgroundColor: SakaiSemanticColors.of(context).danger,
              child: const Icon(Icons.sos, color: Colors.white, size: 32),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ride ${ride.id.substring(0, 8)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ride.originAddress ??
                          '(${ride.origin.lat.toStringAsFixed(4)}, ${ride.origin.lng.toStringAsFixed(4)})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ride.destinationAddress ??
                          '(${ride.destination.lat.toStringAsFixed(4)}, ${ride.destination.lng.toStringAsFixed(4)})',
                      style: Theme.of(context).textTheme.bodyMedium,
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

  Future<void> _showSOSConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency SOS'),
        content: const Text(
          'This will alert our emergency team and local authorities. '
          'Are you sure you want to trigger an SOS?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SakaiSemanticColors.of(context).danger,
            ),
            child: const Text(
              'TRIGGER SOS',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await widget.controller.triggerSOS(reason: 'User triggered SOS from app');
      if (context.mounted) {
        SakaiSnackBar.error(context, 'SOS Alert Sent! Help is on the way.');
      }
    }
  }

  Widget _buildStatusIndicator(ActiveRideStep step) {
    final semantic = SakaiSemanticColors.of(context);
    Color color;
    String text;

    switch (step) {
      case ActiveRideStep.enRoute:
        color = semantic.accentBlue;
        text = 'En Route';
        break;
      case ActiveRideStep.arrived:
        color = semantic.success;
        text = 'Arrived';
        break;
      case ActiveRideStep.inProgress:
        color = semantic.warning;
        text = 'In Progress';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _statusText(ActiveRideStep step) {
    switch (step) {
      case ActiveRideStep.enRoute:
        return 'Your driver is on the way';
      case ActiveRideStep.arrived:
        return 'Your driver has arrived at pickup';
      case ActiveRideStep.inProgress:
        return 'Ride in progress to destination';
    }
  }
}
