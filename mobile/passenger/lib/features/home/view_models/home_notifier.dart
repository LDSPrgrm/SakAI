import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart' hide LatLng;
import 'package:uuid/uuid.dart';

import '../../ride/models/ride_exception.dart';
import '../../../app/providers.dart';
import '../models/ride_type_option.dart';
import '../repositories/driver_repository.dart';

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

  const HomeState({
    required this.status,
    this.currentLatLng,
    this.pickup,
    this.destination,
    this.errorMessage,
    this.createdRide,
    this.selectedRideType,
    this.rideTypeOptions = const [],
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
  Timer? _rideTypePollTimer;

  @override
  HomeState build() {
    ref.onDispose(() {
      _stopLocationStreaming();
      _stopRideTypePolling();
    });
    return const HomeState(status: HomeStatus.idle);
  }

  /// Starts periodic polling for nearby driver counts by ride type.
  void _startRideTypePolling() {
    _stopRideTypePolling();
    _rideTypePollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (state.destination != null) {
        fetchRideTypeOptions();
      }
    });
    // Immediate first fetch
    fetchRideTypeOptions();
  }

  /// Stops the periodic ride type poller.
  void _stopRideTypePolling() {
    _rideTypePollTimer?.cancel();
    _rideTypePollTimer = null;
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
    // Start real-time polling for nearby driver counts
    _startRideTypePolling();
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
    _stopRideTypePolling();
    state = state.copyWith(status: HomeStatus.idle, clearDestination: true);
  }

  /// Fetches available ride type options based on nearby drivers.
  Future<void> fetchRideTypeOptions() async {
    final pickup = state.pickup;
    final currentLatLng = state.currentLatLng;
    if (pickup == null && currentLatLng == null) return;

    final location = currentLatLng ?? LatLng(pickup!.lat, pickup.lng);
    final authInterceptor = ref.watch(authInterceptorProvider);
    final repo = DriverRepository(authInterceptor: authInterceptor);

    // Query each ride type independently
    final rideTypeApiValues = {
      VehicleType.motorcycle: 'motorcycle',
      VehicleType.car: 'car',
      VehicleType.tricycle: 'tricycle',
    };

    final driverCounts = <VehicleType, int>{};
    for (final entry in rideTypeApiValues.entries) {
      try {
        final drivers = await repo.fetchNearbyDrivers(
          location,
          rideType: entry.value,
        );
        driverCounts[entry.key] = drivers.length;
      } catch (e) {
        debugPrint('fetchRideTypeOptions error for ${entry.key}: $e');
        driverCounts[entry.key] = 0;
      }
    }

    // Base fare estimates per ride type (in PHP)
    const baseFares = {
      VehicleType.motorcycle: 65.0,
      VehicleType.car: 120.0,
      VehicleType.tricycle: 50.0,
    };

    // Base duration estimates (in minutes)
    const baseDurations = {
      VehicleType.motorcycle: 10,
      VehicleType.car: 15,
      VehicleType.tricycle: 12,
    };

    final options = VehicleType.values.map((type) {
      final availableDrivers = driverCounts[type] ?? 0;
      // Simple fare estimate: base fare + distance-based (rough estimate)
      final estimatedFare = baseFares[type]!;
      final estimatedDuration = Duration(minutes: baseDurations[type]!);

      return RideTypeOption(
        type: type,
        estimatedFare: estimatedFare,
        estimatedDuration: estimatedDuration,
        availableDrivers: availableDrivers,
      );
    }).toList();

    state = state.copyWith(rideTypeOptions: options);
  }

  /// Sets the selected ride type.
  void setSelectedRideType(VehicleType type) {
    state = state.copyWith(selectedRideType: type);
  }

  Future<RideEntity?> requestRide() async {
    final pickup = state.pickup;
    final destination = state.destination;
    final rideType = state.selectedRideType;
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
