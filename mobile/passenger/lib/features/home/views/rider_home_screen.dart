import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide LatLng, NearbyDriver, ServiceArea;

import '../../../app/e2e_mode_stub.dart'
    if (dart.library.js_interop) '../../../app/e2e_mode_web.dart';
import '../../../app/routes.dart';
import 'activity_screen.dart';
import 'destination_sheet.dart';

import '../repositories/geocoding_service.dart';
import '../repositories/service_area_repository.dart';
import '../models/service_area.dart';
import '../models/nearby_driver.dart';
import '../models/ride_type_option.dart';
import '../view_models/home_notifier.dart';
import 'profile_screen.dart';
import '../../../app/providers.dart';

/// Full-screen Google Map home screen for ride requesting (REQ-3.2.4).
class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  // Navigation State
  int _currentIndex = 0;

  // Sheet & Search State
  final _sheetController = DraggableScrollableController();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _isSearching = false;
  bool _isLoadingSuggestions = false;
  LocationSearchMode? _searchMode;
  List<String> _suggestions = [];
  List<NearbyDriver> _nearbyDrivers = [];
  Timer? _debounce;
  Timer? _driverTimer;
  final _sheetKey = GlobalKey();

  // Map & Ride Logic State
  GoogleMapController? _mapController;
  List<ServiceArea> _serviceAreas = [];
  static const _defaultLatLng = LatLng(
    0.0,
    0.0,
  ); // Uses GPS location at runtime

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onSearchFocusChange);
    // Schedule initLocation after first build to read provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).initLocation();
      _fetchServiceAreas();
    });
  }

  Future<void> _fetchServiceAreas() async {
    final authInterceptor = ref.read(authInterceptorProvider);
    final areas = await ServiceAreaRepository(
      authInterceptor: authInterceptor,
    ).getServiceAreas();
    if (mounted) {
      setState(() => _serviceAreas = areas);

      // If user location is not yet available, center on the first service area
      final currentPos = ref.read(homeNotifierProvider).currentLatLng;
      if (currentPos == null && areas.isNotEmpty && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(areas.first.polygon.first, 12),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _sheetController.dispose();
    _searchController.dispose();
    _searchFocus.removeListener(_onSearchFocusChange);
    _searchFocus.dispose();
    _debounce?.cancel();
    _driverTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (val.trim().isEmpty) {
        setState(() {
          _suggestions = [];
          _isLoadingSuggestions = false;
        });
        return;
      }

      setState(() => _isLoadingSuggestions = true);
      try {
        // No service area biasing — search globally
        final results = await GeocodingService().getSuggestions(val);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isLoadingSuggestions = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _isLoadingSuggestions = false);
        }
      }
    });
  }

  // ignore: unused_element
  ServiceArea? _getNearestAreaBias(LatLng? currentLoc) {
    if (_serviceAreas.isEmpty) return null;
    if (currentLoc == null) return _serviceAreas.first;

    ServiceArea? nearest;
    double minDistance = double.infinity;

    for (final area in _serviceAreas) {
      final distance = _calculateDistance(currentLoc, area.polygon.first);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = area;
      }
    }
    return nearest;
  }

  // ignore: unused_element
  bool _isInsideArea(LatLng? loc, ServiceArea area) {
    if (loc == null) return false;
    return area.contains(loc);
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    // Basic approximate distance for biasing logic
    // In a real app, use a proper Vincenty/Haversine or the 'geolocator' package helper
    return (p1.latitude - p2.latitude).abs() +
        (p1.longitude - p2.longitude).abs();
  }

  void _onSearchFocusChange() {
    if (_searchFocus.hasFocus && !_isSearching) {
      setState(() => _isSearching = true);
      _sheetController.animateTo(
        0.9,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _listenToState() {
    ref.listen<HomeState>(homeNotifierProvider, (previous, next) {
      if (next.currentLatLng != null &&
          previous?.currentLatLng == null &&
          _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(next.currentLatLng!, 15),
        );
      }

      // Sync nearby drivers from notifier (single source of truth)
      if (next.nearbyDrivers != previous?.nearbyDrivers && mounted) {
        setState(() {
          _nearbyDrivers = next.nearbyDrivers;
        });
      }

      if (next.createdRide != null &&
          next.createdRide != previous?.createdRide &&
          mounted) {
        final ride = next.createdRide!;
        context.push(Routes.rideWaiting, extra: ride.id);
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        // Defer clearError to avoid mutating provider during build phase.
        Future(() {
          ref.read(homeNotifierProvider.notifier).clearError();
        });
      }
    });
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'SakAI · Home';
      case 1:
        return 'Activity';
      case 2:
        return 'Profile';
      default:
        return 'SakAI';
    }
  }

  Future<void> _logout() async {
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

    // Disconnect WebSocket on logout.
    await ref.read(wsConnectionProvider).disconnect();

    await tokenStorage.clear();
    ref.read(authStateProvider.notifier).markUnauthenticated(forceLogin: true);
  }

  @override
  Widget build(BuildContext context) {
    _listenToState();
    final scheme = Theme.of(context).colorScheme;

    // Determine the main body based on navigation index
    Widget body;
    switch (_currentIndex) {
      case 1:
        body = const ActivityScreen();
        break;
      case 2:
        body = ProfileScreen(onSignOut: _logout);
        break;
      case 0:
      default:
        body = _buildMapHomeStack(context, scheme);
        break;
    }

    // Using a standard Scaffold to handle the Stack properly
    return Scaffold(
      appBar: _currentIndex != 0
          ? AppBar(title: Text(_getTitle(_currentIndex)))
          : null, // Map handles its own top bar
      body: body,
      drawer: _buildDrawer(context, scheme),
    );
  }

  /// The original Map-based UI for the Home tab
  Widget _buildMapHomeStack(BuildContext context, ColorScheme scheme) {
    return Stack(
      children: [
        _buildMap(scheme),
        _buildTopBar(context, scheme),
        if (ref.watch(homeNotifierProvider).status == HomeStatus.idle)
          Positioned(
            right: 16,
            bottom: 320, // Adjusted to sit above the bottom card
            child: FloatingActionButton.small(
              onPressed: () {
                if (ref.watch(homeNotifierProvider).currentLatLng != null &&
                    _mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      ref.watch(homeNotifierProvider).currentLatLng!,
                      15,
                    ),
                  );
                }
              },
              backgroundColor: scheme.surface.withAlpha(230),
              child: Icon(Icons.my_location, color: scheme.onSurface),
            ),
          ),
        Positioned.fill(child: _buildDraggableSheet(context, scheme)),
        if (ref.watch(homeNotifierProvider).status == HomeStatus.locating)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x88000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  // --- UI Helpers (Map, TopBar, Cards) ---

  Widget _buildMap(ColorScheme scheme) {
    // Web E2E bypass: Google Maps JS SDK is not loaded in web/index.html,
    // so the plugin's `_gmapTypeIDForPluginType` null-checks crash on render.
    // Render an inert placeholder so post-login flows can proceed.
    if (kIsWeb && isE2EMode()) {
      return Container(
        key: const ValueKey('e2e-map-placeholder'),
        color: scheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Text(
          'Map (E2E placeholder)',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }
    final center =
        ref.watch(homeNotifierProvider).currentLatLng ?? _defaultLatLng;
    final markers = <Marker>{
      if (ref.watch(homeNotifierProvider).currentLatLng != null)
        Marker(
          markerId: const MarkerId('pickup'),
          position: ref.watch(homeNotifierProvider).currentLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      if (ref.watch(homeNotifierProvider).destination != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            ref.watch(homeNotifierProvider).destination!.lat,
            ref.watch(homeNotifierProvider).destination!.lng,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      ..._nearbyDrivers.map(
        (d) => Marker(
          markerId: MarkerId('driver_${d.id}'),
          position: d.location,
          rotation: d.heading,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            d.vehicleType == VehicleType.car
                ? BitmapDescriptor.hueBlue
                : d.vehicleType == VehicleType.motorcycle
                ? BitmapDescriptor.hueYellow
                : BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(title: d.name),
        ),
      ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: center, zoom: 14),
      onMapCreated: (c) => _mapController = c,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: markers,
    );
  }

  Widget _buildTopBar(BuildContext context, ColorScheme scheme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: scheme.surface.withAlpha(235),
              child: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: scheme.onSurface),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Navigation & Bottom Sheets ---

  Widget _buildDrawer(BuildContext context, ColorScheme scheme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primary),
            child: Text(
              'SakAI Menu',
              style: TextStyle(color: scheme.onPrimary, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(
              _currentIndex == 0 ? Icons.home : Icons.home_outlined,
            ),
            title: const Text('Home'),
            selected: _currentIndex == 0,
            onTap: () {
              setState(() => _currentIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              _currentIndex == 1 ? Icons.history : Icons.history_outlined,
            ),
            title: const Text('Activity'),
            selected: _currentIndex == 1,
            onTap: () {
              setState(() => _currentIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              _currentIndex == 2 ? Icons.person : Icons.person_outline,
            ),
            title: const Text('Profile'),
            selected: _currentIndex == 2,
            onTap: () {
              setState(() => _currentIndex = 2);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet(BuildContext context, ColorScheme scheme) {
    final tokens = SakaiDesignTokens.of(context);
    final isIdle = ref.watch(homeNotifierProvider).status == HomeStatus.idle;

    return DraggableScrollableSheet(
      key: _sheetKey,
      controller: _sheetController,
      initialChildSize: isIdle ? (_currentIndex == 0 ? 0.35 : 0.22) : 0.45,
      minChildSize: 0.22,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.22, 0.35, 0.45, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: tokens.elevationLg,
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Drag Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              if (isIdle)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
                  sliver: SliverToBoxAdapter(
                    child: _buildIdleContent(context, scheme, tokens),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
                  sliver: SliverToBoxAdapter(
                    child: _buildActiveContent(context, scheme, tokens),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIdleContent(
    BuildContext context,
    ColorScheme scheme,
    SakaiDesignTokens tokens,
  ) {
    if (_isSearching) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                _searchMode == LocationSearchMode.pickup
                    ? 'Where from?'
                    : 'Where to?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _closeLocationSearch,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchField(context, scheme, tokens),
          if (_isLoadingSuggestions)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else
            const SizedBox(height: 16),

          if (_suggestions.isNotEmpty) ...[
            Text(
              'Suggestions',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            // Real Suggestions List
            ..._suggestions.map(
              (s) => ListTile(
                leading: Icon(
                  Icons.place_outlined,
                  size: 20,
                  color: scheme.outline,
                ),
                title: Text(s, style: const TextStyle(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onTap: () => _handleSuggestionTapped(s),
              ),
            ),
          ] else if (!_isLoadingSuggestions) ...[
            // No results found
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: scheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different or more specific address',
                    style: TextStyle(color: scheme.outline, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  SakaiPrimaryButton(
                    label: 'Confirm "${_searchController.text}"',
                    onPressed: () =>
                        _handleSuggestionTapped(_searchController.text),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              setState(() => _isSearching = false);
              _searchFocus.unfocus();
              _searchController.clear();
              _sheetController.animateTo(
                0.35,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            icon: const Icon(Icons.close),
            label: const Text('Cancel Search'),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Pickup and destination display
        _buildLocationRow(context, scheme, tokens),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLocationRow(
    BuildContext context,
    ColorScheme scheme,
    SakaiDesignTokens tokens,
  ) {
    final pickup = ref.watch(homeNotifierProvider).pickup;
    final destination = ref.watch(homeNotifierProvider).destination;

    return Column(
      children: [
        // Pickup field
        _buildLocationTile(
          icon: Icons.my_location,
          label: pickup?.address ?? 'Tap to set pickup',
          onTap: () => _openLocationSearch(LocationSearchMode.pickup),
          scheme: scheme,
        ),
        const SizedBox(height: 12),
        // Destination field
        _buildLocationTile(
          icon: Icons.place,
          label: destination?.address ?? 'Where to?',
          onTap: () => _openLocationSearch(LocationSearchMode.destination),
          scheme: scheme,
        ),
      ],
    );
  }

  Widget _buildLocationTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme scheme,
  }) {
    final isPlaceholder = label.contains('Tap') || label.contains('Where');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isPlaceholder
                      ? scheme.onSurfaceVariant
                      : scheme.onSurface,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.outline, size: 20),
          ],
        ),
      ),
    );
  }

  void _handleSuggestionTapped(String address) async {
    final notifier = ref.read(homeNotifierProvider.notifier);
    final mode = _searchMode; // Save before clearing
    setState(() {
      _isSearching = false;
      _suggestions = [];
      _searchMode = null;
      _searchController.text = address;
    });
    _searchFocus.unfocus();
    _sheetController.animateTo(
      0.35,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    try {
      final loc = await GeocodingService().geocode(address);
      if (mounted) {
        if (mode == LocationSearchMode.pickup) {
          notifier.setPickup(loc);
        } else {
          notifier.setDestination(loc);
          // setDestination() auto-starts ride type polling
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find that location.')),
        );
      }
    }
  }

  void _openLocationSearch(LocationSearchMode mode) {
    setState(() {
      _searchMode = mode;
      _isSearching = true;
      _searchController.clear();
      _suggestions = [];
    });
    _sheetController.animateTo(
      0.9,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _searchFocus.requestFocus();
  }

  void _closeLocationSearch() {
    setState(() {
      _searchMode = null;
      _isSearching = false;
      _suggestions = [];
      _searchController.clear();
    });
    _searchFocus.unfocus();
    _sheetController.animateTo(
      0.35,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    ColorScheme scheme,
    SakaiDesignTokens tokens,
  ) {
    return SakaiTextField(
      controller: _searchController,
      focusNode: _searchFocus,
      label: 'Where to?',
      hint: 'Enter destination...',
      prefixIcon: Icon(Icons.search, color: scheme.primary),
      textInputAction: TextInputAction.search,
      onChanged: _onSearchChanged,
      suffixIcon: _searchController.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _suggestions = [];
                });
              },
            )
          : null,
    );
  }

  // ignore: unused_element
  Widget _buildRecentItem(
    IconData icon,
    String title,
    String subtitle,
    ColorScheme scheme,
    SakaiDesignTokens tokens, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 4),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.surfaceContainerHighest,
              child: Icon(icon, size: 20, color: scheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveContent(
    BuildContext context,
    ColorScheme scheme,
    SakaiDesignTokens tokens,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () => _openLocationSearch(LocationSearchMode.pickup),
                  child: Icon(
                    Icons.my_location,
                    size: 16,
                    color: scheme.primary,
                  ),
                ),
                Container(width: 1, height: 24, color: scheme.outlineVariant),
                Icon(Icons.place, size: 16, color: scheme.error),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _openLocationSearch(LocationSearchMode.pickup),
                    child: Text(
                      ref.watch(homeNotifierProvider).pickup?.address ??
                          "Tap to set pickup",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: ref.watch(homeNotifierProvider).pickup == null
                            ? scheme.primary
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ref.watch(homeNotifierProvider).destination?.address ??
                        "Select destination",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  ref.read(homeNotifierProvider.notifier).clearDestination(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Divider(height: 32),
        // Real-time ride type cards with live driver counts
        _buildRideTypeCards(context, scheme, tokens),
        const SizedBox(height: 16),
        // Single-tap Request Ride button
        SakaiPrimaryButton(
          label: _buildRequestButtonLabel(),
          onPressed: _canRequestRide() ? _handleRequestRide : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Builds inline ride type cards with live driver counts.
  Widget _buildRideTypeCards(
    BuildContext context,
    ColorScheme scheme,
    SakaiDesignTokens tokens,
  ) {
    final options = ref.watch(homeNotifierProvider).rideTypeOptions;
    final selectedType = ref.watch(homeNotifierProvider).selectedRideType;
    final notifier = ref.read(homeNotifierProvider.notifier);

    if (options.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Checking nearby drivers…',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your ride',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...options.map(
          (opt) => _buildRideTypeCard(
            opt,
            selectedType == opt.type,
            scheme,
            tokens,
            () => notifier.setSelectedRideType(opt.type),
          ),
        ),
      ],
    );
  }

  Widget _buildRideTypeCard(
    RideTypeOption option,
    bool selected,
    ColorScheme scheme,
    SakaiDesignTokens tokens,
    VoidCallback onTap,
  ) {
    final typeLabels = {
      VehicleType.motorcycle: 'Moto',
      VehicleType.car: 'Car',
      VehicleType.tricycle: 'Tricycle',
    };
    final typeDesc = {
      VehicleType.motorcycle: 'Fastest through traffic',
      VehicleType.car: 'Comfortable, up to 4 seats',
      VehicleType.tricycle: 'Budget-friendly local rides',
    };

    return InkWell(
      onTap: option.isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.type.icon,
              size: 28,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeLabels[option.type] ?? option.type.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    typeDesc[option.type] ?? '',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₱${option.estimatedFare.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  option.isAvailable
                      ? '${option.availableDrivers} nearby'
                      : 'None available',
                  style: TextStyle(
                    color: option.isAvailable
                        ? scheme.onSurfaceVariant
                        : scheme.error,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildRequestButtonLabel() {
    final state = ref.watch(homeNotifierProvider);
    if (state.status == HomeStatus.requesting) return 'Requesting…';
    if (state.selectedRideType != null) {
      return 'Request ${state.selectedRideType!.displayName}';
    }
    return 'Request Ride';
  }

  bool _canRequestRide() {
    return ref.watch(homeNotifierProvider).canRequest ||
        (ref.watch(homeNotifierProvider).destination != null &&
            ref.watch(homeNotifierProvider).rideTypeOptions.isNotEmpty);
  }

  void _handleRequestRide() {
    final notifier = ref.read(homeNotifierProvider.notifier);
    final state = ref.read(homeNotifierProvider);

    // If no type selected yet, pick the one with most drivers
    if (state.selectedRideType == null && state.rideTypeOptions.isNotEmpty) {
      final best = state.rideTypeOptions
          .where((o) => o.isAvailable)
          .fold<RideTypeOption?>(
            null,
            (prev, opt) =>
                prev == null || opt.availableDrivers > prev.availableDrivers
                ? opt
                : prev,
          );
      if (best != null) {
        notifier.setSelectedRideType(best.type);
      }
    }

    notifier.requestRide();
  }

  // ignore: unused_element
  Widget _buildRideOption(
    String name,
    String type,
    String price,
    IconData icon,
    ColorScheme scheme,
    SakaiDesignTokens tokens, {
    bool selected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  type,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
