import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide LatLng, NearbyDriver, ServiceArea;

import '../../ride_history/view_models/ride_history_list_view_model.dart';
import '../../../app/providers.dart';
import '../models/location_search_mode.dart';
import '../repositories/geocoding_service.dart';
import '../view_models/recent_locations_notifier.dart';



// ─────────────────────────────────────────────────────────────────────────────
// Location Picker Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Full-screen location picker with:
///   • Live autocomplete search
///   • Suggested transit points
///   • "Pin on Map" option
///
/// Returns a [RideLocation] via [Navigator.pop] or null on cancel.
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key, required this.mode});

  final LocationSearchMode mode;

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  List<String> _autocompleteResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  bool _isLocating = false;
  Timer? _debounce;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    _searchFocus.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();

      final historyState = ref.read(rideHistoryListNotifierProvider);
      if (historyState.status == RideHistoryStatus.initial) {
        ref.read(rideHistoryListNotifierProvider.notifier).loadHistory();
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchController.dispose();
    _searchFocus
      ..removeListener(_onFocusChange)
      ..dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _autocompleteResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 380), () async {
      setState(() => _isLoading = true);
      final results = await ref
          .read(geocodingServiceProvider)
          .getSuggestions(value);
      if (mounted) {
        setState(() {
          _autocompleteResults = results;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _confirmAddress(String address) async {
    setState(() => _isLoading = true);
    try {
      final loc = await ref.read(geocodingServiceProvider).geocode(address);
      if (mounted) {
        ref
            .read(recentLocationsNotifierProvider(widget.mode).notifier)
            .addLocation(loc);
        Navigator.of(context).pop(loc);
      }
    } catch (e) {
      if (mounted) {
        SakaiSnackBar.error(context, 'Could not resolve address. Try again.');
        setState(() => _isLoading = false);
      }
    }
  }



  void _openMapPinPicker() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<RideLocation>(
            builder: (_) => _MapPinPickerScreen(mode: widget.mode),
          ),
        )
        .then((loc) {
          if (loc != null && mounted) {
            ref
                .read(recentLocationsNotifierProvider(widget.mode).notifier)
                .addLocation(loc);
            Navigator.of(context).pop(loc);
          }
        });
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          SakaiSnackBar.error(
            context,
            'Location permission denied. Enable it in Settings.',
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (!mounted) return;

      // Reverse-geocode to a human-readable address.
      final loc = await ref
          .read(geocodingServiceProvider)
          .reverseGeocode(pos.latitude, pos.longitude);

      if (mounted) {
        ref
            .read(recentLocationsNotifierProvider(widget.mode).notifier)
            .addLocation(loc);
        Navigator.of(context).pop(loc);
      }
    } catch (_) {
      if (mounted) {
        SakaiSnackBar.error(
          context,
          'Could not get your current location. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.mode == LocationSearchMode.pickup
        ? 'Select Pickup Location'
        : 'Select Destination';

    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: Column(
          children: [
            _buildAppBar(context, scheme, isDark, title),
            _buildSearchBar(scheme, isDark),
            if (_isLoading)
              LinearProgressIndicator(
                color: scheme.primary,
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
                minHeight: 2,
              ),
            Expanded(
              child: _isSearching
                  ? _buildAutocompleteList(scheme)
                  : _buildDefaultList(scheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
    String title,
  ) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: scheme.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme scheme, bool isDark) {
    final hasText = _searchController.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? scheme.surfaceContainerHighest.withValues(alpha: 0.7)
              : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _searchFocus.hasFocus
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.5),
            width: _searchFocus.hasFocus ? 1.5 : 1,
          ),
          boxShadow: _searchFocus.hasFocus
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: _onSearchChanged,
          style: TextStyle(
            fontSize: 15,
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search address, building, station…',
            hintStyle: TextStyle(
              fontSize: 14,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _searchFocus.hasFocus
                  ? scheme.primary
                  : scheme.onSurfaceVariant,
              size: 22,
            ),
            suffixIcon: hasText
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultList(ColorScheme scheme) {
    final recentLocations = ref.watch(recentLocationsNotifierProvider(widget.mode));
    final isPickup = widget.mode == LocationSearchMode.pickup;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      children: [
        // ── Current Location (pickup only) ────────────────────────
        if (isPickup) ...[
          _buildCurrentLocationTile(scheme),
          const SizedBox(height: 4),
        ],
        // ── Pin on Map ────────────────────────────────────────────
        _buildPinOnMapTile(scheme),

        if (recentLocations.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              isPickup ? 'RECENT PICKUPS' : 'RECENT DESTINATIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
          ...recentLocations
              .take(6)
              .map((loc) => _buildRecentLocationTile(loc, scheme)),
        ],
      ],
    );
  }

  Widget _buildRecentLocationTile(RideLocation loc, ColorScheme scheme) {
    final commaIdx = loc.address.indexOf(',');
    final String name;
    final String address;
    if (commaIdx != -1) {
      name = loc.address.substring(0, commaIdx).trim();
      address = loc.address.substring(commaIdx + 1).trim();
    } else {
      name = loc.address.trim();
      address = '';
    }

    final isPickup = widget.mode == LocationSearchMode.pickup;
    final subtitle = isPickup ? 'Recent Pickup' : 'Recent Destination';
    final iconColor = scheme.onSurfaceVariant;

    return InkWell(
      onTap: () {
        ref
            .read(recentLocationsNotifierProvider(widget.mode).notifier)
            .addLocation(loc);
        Navigator.of(context).pop(loc);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.isEmpty ? subtitle : '$subtitle · $address',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              onPressed: () {
                ref
                    .read(recentLocationsNotifierProvider(widget.mode).notifier)
                    .removeLocation(loc);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationTile(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: _isLocating ? null : _useCurrentLocation,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: _isLocating
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.my_location_rounded,
                        color: scheme.primary,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use Current Location',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isLocating
                          ? 'Getting your location…'
                          : 'Set pickup to your current GPS position',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isLocating)
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinOnMapTile(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: _openMapPinPicker,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pin_drop_rounded,
                  color: scheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pin on Map',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap anywhere on the map to set location',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildAutocompleteList(ColorScheme scheme) {
    if (_autocompleteResults.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No results found',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 32),
      itemCount: _autocompleteResults.length,
      itemBuilder: (context, i) {
        final address = _autocompleteResults[i];
        return InkWell(
          onTap: () => _confirmAddress(address),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.place_outlined,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map Pin Picker (inline full-screen map overlay)
// ─────────────────────────────────────────────────────────────────────────────

class _MapPinPickerScreen extends StatefulWidget {
  const _MapPinPickerScreen({required this.mode});

  final LocationSearchMode mode;

  @override
  State<_MapPinPickerScreen> createState() => _MapPinPickerScreenState();
}

class _MapPinPickerScreenState extends State<_MapPinPickerScreen> {
  static const _defaultPosition = LatLng(14.5995, 120.9842); // Manila fallback
  GoogleMapController? _mapController;
  LatLng _pinnedLocation = _defaultPosition;
  String? _resolvedAddress;
  bool _resolving = false;
  bool _locating = false;
  // True while the very first location fetch is running — no pin shown yet.
  bool _initializing = true;
  final _geocodingService = GeocodingService();

  @override
  void initState() {
    super.initState();
    _fetchInitialLocation();
  }

  /// Silently resolves current location on open. If permission is denied or
  /// location fails, simply stays on the Manila fallback with no error shown.
  Future<void> _fetchInitialLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        // Permission unavailable — fall back to Manila.
        if (mounted) setState(() => _initializing = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (!mounted) return;
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _pinnedLocation = latLng;
        _initializing = false;
      });
      // Animate camera — works whether map is ready or not (controller may
      // already be set if the map rendered before GPS resolved).
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16),
        ),
      );
      _resolveAddress(latLng);
    } catch (_) {
      // Timeout or any other error — fall back to Manila silently.
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _resolveAddress(LatLng latLng) async {
    setState(() => _resolving = true);
    try {
      final loc = await _geocodingService.reverseGeocode(
        latLng.latitude,
        latLng.longitude,
      );
      if (mounted) {
        setState(() {
          _resolvedAddress = loc.address;
          _resolving = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _resolvedAddress =
              '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}';
          _resolving = false;
        });
      }
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _pinnedLocation = position;
      _resolvedAddress = null;
    });
    _resolveAddress(position);
  }

  Future<void> _goToCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      // Check / request permission without throwing.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission denied. Enable it in Settings.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final latLng = LatLng(pos.latitude, pos.longitude);
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16),
        ),
      );
      _onMapTap(latLng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get current location. Try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canConfirm = _resolvedAddress != null && !_resolving;

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _defaultPosition,
              zoom: 14,
            ),
            onMapCreated: (c) {
              _mapController = c;
              // If GPS resolved before the map rendered, animate now.
              if (!_initializing) {
                c.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _pinnedLocation, zoom: 16),
                  ),
                );
              }
            },
            onTap: _onMapTap,
            // Don't show the marker until we have a real location.
            markers: _initializing
                ? const {}
                : {
                    Marker(
                      markerId: const MarkerId('pin'),
                      position: _pinnedLocation,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                    ),
                  },
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // we supply our own styled button
            zoomControlsEnabled: false,
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                child: Row(
                  children: [
                    _glassButton(
                      child: Icon(Icons.arrow_back, color: scheme.onSurface),
                      onTap: () => Navigator.of(context).pop(),
                      scheme: scheme,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tap on the map to pin your location',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Current Location Button — right side, below top bar
          Positioned(
            right: 16,
            bottom: 220,
            child: _CurrentLocationButton(
              loading: _locating,
              onTap: _goToCurrentLocation,
            ),
          ),

          // Bottom Confirm Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.pin_drop_rounded,
                            color: scheme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _resolving
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Resolving address…',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  _resolvedAddress ??
                                      'Tap on the map to drop a pin',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _resolvedAddress != null
                                        ? scheme.onSurface
                                        : scheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: canConfirm
                          ? () => Navigator.of(context).pop(
                              RideLocation(
                                lat: _pinnedLocation.latitude,
                                lng: _pinnedLocation.longitude,
                                address: _resolvedAddress!,
                              ),
                            )
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: canConfirm
                              ? scheme.primary
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: canConfirm
                              ? [
                                  BoxShadow(
                                    color: scheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              color: canConfirm
                                  ? Colors.black
                                  : scheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Confirm Location',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: canConfirm
                                    ? Colors.black
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _glassButton({
    required Widget child,
    required VoidCallback onTap,
    required ColorScheme scheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Current Location Button widget
// ─────────────────────────────────────────────────────────────────────────────

class _CurrentLocationButton extends StatelessWidget {
  const _CurrentLocationButton({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: scheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: scheme.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: loading
            ? Padding(
                padding: const EdgeInsets.all(13),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              )
            : Icon(
                Icons.my_location_rounded,
                color: scheme.primary,
                size: 22,
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Public helper – shows the picker and returns a RideLocation
// ─────────────────────────────────────────────────────────────────────────────

Future<RideLocation?> showLocationPicker(
  BuildContext context, {
  required LocationSearchMode mode,
}) {
  return Navigator.of(context).push<RideLocation>(
    MaterialPageRoute(builder: (_) => LocationPickerScreen(mode: mode)),
  );
}
