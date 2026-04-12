import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:sakai_shared/sakai_shared.dart' hide LatLng;

import '../../../app/providers.dart';
import '../../../app/routes.dart';

/// Active ride screen showing real-time driver tracking.
///
/// Listens to WebSocket events:
/// - ride.accepted → show driver info
/// - ride.arrived → driver at pickup
/// - ride.status_changed → in_progress, completed, cancelled
class ActiveRideScreen extends ConsumerStatefulWidget {
  const ActiveRideScreen({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen> {
  gmaps.GoogleMapController? _mapController;
  final Set<gmaps.Marker> _markers = {};
  RideEntity? _ride;
  bool _loading = true;
  String? _error;

  StreamSubscription<WsEvent>? _wsSub;

  @override
  void initState() {
    super.initState();
    _loadRide();
    _setupWebSocketListener();
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadRide() async {
    try {
      final client = ref.read(apiClientProvider);
      final apiResponse = await client.getRidesApi().rideGet(
        rideId: widget.rideId,
      );
      final response = apiResponse.data;
      if (response == null) {
        setState(() {
          _error = 'No ride data found';
          _loading = false;
        });
        return;
      }
      setState(() {
        _ride = _rideFromResponse(response);
        _loading = false;
      });
      _updateMarkers();
    } catch (e) {
      setState(() {
        _error = 'Failed to load ride';
        _loading = false;
      });
    }
  }

  void _setupWebSocketListener() {
    final wsClient = ref.read(wsClientProvider);
    _wsSub = wsClient.events.listen((event) {
      if (!mounted) return;

      switch (event.type) {
        case WsEventNames.rideStatusChanged:
          _handleStatusChanged(event.payload);
          break;
        case WsEventNames.driverLocationUpdated:
          _handleDriverLocation(event.payload);
          break;
        case WsEventNames.rideArrived:
          _handleDriverArrived();
          break;
        case WsEventNames.rideCancelled:
          _handleRideCancelled();
          break;
      }
    });
  }

  void _handleStatusChanged(Map<String, dynamic> payload) {
    final status = payload['status'] as String?;
    if (status == null) return;

    final rideState = RideState.fromString(status);
    setState(() {
      _ride = _ride?.copyWith(status: rideState);
    });

    if (rideState == RideState.completed) {
      _navigateToRideComplete();
    } else if (rideState == RideState.cancelled) {
      _navigateToRideCancelled();
    }
  }

  void _handleDriverLocation(Map<String, dynamic> payload) {
    final lat = payload['lat'] as double?;
    final lng = payload['lng'] as double?;
    if (lat == null || lng == null) return;

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'driver');
      _markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('driver'),
          position: gmaps.LatLng(lat, lng),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueAzure,
          ),
          infoWindow: const gmaps.InfoWindow(title: 'Your Driver'),
        ),
      );
    });

    _mapController?.animateCamera(
      gmaps.CameraUpdate.newLatLng(gmaps.LatLng(lat, lng)),
    );
  }

  void _handleDriverArrived() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Your driver has arrived!')));
  }

  void _handleRideCancelled() {
    _navigateToRideCancelled();
  }

  void _updateMarkers() {
    if (_ride == null) return;

    _markers.clear();

    _markers.add(
      gmaps.Marker(
        markerId: const gmaps.MarkerId('pickup'),
        position: gmaps.LatLng(_ride!.origin.lat, _ride!.origin.lng),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueGreen,
        ),
        infoWindow: gmaps.InfoWindow(
          title: 'Pickup',
          snippet: _ride!.origin.address,
        ),
      ),
    );

    _markers.add(
      gmaps.Marker(
        markerId: const gmaps.MarkerId('destination'),
        position: gmaps.LatLng(_ride!.destination.lat, _ride!.destination.lng),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueRed,
        ),
        infoWindow: gmaps.InfoWindow(
          title: 'Destination',
          snippet: _ride!.destination.address,
        ),
      ),
    );
  }

  void _navigateToRideComplete() {
    if (!mounted) return;
    context.push(Routes.rideComplete, extra: widget.rideId);
  }

  void _navigateToRideCancelled() {
    if (!mounted) return;
    context.go('/ride/cancelled/${widget.rideId}');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadRide, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
              target: gmaps.LatLng(_ride!.origin.lat, _ride!.origin.lng),
              zoom: 14,
            ),
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          if (_ride?.driverName != null)
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
                                  _ride!.driverName!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                if (_ride!.driverVehicle != null)
                                  Text(
                                    _ride!.driverVehicle!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          _buildStatusIndicator(),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        _statusText,
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
                      'Ride ${_ride!.id.substring(0, 8)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _ride!.origin.address,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _ride!.destination.address,
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

  Widget _buildStatusIndicator() {
    Color color;
    String text;

    switch (_ride!.status) {
      case RideState.accepted:
        color = Colors.blue;
        text = 'En Route';
        break;
      case RideState.arrived:
        color = Colors.green;
        text = 'Arrived';
        break;
      case RideState.inProgress:
        color = Colors.orange;
        text = 'In Progress';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String get _statusText {
    switch (_ride!.status) {
      case RideState.accepted:
        return 'Your driver is on the way';
      case RideState.arrived:
        return 'Your driver has arrived at pickup';
      case RideState.inProgress:
        return 'Ride in progress to destination';
      case RideState.completed:
        return 'Ride completed';
      case RideState.cancelled:
        return 'Ride cancelled';
      case RideState.requested:
        return 'Looking for a driver...';
    }
  }
}

/// Maps a generated RideResponse to a domain RideEntity.
RideEntity _rideFromResponse(RideResponse response) {
  return RideEntity(
    id: response.id,
    status: RideState.fromString(response.status.name),
    origin: RideLocation(
      lat: response.origin.lat,
      lng: response.origin.lng,
      address: response.originAddress ?? '',
    ),
    destination: RideLocation(
      lat: response.destination.lat,
      lng: response.destination.lng,
      address: response.destinationAddress ?? '',
    ),
    createdAt: response.createdAt,
    updatedAt: response.updatedAt,
    driverName: null, // TODO: enrich with driver name from /users/{id}
    driverVehicle: null, // TODO: enrich with vehicle info
  );
}
