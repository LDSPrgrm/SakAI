import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart' hide LatLng;
import 'package:uuid/uuid.dart';

import '../../ride/models/ride_exception.dart';
import '../../../app/providers.dart';

enum HomeStatus { idle, locating, destinationSet, requesting }

class HomeState {
  final HomeStatus status;
  final LatLng? currentLatLng;
  final RideLocation? pickup;
  final RideLocation? destination;
  final String? errorMessage;
  final RideEntity? createdRide;

  const HomeState({
    required this.status,
    this.currentLatLng,
    this.pickup,
    this.destination,
    this.errorMessage,
    this.createdRide,
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
  }) {
    return HomeState(
      status: status ?? this.status,
      currentLatLng: currentLatLng ?? this.currentLatLng,
      pickup: clearPickup ? null : (pickup ?? this.pickup),
      destination: clearDestination ? null : (destination ?? this.destination),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdRide: clearCreatedRide ? null : (createdRide ?? this.createdRide),
    );
  }

  bool get canRequest => destination != null && status != HomeStatus.requesting;
}

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});

class HomeNotifier extends Notifier<HomeState> {
  final _uuid = const Uuid();
  String? _idempotencyKey;

  @override
  HomeState build() {
    return const HomeState(status: HomeStatus.idle);
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
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
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

      final pickup = RideLocation(
        lat: pos.latitude,
        lng: pos.longitude,
        address: address,
      );

      state = state.copyWith(
        status: HomeStatus.idle,
        currentLatLng: currentLatLng,
        pickup: pickup,
      );
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.idle,
        errorMessage: 'Could not determine your location. Check GPS settings.',
      );
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

  void setDestination(RideLocation destination) {
    state = state.copyWith(
      status: HomeStatus.destinationSet,
      destination: destination,
      clearError: true,
    );
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
    state = state.copyWith(
      status: HomeStatus.idle,
      clearDestination: true,
    );
  }

  Future<RideEntity?> requestRide() async {
    final pickup = state.pickup;
    final destination = state.destination;
    if (pickup == null || destination == null) return null;

    _idempotencyKey ??= _uuid.v4();
    state = state.copyWith(status: HomeStatus.requesting, clearError: true);

    try {
      final repo = ref.read(rideRepositoryProvider);
      final ride = await repo.requestRide(
        origin: pickup,
        destination: destination,
        idempotencyKey: _idempotencyKey!,
      );

      _idempotencyKey = null; // clear after definitive success
      state = state.copyWith(createdRide: ride);
      return ride;
    } on RideException catch (e) {
      state = state.copyWith(
        status: HomeStatus.destinationSet,
        errorMessage: e.userMessage,
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
