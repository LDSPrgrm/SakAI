import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart' hide LatLng;

import '../../../app/e2e_mode_stub.dart'
    if (dart.library.js_interop) '../../../app/e2e_mode_web.dart';
import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../earnings/view_models/earnings_notifier.dart';
import '../../profile/view_models/driver_profile_notifier.dart';
import '../view_models/driver_home_notifier.dart';

/// Two-letter initials from a display name, for the avatar placeholder —
/// the backend has no profile-photo field, so an invented stock photo
/// would be a fabricated value (see plan honesty principle #6).
String _initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

/// Driver home screen — full-screen Google Map with online/offline toggle,
/// GPS streaming, and ride offer handling.
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> with WidgetsBindingObserver {
  late final DriverHomeNotifier _notifier;
  GoogleMapController? _mapController;
  LatLng _currentLatLng = const LatLng(14.5995, 120.9842);
  
  // Custom Visual State
  bool _isMapExpanded = false;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notifier = ref.read(driverHomeNotifierProvider.notifier);
    _setupWsListener();
    _initLocation();

    // Start GPS tracking immediately (updates marker regardless of online status).
    _notifier.startGpsTracking();

    // Check for active ride recovery on screen init
    _notifier.checkForActiveRide();

    // When a ride offer arrives, navigate to the offer screen.
    _notifier.onRideOffer = (offer) {
      if (context.mounted) {
        context.push(Routes.rideOffer, extra: offer);
      }
    };

    // When the ride is cancelled while on home screen, clear state and show message.
    _notifier.onRideCancelled = (rideId) {
      if (context.mounted) {
        _notifier.checkForActiveRide(); // Clear the active ride from state
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ride was cancelled.')));
      }
    };

    // When ride status changes, check for active ride updates
    _notifier.onStatusChanged = (rideId, status) {
      debugPrint('[DRIVER] Ride status changed: $rideId -> $status');
      _notifier.checkForActiveRide();
    };

    // When active ride is detected, navigate to active ride screen
    _notifier.onActiveRideDetected = (activeRide) {
      if (context.mounted) {
        debugPrint(
          '[DRIVER] Active ride detected, navigating to active ride screen',
        );
        context.go(Routes.rideActive, extra: activeRide);
      }
    };
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.hidden) {
      final isOnline = ref.read(driverHomeNotifierProvider).online;
      if (isOnline) {
        debugPrint('[DRIVER] App detached/hidden while online - forcing offline');
        _notifier.toggleStatus(); 
      }
    }
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
    _mapController?.dispose();
    _notifier.unsubscribeWs();
    _notifier.onRideOffer = null;
    _notifier.onRideCancelled = null;
    _notifier.onStatusChanged = null;
    _notifier.onActiveRideDetected = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverHomeNotifierProvider);
    final notifier = ref.read(driverHomeNotifierProvider.notifier);
    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final semantic = SakaiSemanticColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    // Use currentLatLng from notifier state (single GPS source of truth)
    final currentLatLng = state.currentLatLng ?? _currentLatLng;

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
      // Animate camera to follow driver's new position
      if (previous?.currentLatLng != next.currentLatLng &&
          next.currentLatLng != null &&
          _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(next.currentLatLng!),
        );
      }
    });

    // No custom markers needed — the native blue GPS dot shows driver location.
    final markers = <Marker>{};

    final mapWidget = RepaintBoundary(
      child: (kIsWeb && isE2EMode())
          ? Container(
              key: const ValueKey('e2e-map-placeholder'),
              color: scheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const Text('Map (E2E placeholder)'),
            )
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(14.5995, 120.9842),
                zoom: 14,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: markers,
            ),
    );

    // Render Full-Screen Map Mode if expanded
    if (_isMapExpanded) {
      return Scaffold(
        body: Stack(
          children: [
            mapWidget,

            // Floating Top Bar Overlay in Map Mode
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spaceMd,
                  vertical: tokens.spaceSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: scheme.onSurface),
                        onPressed: () => setState(() => _isMapExpanded = false),
                      ),
                    ),
                    // SakAI logo pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spaceMd,
                        vertical: tokens.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: scheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, color: scheme.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'SakAI',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
                      child: IconButton(
                        icon: Icon(Icons.menu, color: scheme.onSurface),
                        onPressed: () => Scaffold.of(context).openDrawer(),
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
                    color: semantic.dangerSubtle,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: semantic.danger, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.signal_wifi_off,
                        color: semantic.danger,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Waiting for GPS signal…',
                          style: textTheme.bodySmall?.copyWith(
                            color: semantic.danger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Active ride banner
            if (state.activeRide != null)
              Positioned(
                top: state.online && !state.gpsAvailable ? 130 : 70,
                left: 16,
                right: 16,
                child: _buildActiveRideCard(context, state, scheme, tokens),
              ),

            // Re-center on current GPS location
            Positioned(
              right: 16,
              bottom: 100,
              child: FloatingActionButton.small(
                heroTag: 'centerLocationExpanded',
                onPressed: () {
                  if (_mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(currentLatLng, 15),
                    );
                  }
                },
                backgroundColor: scheme.surfaceContainerHigh,
                child: Icon(Icons.my_location, color: scheme.primary),
              ),
            ),

            // Bottom Navigation Bar overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildCustomBottomNavBar(context, scheme, tokens),
            ),
          ],
        ),
        drawer: _buildCohesiveDrawer(context, state, scheme),
      );
    }

    // Default console mode/dashboard mode (Mockup 2 layout)
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Menu, SakAI branding, notification + theme toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu button
                  Builder(
                    builder: (context) => CircleAvatar(
                      backgroundColor: scheme.surfaceContainerHigh,
                      child: IconButton(
                        icon: Icon(Icons.menu, color: scheme.onSurface),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ),
                  // SakAI logo + Driver Console label
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spaceMd,
                      vertical: tokens.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: scheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: scheme.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'SakAI',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Driver',
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification + theme toggle buttons
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications_rounded,
                            color: scheme.onSurface,
                            size: 20,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 6),
                      CircleAvatar(
                        backgroundColor: scheme.surfaceContainerHigh,
                        child: IconButton(
                          icon: Icon(
                            _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                            color: _isDarkMode ? scheme.primary : semantic.warning,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isDarkMode = !_isDarkMode;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isDarkMode ? 'Premium Dark Mode Active' : 'Light Mode Active',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: scheme.onInverseSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Scrollable Console
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Greeting Header
                    _buildGreetingHeader(context, state.online, scheme, tokens),

                    // Interactive Live Map Preview Card
                    _buildMapPreviewCard(context, currentLatLng, markers, scheme, tokens, mapWidget),

                    // GPS Signal Warnings
                    if (state.online && !state.gpsAvailable)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: semantic.dangerSubtle,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: semantic.danger.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.signal_wifi_off, color: semantic.danger, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Waiting for GPS signal…',
                                style: textTheme.bodySmall?.copyWith(
                                  color: semantic.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Active Ride Card
                    if (state.activeRide != null)
                      _buildActiveRideCard(context, state, scheme, tokens),

                    // Live Dispatch Active Switch Card (Broadcasting Switch)
                    _buildLiveDispatchCard(context, state.online, state.loading, notifier, scheme, tokens),

                    // Stats Row (Gross Cash, Completed Rides, Shift Hours)
                    _buildStatsRow(scheme, tokens),

                    // Weekly earnings trends: pending an analytics endpoint (follow-on spec).

                    // Fatigue Check Card
                    _buildFatigueCheckCard(scheme, tokens),
                  ],
                ),
              ),
            ),

            // Bottom Custom Tab bar Navigation
            _buildCustomBottomNavBar(context, scheme, tokens),
          ],
        ),
      ),
      drawer: _buildCohesiveDrawer(context, state, scheme),
    );
  }


  // Greeting Header
  Widget _buildGreetingHeader(BuildContext context, bool online, ColorScheme scheme, SakaiDesignTokens tokens) {
    final profile = ref.watch(driverProfileNotifierProvider).profile;
    final driverName = profile?.name ?? 'Driver';
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: online ? scheme.primary : scheme.onSurfaceVariant,
                width: 2.5,
              ),
              boxShadow: online
                  ? [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: scheme.surfaceContainerHighest,
              child: Text(
                _initialsOf(driverName),
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: tokens.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  driverName,
                  style: textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Interactive Live Map Card
  Widget _buildMapPreviewCard(
    BuildContext context,
    LatLng currentLatLng,
    Set<Marker> markers,
    ColorScheme scheme,
    SakaiDesignTokens tokens,
    Widget mapWidget,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 180,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: scheme.outlineVariant, width: 1),
        boxShadow: tokens.elevationMd,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            mapWidget,
            
            // Map controls overlay
            Positioned(
              right: 12,
              bottom: 12,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (_mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLngZoom(currentLatLng, 15),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.outlineVariant, width: 1),
                      ),
                      child: Icon(Icons.my_location, color: scheme.primary, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _isMapExpanded = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.outlineVariant, width: 1),
                      ),
                      child: Icon(Icons.fullscreen_rounded, color: scheme.onSurface, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // Top overlay badge
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  // Sits on top of the map tiles, so it needs its own opaque-ish
                  // surface rather than `scrim` (which is black in both
                  // brightnesses and made this dark-on-dark in dark mode).
                  color: scheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.map_rounded, color: scheme.primary, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      'Interactive Map',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

  // Active Ride Custom Card
  Widget _buildActiveRideCard(
    BuildContext context,
    DriverHomeState state,
    ColorScheme scheme,
    SakaiDesignTokens tokens,
  ) {
    final activeRide = state.activeRide;
    if (activeRide == null) return const SizedBox.shrink();

    final semantic = SakaiSemanticColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.15),
            scheme.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_taxi_rounded,
                    color: scheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ACTIVE TRIP',
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: semantic.primarySubtle,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: Text(
                  _formatRideStatus(activeRide.status).toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activeRide.passenger.name,
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: semantic.danger, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  activeRide.originAddress ?? 'Pickup address',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (context.mounted) {
                  context.go(Routes.rideActive, extra: activeRide);
                }
              },
              icon: Icon(Icons.navigation_rounded, color: scheme.onPrimary, size: 18),
              label: Text(
                'Resume Navigation',
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Live Dispatch Card
  Widget _buildLiveDispatchCard(
    BuildContext context,
    bool online,
    bool loading,
    DriverHomeNotifier notifier,
    ColorScheme scheme,
    SakaiDesignTokens tokens,
  ) {
    final semantic = SakaiSemanticColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(
          color: online
              ? scheme.primary.withValues(alpha: 0.3)
              : scheme.outlineVariant,
          width: 1,
        ),
        boxShadow: online
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildLivePulseDot(online, scheme),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: online
                            ? semantic.primarySubtle
                            : scheme.onSurfaceVariant.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(tokens.radiusMd),
                      ),
                      child: Text(
                        online ? 'ACTIVE' : 'INACTIVE',
                        style: textTheme.labelSmall?.copyWith(
                          color: online ? scheme.primary : scheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Live Dispatch',
                  style: textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  online
                      ? 'Broadcasting location & matching with nearby commuters'
                      : 'Go online to receive and accept ride offers',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          loading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                  ),
                )
              : Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: online,
                    activeThumbColor: scheme.primary,
                    activeTrackColor: scheme.primary.withValues(alpha: 0.3),
                    inactiveThumbColor: scheme.onSurfaceVariant,
                    inactiveTrackColor: scheme.outlineVariant,
                    onChanged: (val) async {
                      await HapticFeedback.mediumImpact();
                      notifier.toggleStatus();
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildLivePulseDot(bool active, ColorScheme scheme) {
    if (!active) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: scheme.onSurfaceVariant,
          shape: BoxShape.circle,
        ),
      );
    }
    return PulsingIndicatorDot(color: scheme.primary);
  }

  // Stats Row (Gross Cash, Completed Rides, Shift Hours)
  Widget _buildStatsRow(ColorScheme scheme, SakaiDesignTokens tokens) {
    final state = ref.watch(earningsNotifierProvider);
    final e = state.earnings;
    final gross = state.isLoading ? '—' : SakaiCurrency.format(e.totalEarnings);
    final rides = state.isLoading ? '—' : '${e.completedRidesCount} Rides';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              label: 'GROSS CASH',
              value: gross,
              icon: Icons.payments_rounded,
              valueColor: scheme.primary,
              scheme: scheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              label: 'COMPLETED',
              value: rides,
              icon: Icons.check_circle_rounded,
              valueColor: scheme.onSurface,
              scheme: scheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              label: 'SHIFT HOURS',
              value: '—',
              icon: Icons.schedule_rounded,
              valueColor: scheme.onSurface,
              scheme: scheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color valueColor,
    required ColorScheme scheme,
  }) {
    final tokens = SakaiDesignTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(tokens.spacing12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: scheme.onSurfaceVariant, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // Fatigue Alert
  Widget _buildFatigueCheckCard(ColorScheme scheme, SakaiDesignTokens tokens) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(tokens.spacing12),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_outlined,
              color: scheme.primary,
              size: 22,
            ),
          ),
          SizedBox(width: tokens.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety Fatigue Check',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'To maintain safety regulations, we recommend a 15-minute break in the next 1h 45m.',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom Bottom Navigation Bar
  Widget _buildCustomBottomNavBar(BuildContext context, ColorScheme scheme, SakaiDesignTokens tokens) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spaceMd,
        vertical: tokens.spacing12,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant, width: 1),
        boxShadow: tokens.elevationMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(
            icon: Icons.dashboard_rounded,
            label: 'Console',
            isActive: true,
            scheme: scheme,
            tokens: tokens,
            onTap: () {},
          ),
          _buildBottomNavItem(
            icon: Icons.payments_rounded,
            label: 'Earnings',
            isActive: false,
            scheme: scheme,
            tokens: tokens,
            onTap: () => context.push(Routes.earnings),
          ),
          _buildBottomNavItem(
            icon: Icons.description_rounded,
            label: 'Documents',
            isActive: false,
            scheme: scheme,
            tokens: tokens,
            onTap: () => context.push(Routes.documents),
          ),
          _buildBottomNavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            isActive: false,
            scheme: scheme,
            tokens: tokens,
            onTap: () => context.push(Routes.settings),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required ColorScheme scheme,
    required SakaiDesignTokens tokens,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // `Colors.transparent` is the absence of a fill, not a theme role.
          color: isActive
              ? SakaiSemanticColors.of(context).primarySubtle
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? scheme.primary : scheme.onSurfaceVariant,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Cohesive navigation drawer (brightness-correct in both light and dark).
  Widget _buildCohesiveDrawer(BuildContext context, DriverHomeState state, ColorScheme scheme) {
    final profile = ref.watch(driverProfileNotifierProvider).profile;
    final driverName = profile?.name ?? 'Driver';
    final tokens = SakaiDesignTokens.of(context);
    final semantic = SakaiSemanticColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Drawer(
      backgroundColor: scheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.primary, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    // Was `surface` + hardcoded white text: invisible in light
                    // mode. Both roles now track brightness together.
                    backgroundColor: scheme.surfaceContainerHighest,
                    child: Text(
                      _initialsOf(driverName),
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        driverName,
                        style: textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'GoRide Navigator',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerTile(
                  icon: Icons.dashboard_rounded,
                  title: 'Console Dashboard',
                  selected: true,
                  onTap: () => Navigator.pop(context),
                ),
                if (state.activeRide != null)
                  _buildDrawerTile(
                    icon: Icons.directions_car,
                    title: 'Active Ride',
                    textColor: scheme.primary,
                    iconColor: scheme.primary,
                    onTap: () {
                      Navigator.pop(context);
                      if (context.mounted && state.activeRide != null) {
                        context.go(Routes.rideActive, extra: state.activeRide);
                      }
                    },
                  ),
                Divider(color: scheme.outlineVariant),
                _buildDrawerTile(
                  icon: Icons.payments_rounded,
                  title: 'Earnings',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(Routes.earnings);
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.description_rounded,
                  title: 'My Documents',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(Routes.documents);
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.history_rounded,
                  title: 'Trip History',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(Routes.tripHistory);
                  },
                ),
                Divider(color: scheme.outlineVariant),
                _buildDrawerTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(Routes.profile);
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(Routes.settings);
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(Routes.notifications);
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Support',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(Routes.support);
                  },
                ),
                Divider(color: scheme.outlineVariant),
                _buildDrawerTile(
                  icon: Icons.logout_rounded,
                  title: 'Log Out',
                  iconColor: semantic.danger,
                  textColor: semantic.danger,
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
        ],
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    bool selected = false,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    // `_buildDrawerTile` takes no ColorScheme param, but it is a State method,
    // so `this.context` is in scope — no threading through 10 call sites needed.
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(
        icon,
        color: selected
            ? scheme.primary
            : (iconColor ?? scheme.onSurfaceVariant),
      ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(
          color: selected
              ? scheme.primary
              : (textColor ?? scheme.onSurface),
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: selected,
      selectedTileColor: SakaiSemanticColors.of(context).primarySubtle,
      onTap: onTap,
    );
  }

  String _formatRideStatus(RideStatus status) {
    switch (status) {
      case RideStatus.created:
        return 'Created';
      case RideStatus.requested:
        return 'Requested';
      case RideStatus.accepted:
        return 'Accepted - En Route';
      case RideStatus.arrived:
        return 'Arrived at Pickup';
      case RideStatus.inProgress:
        return 'In Progress';
      case RideStatus.paymentPending:
        return 'Payment Pending';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
    }
    return status.toString().split('.').last;
  }
}

// -------------------------------------------------------------
// Pulsing Indicator Dot Stateful Widget for Premium Live Status
// -------------------------------------------------------------
class PulsingIndicatorDot extends StatefulWidget {
  const PulsingIndicatorDot({super.key, required this.color});

  final Color color;

  @override
  State<PulsingIndicatorDot> createState() => _PulsingIndicatorDotState();
}

class _PulsingIndicatorDotState extends State<PulsingIndicatorDot> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: _pulseAnimation.value * 2,
              height: _pulseAnimation.value * 2,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: (1.0 - _pulseController.value) * 0.5),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}
