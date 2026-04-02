import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart' hide LatLng;
import 'package:uuid/uuid.dart';

import '../../domain/ride_exception.dart';
import '../../domain/ride_repository.dart';

/// State enum for the home screen map experience.
enum HomeState { idle, locating, destinationSet, requesting }

/// ViewModel for the full-screen map home screen.
///
/// Responsibilities:
/// - Acquire and track the rider's GPS position.
/// - Reverse-geocode pickup coordinates to a human-readable address.
/// - Hold the chosen destination [RideLocation].
/// - Call [RideRepository.requestRide] and report the created [RideEntity].
class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._rideRepository);

  final RideRepository _rideRepository;
  final _uuid = const Uuid();

  // ── State ──────────────────────────────────────────────────────────────────

  HomeState _state = HomeState.idle;
  HomeState get state => _state;

  LatLng? _currentLatLng;
  LatLng? get currentLatLng => _currentLatLng;

  RideLocation? _pickup;
  RideLocation? get pickup => _pickup;

  RideLocation? _destination;
  RideLocation? get destination => _destination;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RideEntity? _createdRide;
  RideEntity? get createdRide => _createdRide;

  bool get canRequest =>
      _destination != null && _state != HomeState.requesting;

  // Idempotency key — generated once per attempt, cleared on success/error.
  String? _idempotencyKey;

  // ── GPS ────────────────────────────────────────────────────────────────────

  Future<void> initLocation() async {
    _setState(HomeState.locating);
    try {
      final permission = await _ensureLocationPermission();
      if (!permission) {
        _setError('Location permission is required to request a ride.');
        _setState(HomeState.idle);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _currentLatLng = LatLng(pos.latitude, pos.longitude);

      // Reverse-geocode the pickup position
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final p = placemarks.isNotEmpty ? placemarks.first : null;
      final address = p == null
          ? '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}'
          : [p.street, p.subLocality, p.locality]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');

      _pickup = RideLocation(
        lat: pos.latitude,
        lng: pos.longitude,
        address: address,
      );
      _setState(HomeState.idle);
    } catch (e) {
      _setError('Could not determine your location. Check GPS settings.');
      _setState(HomeState.idle);
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

  // ── Destination ────────────────────────────────────────────────────────────

  void setDestination(RideLocation destination) {
    _destination = destination;
    _errorMessage = null;
    _setState(HomeState.destinationSet);
  }

  void setPickup(RideLocation pickup) {
    _pickup = pickup;
    _errorMessage = null;
    if (_destination != null) {
      _setState(HomeState.destinationSet);
    } else {
      _setState(HomeState.idle);
    }
  }

  void clearDestination() {
    _destination = null;
    _setState(HomeState.idle);
  }

  // ── Ride Request ───────────────────────────────────────────────────────────

  Future<RideEntity?> requestRide() async {
    final pickup = _pickup;
    final destination = _destination;
    if (pickup == null || destination == null) return null;

    _idempotencyKey ??= _uuid.v4();
    _clearError();
    _setState(HomeState.requesting);

    try {
      final ride = await _rideRepository.requestRide(
        origin: pickup,
        destination: destination,
        idempotencyKey: _idempotencyKey!,
      );
      _createdRide = ride;
      _idempotencyKey = null; // clear after definitive success
      notifyListeners();
      return ride;
    } on RideException catch (e) {
      _setError(e.userMessage);
      _setState(HomeState.destinationSet);
      return null;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void clearError() => _clearError();

  void _setState(HomeState s) {
    _state = s;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }
}
