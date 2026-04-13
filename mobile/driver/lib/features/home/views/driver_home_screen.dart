import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart' hide LatLng;

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../view_models/driver_home_notifier.dart';

/// Driver home screen — full-screen Google Map with online/offline toggle,
/// GPS streaming, and ride offer handling.
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  late final DriverHomeNotifier _notifier;
  GoogleMapController? _mapController;
  LatLng _currentLatLng = const LatLng(14.5995, 120.9842);
  Timer? _gpsUpdateTimer;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(driverHomeNotifierProvider.notifier);
    _setupWsListener();
    _initLocation();

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

  Future<void> _initLocation() async {
    try {
      final permission = await _ensureLocationPermission();
      if (!permission) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() => _currentLatLng = LatLng(pos.latitude, pos.longitude));
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLatLng, 15),
        );
      }
    } catch (_) {
      // Ignore — GPS not critical for home screen
    }
  }

  Future<bool> _ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  void _setupWsListener() {
    final wsClient = ref.read(wsClientProvider);
    _notifier.setupWsListener(wsClient);
  }

  @override
  void dispose() {
    _gpsUpdateTimer?.cancel();
    _mapController?.dispose();
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

    // Build map markers
    final markers = <Marker>{};
    markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: _currentLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          state.online ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: state.online ? 'You (Online)' : 'You (Offline)',
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng,
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: markers,
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => CircleAvatar(
                      backgroundColor: scheme.surface.withValues(alpha: 0.9),
                      child: IconButton(
                        icon: Icon(Icons.menu, color: scheme.onSurface),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ),
                  // Online indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.online
                                ? SakaiSemanticColors.of(context).success
                                : scheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.online ? 'Available' : 'Unavailable',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: state.online
                                    ? SakaiSemanticColors.of(context).success
                                    : scheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // GPS warning banner
          if (state.online && !state.gpsAvailable)
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
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
                      size: 18,
                    ),
                    const SizedBox(width: 8),
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
            ),

          // Bottom card — online/offline toggle
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: tokens.elevationLg,
              ),
              padding: EdgeInsets.all(tokens.spaceLg),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      state.online
                          ? 'You are online — waiting for rides'
                          : 'Go online to start accepting rides',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SakaiPrimaryButton(
                      label: state.loading
                          ? (state.online ? 'Going offline…' : 'Going online…')
                          : (state.online ? 'End shift' : 'Start shift'),
                      icon: state.online
                          ? Icons.stop_circle
                          : Icons.play_circle_outline,
                      onPressed: state.loading
                          ? null
                          : () async {
                              final wasOnline = state.online;
                              await notifier.toggleStatus();
                              // Update GPS on toggle
                              if (!wasOnline) {
                                _startGpsUpdates();
                              } else {
                                _stopGpsUpdates();
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    SakaiSecondaryButton(
                      label: 'View earnings',
                      icon: Icons.payments_outlined,
                      onPressed: () => context.push(Routes.earnings),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // Center location button
          Positioned(
            right: 16,
            bottom: 280,
            child: FloatingActionButton.small(
              onPressed: () {
                if (_mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(_currentLatLng, 15),
                  );
                }
              },
              backgroundColor: scheme.surface.withValues(alpha: 0.9),
              child: Icon(Icons.my_location, color: scheme.onSurface),
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
              onTap: () async {
                final tokenStorage = ref.read(tokenStorageProvider);
                final refreshToken = await tokenStorage.getRefreshToken();
                if (refreshToken != null && refreshToken.isNotEmpty) {
                  try {
                    await ref
                        .read(authRepositoryProvider)
                        .logout(refreshToken: refreshToken);
                  } catch (_) {
                    // Best effort: local session must still be cleared.
                  }
                }
                await ref.read(wsConnectionProvider).disconnect();
                await tokenStorage.clear();
                ref
                    .read(authStateProvider.notifier)
                    .markUnauthenticated(forceLogin: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startGpsUpdates() {
    _stopGpsUpdates();
    _gpsUpdateTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      try {
        final permission = await _ensureLocationPermission();
        if (!permission) return;
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        if (mounted) {
          setState(() => _currentLatLng = LatLng(pos.latitude, pos.longitude));
        }
      } catch (_) {
        // Ignore silently
      }
    });
  }

  void _stopGpsUpdates() {
    _gpsUpdateTimer?.cancel();
    _gpsUpdateTimer = null;
  }
}
