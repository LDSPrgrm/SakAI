import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/nearby_driver.dart';
import '../../repositories/directions_service.dart';
import '../../view_models/home_notifier.dart';

/// Async provider that fetches and caches the route polyline.
/// Keyed by (pickupLat, pickupLng, destLat, destLng) so it
/// only re-fetches when coordinates actually change.
final routePolylineProvider = FutureProvider.family<List<LatLng>, _RouteKey>(
  (ref, key) async {
    final service = DirectionsService();
    return service.getRoutePolyline(
      origin: LatLng(key.pickupLat, key.pickupLng),
      destination: LatLng(key.destLat, key.destLng),
    );
  },
);

/// Immutable key for the route polyline provider.
class _RouteKey {
  const _RouteKey({
    required this.pickupLat,
    required this.pickupLng,
    required this.destLat,
    required this.destLng,
  });

  final double pickupLat;
  final double pickupLng;
  final double destLat;
  final double destLng;

  @override
  bool operator ==(Object other) =>
      other is _RouteKey &&
      other.pickupLat == pickupLat &&
      other.pickupLng == pickupLng &&
      other.destLat == destLat &&
      other.destLng == destLng;

  @override
  int get hashCode =>
      Object.hash(pickupLat, pickupLng, destLat, destLng);
}

/// Full-screen GoogleMap used only during the booking flow.
///
/// Shown when [HomeStatus] is [destinationSet] or [requesting].
/// Displays:
///   - User's current location dot (myLocationEnabled)
///   - Green pickup marker
///   - Red destination marker
///   - Directions API route polyline
///   - Nearby driver markers (grey dots)
///
/// Camera auto-fits to show all route points with padding.
class BookingMap extends ConsumerStatefulWidget {
  const BookingMap({super.key});

  @override
  ConsumerState<BookingMap> createState() => _BookingMapState();
}

class _BookingMapState extends ConsumerState<BookingMap> {
  GoogleMapController? _controller;

  // Track what we last animated to avoid redundant camera moves.
  _RouteKey? _lastKey;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final pickup = homeState.pickup;
    final destination = homeState.destination;

    if (pickup == null || destination == null) {
      return const SizedBox.shrink();
    }

    final pickupLatLng = LatLng(pickup.lat, pickup.lng);
    final destLatLng = LatLng(destination.lat, destination.lng);
    final routeKey = _RouteKey(
      pickupLat: pickup.lat,
      pickupLng: pickup.lng,
      destLat: destination.lat,
      destLng: destination.lng,
    );

    final routeAsync = ref.watch(routePolylineProvider(routeKey));

    final routePoints = routeAsync.maybeWhen(
      data: (pts) => pts,
      orElse: () => [pickupLatLng, destLatLng],
    );

    // Animate camera whenever route key changes (new destination selected).
    if (_controller != null && routeKey != _lastKey) {
      _lastKey = routeKey;
      _animateCameraToFitRoute(routePoints, pickupLatLng, destLatLng);
    }

    final markers = _buildMarkers(pickupLatLng, destLatLng, homeState.nearbyDrivers);
    final polylines = _buildPolylines(routePoints);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          (pickup.lat + destination.lat) / 2,
          (pickup.lng + destination.lng) / 2,
        ),
        zoom: 13,
      ),
      onMapCreated: (controller) {
        _controller = controller;
        _lastKey = routeKey;
        _animateCameraToFitRoute(routePoints, pickupLatLng, destLatLng);
      },
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      padding: const EdgeInsets.only(top: 80, bottom: 340), // room for top bar and bottom sheet
    );
  }

  // ── Camera ─────────────────────────────────────────────────────────────────

  void _animateCameraToFitRoute(
    List<LatLng> routePoints,
    LatLng pickup,
    LatLng dest,
  ) {
    final allPoints = routePoints.isNotEmpty ? routePoints : [pickup, dest];
    final bounds = boundsFromPoints(allPoints);
    
    void attemptAnimate() {
      if (_controller == null || !mounted) return;
      try {
        _controller!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 80),
        );
      } catch (_) {
        // Fallback: wait a short duration if map was not fully laid out/loaded yet
        Future.delayed(const Duration(milliseconds: 150), () {
          if (_controller == null || !mounted) return;
          try {
            _controller!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 80),
            );
          } catch (_) {}
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => attemptAnimate());
  }

  // ── Markers ────────────────────────────────────────────────────────────────

  Set<Marker> _buildMarkers(
    LatLng pickup,
    LatLng dest,
    List<NearbyDriver> drivers,
  ) {
    final markers = <Marker>{
      // Pickup — green circle
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup'),
        zIndex: 2,
      ),
      // Destination — red pin (default)
      Marker(
        markerId: const MarkerId('destination'),
        position: dest,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destination'),
        zIndex: 2,
      ),
    };

    // Nearby driver markers — subtle cyan dots
    for (final driver in drivers) {
      markers.add(
        Marker(
          markerId: MarkerId('driver_${driver.id}'),
          position: driver.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueCyan,
          ),
          anchor: const Offset(0.5, 0.5),
          zIndex: 1,
          flat: true,
        ),
      );
    }

    return markers;
  }

  // ── Polylines ──────────────────────────────────────────────────────────────

  Set<Polyline> _buildPolylines(List<LatLng> points) {
    if (points.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: const Color(0xFF00DC82),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }
}
