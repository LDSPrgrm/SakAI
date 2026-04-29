import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide LatLng, NearbyDriver, ServiceArea;
import 'package:uuid/uuid.dart';

import '../../ride/models/ride_exception.dart';
import '../../../app/providers.dart';
import '../models/ride_type_option.dart';
import '../models/nearby_driver.dart';
import '../models/service_area.dart';
import '../repositories/driver_repository.dart';
import '../repositories/service_area_repository.dart';

enum HomeStatus {
  idle,
  locating,
  destinationSet,
  requesting,
  selectingRideType,
}

class HomeState {
  final HomeStatus status;
  final LatLng? currentLatLng;
  final RideLocation? pickup;
  final RideLocation? destination;
  final String? errorMessage;
  final RideEntity? createdRide;
  final VehicleType? selectedRideType;
  final List<RideTypeOption> rideTypeOptions;
  final List<NearbyDriver> nearbyDrivers;
  final List<ServiceArea> serviceAreas;

  const HomeState({
    required this.status,
    this.currentLatLng,
    this.pickup,
    this.destination,
    this.errorMessage,
    this.createdRide,
    this.selectedRideType,
    this.rideTypeOptions = const [],
    this.nearbyDrivers = const [],
    this.serviceAreas = const [],
  });

  HomeState copyWith({
    HomeStatus? status,
    LatLng? currentLatLng,
    RideLocation? pickup,
    RideLocation? destination,
    String? errorMessage,
    RideEntity? createdRide,
    bool clearError = false,
    bool clearDestination = false,
    bool clearPickup = false,
    bool clearCreatedRide = false,
    VehicleType? selectedRideType,
    bool clearSelectedRideType = false,
    List<RideTypeOption>? rideTypeOptions,
    List<NearbyDriver>? nearbyDrivers,
    List<ServiceArea>? serviceAreas,
  }) {
    return HomeState(
      status: status ?? this.status,
      currentLatLng: currentLatLng ?? this.currentLatLng,
      pickup: clearPickup ? null : (pickup ?? this.pickup),
      destination: clearDestination ? null : (destination ?? this.destination),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdRide: clearCreatedRide ? null : (createdRide ?? this.createdRide),
      selectedRideType: clearSelectedRideType
          ? null
          : (selectedRideType ?? this.selectedRideType),
      rideTypeOptions: rideTypeOptions ?? this.rideTypeOptions,
      nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
      serviceAreas: serviceAreas ?? this.serviceAreas,
    );
  }

  bool get canRequest =>
      destination != null &&
      selectedRideType != null &&
      status != HomeStatus.requesting;
}

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});

class HomeNotifier extends Notifier<HomeState> {
  final _uuid = const Uuid();
  String? _idempotencyKey;
  Timer? _nearbyDriverPollTimer;

  @override
  HomeState build() {
    ref.onDispose(() {
      _stopLocationStreaming();
      _stopNearbyDriverPolling();
    });
    _fetchServiceAreas();
    return const HomeState(status: HomeStatus.idle);
  }

  Future<void> _fetchServiceAreas() async {
    try {
      final authInterceptor = ref.read(authInterceptorProvider);
      final repo = ServiceAreaRepository(authInterceptor: authInterceptor);
      final areas = await repo.getServiceAreas();
      state = state.copyWith(serviceAreas: areas);
    } catch (e) {
      debugPrint('[HomeNotifier] Failed to fetch service areas: $e');
    }
  }

  /// Starts consolidated periodic polling for nearby drivers.
  /// Single poll serves both ride type options AND map markers — eliminates duplicate API calls.
  void _startNearbyDriverPolling() {
    _stopNearbyDriverPolling();
    _nearbyDriverPollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchNearbyDrivers();
    });
    // Immediate first fetch
    _fetchNearbyDrivers();
  }

  /// Stops the periodic nearby driver poller.
  void _stopNearbyDriverPolling() {
    _nearbyDriverPollTimer?.cancel();
    _nearbyDriverPollTimer = null;
  }

  /// Fetches nearby drivers and updates both ride type options and map markers from a single API call.
  Future<void> _fetchNearbyDrivers() async {
    final currentPos = state.currentLatLng;
    if (currentPos == null) return;

    try {
      final authInterceptor = ref.read(authInterceptorProvider);
      final allDrivers = await DriverRepository(
        authInterceptor: authInterceptor,
      ).fetchNearbyDriversAll(currentPos);

      // Flatten into a single list for map markers
      final flatDrivers = allDrivers.values
          .expand<NearbyDriver>((d) => d)
          .toList();

      // Build ride type options with fare estimates
      final options = _buildRideTypeOptions(allDrivers);

      state = state.copyWith(
        nearbyDrivers: flatDrivers,
        rideTypeOptions: options,
      );
    } catch (e) {
      debugPrint('[HomeNotifier] Nearby driver poll error: $e');
    }
  }

  /// Builds ride type options with fare estimates from nearby driver data.
  List<RideTypeOption> _buildRideTypeOptions(
    Map<String, List<NearbyDriver>> allDrivers,
  ) {
    const baseFares = {'motorcycle': 65.0, 'car': 120.0, 'tricycle': 50.0};
    const baseDurations = {'motorcycle': 10, 'car': 15, 'tricycle': 12};

    return baseFares.entries.map((entry) {
      final typeStr = entry.key;
      final type = VehicleType.values.firstWhere(
        (t) => t.toString().split('.').last == typeStr,
        orElse: () => VehicleType.car,
      );
      final availableDrivers = allDrivers[typeStr]?.length ?? 0;

      return RideTypeOption(
        type: type,
        estimatedFare: entry.value,
        estimatedDuration: Duration(minutes: baseDurations[typeStr]!),
        availableDrivers: availableDrivers,
      );
    }).toList();
  }

  Future<void> initLocation() async {
    state = state.copyWith(status: HomeStatus.locating);
    try {
      final permission = await _ensureLocationPermission();
      if (!permission) {
        state = state.copyWith(
          status: HomeStatus.idle,
          errorMessage: 'Location permission is required to request a ride.',
        );
        return;
      }
      await _updatePickupFromGps();
      _startLocationStreaming();
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.idle,
        errorMessage: 'Could not determine your location. Check GPS settings.',
      );
    }
  }

  /// Updates pickup location from current GPS position.
  Future<void> _updatePickupFromGps() async {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    final currentLatLng = LatLng(pos.latitude, pos.longitude);

    // Reverse-geocode the pickup position
    final placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    final p = placemarks.isNotEmpty ? placemarks.first : null;
    final address = p == null
        ? '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}'
        : [
            p.street,
            p.subLocality,
            p.locality,
          ].where((s) => s != null && s.isNotEmpty).join(', ');

    state = state.copyWith(
      status: HomeStatus.idle,
      currentLatLng: currentLatLng,
      pickup: RideLocation(
        lat: pos.latitude,
        lng: pos.longitude,
        address: address,
      ),
    );
  }

  /// Starts streaming GPS to keep pickup location fresh.
  void _startLocationStreaming() {
    _stopLocationStreaming();
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // Update every 10 meters
          ),
        ).listen((position) {
          final currentLatLng = LatLng(position.latitude, position.longitude);
          placemarkFromCoordinates(position.latitude, position.longitude)
              .then((placemarks) {
                final p = placemarks.isNotEmpty ? placemarks.first : null;
                final address = p == null
                    ? '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}'
                    : [
                        p.street,
                        p.subLocality,
                        p.locality,
                      ].where((s) => s != null && s.isNotEmpty).join(', ');
                state = state.copyWith(
                  currentLatLng: currentLatLng,
                  pickup: RideLocation(
                    lat: position.latitude,
                    lng: position.longitude,
                    address: address,
                  ),
                );
              })
              .catchError((_) {
                // If reverse geocoding fails, still update coordinates.
                state = state.copyWith(
                  currentLatLng: currentLatLng,
                  pickup: RideLocation(
                    lat: position.latitude,
                    lng: position.longitude,
                    address:
                        state.pickup?.address ??
                        '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
                  ),
                );
              });
        });
  }

  StreamSubscription<Position>? _positionStream;

  void _stopLocationStreaming() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  Future<bool> _ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  void setDestination(RideLocation destination) {
    state = state.copyWith(
      status: HomeStatus.destinationSet,
      destination: destination,
      clearError: true,
    );
    // Start consolidated nearby driver polling (serves both ride options and map markers)
    _startNearbyDriverPolling();
  }

  void setPickup(RideLocation pickup) {
    state = state.copyWith(
      pickup: pickup,
      status: state.destination != null
          ? HomeStatus.destinationSet
          : HomeStatus.idle,
      clearError: true,
    );
  }

  void clearDestination() {
    _stopNearbyDriverPolling();
    state = state.copyWith(
      status: HomeStatus.idle,
      clearDestination: true,
      clearSelectedRideType: true,
      nearbyDrivers: [],
      rideTypeOptions: [],
    );
  }

  /// Sets the selected ride type.
  void setSelectedRideType(VehicleType type) {
    state = state.copyWith(selectedRideType: type);
  }

  bool _isLocationInServiceArea(RideLocation location) {
    if (state.serviceAreas.isEmpty) {
      return true; // Default to true if not loaded yet
    }

    final point = LatLng(location.lat, location.lng);
    for (final area in state.serviceAreas) {
      if (area.contains(point)) {
        return true;
      }
    }
    return false;
  }

  Future<RideEntity?> requestRide() async {
    final pickup = state.pickup;
    final destination = state.destination;
    final rideType = state.selectedRideType;

    if (pickup != null && !_isLocationInServiceArea(pickup)) {
      state = state.copyWith(
        errorMessage: 'Pickup location is outside our service area.',
      );
      return null;
    }

    if (destination != null && !_isLocationInServiceArea(destination)) {
      state = state.copyWith(
        errorMessage: 'Destination location is outside our service area.',
      );
      return null;
    }
    debugPrint(
      '[HOME] requestRide called: pickup=$pickup, destination=$destination, rideType=$rideType',
    );
    if (pickup == null || destination == null) {
      debugPrint('[HOME] Cannot request ride: pickup or destination is null');
      return null;
    }

    _idempotencyKey ??= _uuid.v4();
    debugPrint('[HOME] Requesting ride with idempotency key: $_idempotencyKey');
    state = state.copyWith(status: HomeStatus.requesting, clearError: true);

    try {
      final repo = ref.read(rideRepositoryProvider);
      final ride = await repo.requestRide(
        origin: pickup,
        destination: destination,
        idempotencyKey: _idempotencyKey!,
        rideType: rideType,
        paymentMethod: 'cash', // Default to cash for now
      );

      _idempotencyKey = null; // clear after definitive success
      debugPrint('[HOME] Ride created successfully: ${ride.id}');
      state = state.copyWith(createdRide: ride);
      return ride;
    } on RideException catch (e) {
      debugPrint('[HOME] RideException: ${e.userMessage}');
      state = state.copyWith(
        status: HomeStatus.destinationSet,
        errorMessage: e.userMessage,
      );
      return null;
    } catch (e) {
      debugPrint('[HOME] Unexpected error: $e');
      state = state.copyWith(
        status: HomeStatus.destinationSet,
        errorMessage: 'Failed to request ride. Try again.',
      );
      return null;
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}
