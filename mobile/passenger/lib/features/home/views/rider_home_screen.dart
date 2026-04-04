import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart' hide LatLng;

import '../../../app/routes.dart';
import 'activity_screen.dart';

import 'destination_sheet.dart';
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

  // Map & Ride Logic State
  GoogleMapController? _mapController;
  static const _defaultLatLng = LatLng(14.5995, 120.9842); // Manila fallback

  @override
  void initState() {
    super.initState();
    // Schedule initLocation after first build to read provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).initLocation();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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
        ref.read(homeNotifierProvider.notifier).clearError();
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

  Future<void> _openLocationSearchSheet(LocationSearchMode mode) async {
    final notifier = ref.read(homeNotifierProvider.notifier);
    await showLocationSearchSheet(
      context,
      mode: mode,
      onLocationConfirmed: (loc) {
        if (mode == LocationSearchMode.pickup) {
          notifier.setPickup(loc);
        } else {
          notifier.setDestination(loc);
        }
      },
    );
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
      bottomNavigationBar: _buildBottomNav(scheme),
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
        _buildDraggableSheet(context, scheme),
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
              child: IconButton(
                icon: Icon(Icons.menu, color: scheme.onSurface),
                onPressed: () {},
              ),
            ),
            CircleAvatar(
              backgroundColor: scheme.surface.withAlpha(235),
              child: IconButton(
                icon: Icon(Icons.logout, color: scheme.onSurface),
                onPressed: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Navigation & Bottom Sheets ---

  Widget _buildBottomNav(ColorScheme scheme) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Activity',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildDraggableSheet(BuildContext context, ColorScheme scheme) {
    final tokens = SakaiDesignTokens.of(context);
    final isIdle = ref.watch(homeNotifierProvider).status == HomeStatus.idle;

    return DraggableScrollableSheet(
      initialChildSize: isIdle ? 0.22 : 0.45,
      minChildSize: 0.22,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.22, 0.45, 0.9],
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
    return Column(
      children: [
        InkWell(
          onTap: () => _openLocationSearchSheet(LocationSearchMode.destination),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(tokens.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: scheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Saan kayo pupunta?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Recent Destinations Mockup
        _buildRecentItem(
          Icons.home,
          'Home',
          'San Lorenzo, Makati',
          scheme,
          tokens,
        ),
        _buildRecentItem(
          Icons.work,
          'Work',
          'Ayala Avenue, Makati',
          scheme,
          tokens,
        ),
      ],
    );
  }

  Widget _buildRecentItem(
    IconData icon,
    String title,
    String subtitle,
    ColorScheme scheme,
    SakaiDesignTokens tokens,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                Icon(Icons.my_location, size: 16, color: scheme.primary),
                Container(width: 1, height: 24, color: scheme.outlineVariant),
                Icon(Icons.place, size: 16, color: scheme.error),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.watch(homeNotifierProvider).pickup?.address ??
                        "Locating...",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
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
        Text('Available Rides', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        // Ride Options Mockup
        _buildRideOption(
          'SakAI Eco',
          '4-seat economy',
          '₱120.00',
          Icons.directions_car,
          scheme,
          tokens,
          selected: true,
        ),
        _buildRideOption(
          'SakAI Premium',
          'Luxury sedan',
          '₱250.00',
          Icons.directions_car_filled,
          scheme,
          tokens,
        ),
        _buildRideOption(
          'SakAI Moto',
          'Fastest through traffic',
          '₱65.00',
          Icons.motorcycle,
          scheme,
          tokens,
        ),
        const SizedBox(height: 24),
        SakaiPrimaryButton(
          label: 'I-request ang SakAI Eco',
          onPressed: ref.watch(homeNotifierProvider).canRequest
              ? () => ref.read(homeNotifierProvider.notifier).requestRide()
              : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

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
