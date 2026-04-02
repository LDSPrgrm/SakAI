import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart' hide LatLng;

import '../../domain/auth_session.dart';
import '../../domain/ride_repository.dart';
import '../ride/waiting_screen.dart';
import 'activity_screen.dart';
import 'destination_sheet.dart';
import 'home_tab.dart'; // Note: You might not need HomeTab if the Map logic is now here
import 'home_view_model.dart';
import 'profile_screen.dart';

/// Full-screen Google Map home screen for ride requesting (REQ-3.2.4).
class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({
    super.key,
    required this.session,
    required this.rideRepository,
    required this.onSignOut,
  });

  final AuthSession session;
  final RideRepository rideRepository;
  final VoidCallback onSignOut;

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  // Navigation State
  int _currentIndex = 0;

  // Map & Ride Logic State
  late final HomeViewModel _vm;
  GoogleMapController? _mapController;
  static const _defaultLatLng = LatLng(14.5995, 120.9842); // Manila fallback

  @override
  void initState() {
    super.initState();
    _vm = HomeViewModel(widget.rideRepository);
    _vm.addListener(_onVmChanged);
    _vm.initLocation();
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onVmChanged() {
    final pos = _vm.currentLatLng;
    if (pos != null && _mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));
    }

    if (_vm.createdRide != null && mounted) {
      final ride = _vm.createdRide!;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WaitingScreen(ride: ride, rideRepository: widget.rideRepository),
        ),
      );
    }

    if (_vm.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(_vm.errorMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      _vm.clearError();
    }
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'SakAI · Home';
      case 1: return 'Activity';
      case 2: return 'Profile';
      default: return 'SakAI';
    }
  }

  Future<void> _openLocationSearchSheet(LocationSearchMode mode) async {
    await showLocationSearchSheet(
      context,
      mode: mode,
      onLocationConfirmed: (loc) {
        if (mode == LocationSearchMode.pickup) {
          _vm.setPickup(loc);
        } else {
          _vm.setDestination(loc);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Determine the main body based on navigation index
    Widget body;
    switch (_currentIndex) {
      case 1:
        body = const ActivityScreen();
        break;
      case 2:
        body = ProfileScreen(onSignOut: widget.onSignOut);
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
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Stack(
          children: [
            _buildMap(scheme),
            _buildTopBar(context, scheme),
            if (_vm.state == HomeState.idle)
              Positioned(
                right: 16,
                bottom: 320, // Adjusted to sit above the bottom card
                child: FloatingActionButton.small(
                  onPressed: () {
                    if (_vm.currentLatLng != null && _mapController != null) {
                      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_vm.currentLatLng!, 15));
                    }
                  },
                  backgroundColor: scheme.surface.withAlpha(230),
                  child: Icon(Icons.my_location, color: scheme.onSurface),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _vm.state == HomeState.idle
                  ? _buildIdleBottomCard(context, scheme)
                  : _buildActiveBottomCard(context, scheme),
            ),
            if (_vm.state == HomeState.locating)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x88000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }

  // --- UI Helpers (Map, TopBar, Cards) ---

  Widget _buildMap(ColorScheme scheme) {
    final center = _vm.currentLatLng ?? _defaultLatLng;
    final markers = <Marker>{
      if (_vm.currentLatLng != null)
        Marker(
          markerId: const MarkerId('pickup'),
          position: _vm.currentLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      if (_vm.destination != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(_vm.destination!.lat, _vm.destination!.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
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
                onPressed: widget.onSignOut,
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
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Activity'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  Widget _buildIdleBottomCard(BuildContext context, ColorScheme scheme) {
    final tokens = SakaiDesignTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(tokens.spaceLg, tokens.spaceMd, tokens.spaceLg, tokens.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _openLocationSearchSheet(LocationSearchMode.destination),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: scheme.primary),
                  const SizedBox(width: 12),
                  const Text('Saan kayo pupunta?'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBottomCard(BuildContext context, ColorScheme scheme) {
    final tokens = SakaiDesignTokens.of(context);
    return Container(
      color: scheme.surface,
      padding: EdgeInsets.all(tokens.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pickup: ${_vm.pickup?.address ?? "Locating..."}'),
          Text('Dropoff: ${_vm.destination?.address ?? "Select destination"}'),
          const SizedBox(height: 16),
          SakaiPrimaryButton(
            label: 'Request Ride',
            onPressed: _vm.canRequest ? () => _vm.requestRide() : null,
          ),
        ],
      ),
    );
  }
}