import 'dart:async';
import 'dart:math' show sin, cos, sqrt, asin, pi;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../repositories/active_ride_repository.dart';
import '../models/active_ride_step.dart';
import '../services/location_stream_service.dart';

typedef OnRideCompleted = void Function(RideResponse ride);
typedef OnRideCancelled = void Function();

class ActiveRideState {
  const ActiveRideState({
    this.ride,
    required this.currentStep,
    this.isTransitioning = false,
    this.errorMessage,
    this.isNearPickup = false,
    this.isNearDestination = false,
  });

  final RideResponse? ride;
  final ActiveRideStep currentStep;
  final bool isTransitioning;
  final String? errorMessage;
  final bool isNearPickup;
  final bool isNearDestination;

  ActiveRideState copyWith({
    RideResponse? ride,
    ActiveRideStep? currentStep,
    bool? isTransitioning,
    String? errorMessage,
    bool? isNearPickup,
    bool? isNearDestination,
  }) {
    return ActiveRideState(
      ride: ride ?? this.ride,
      currentStep: currentStep ?? this.currentStep,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      errorMessage: errorMessage,
      isNearPickup: isNearPickup ?? this.isNearPickup,
      isNearDestination: isNearDestination ?? this.isNearDestination,
    );
  }

  static ActiveRideStep mapStatusToStep(RideStatus status) {
    switch (status) {
      case RideStatus.accepted:
        return ActiveRideStep.enRoute;
      case RideStatus.arrived:
        return ActiveRideStep.arrived;
      case RideStatus.inProgress:
        return ActiveRideStep.inProgress;
      default:
        return ActiveRideStep.enRoute;
    }
  }
}

class ActiveRideManager extends ChangeNotifier {
  final ActiveRideRepository _repo;
  final LocationStreamService? _locationStream;
  ActiveRideState _state;
  StreamSubscription<LocationPushState>? _locationStreamSub;

  OnRideCompleted? onCompleted;
  OnRideCancelled? onCancelled;

  ActiveRideManager({
    required ActiveRideRepository repo,
    required RideResponse initialRide,
    LocationStreamService? locationStream,
  }) : _repo = repo,
       _locationStream = locationStream,
       _state = ActiveRideState(
         ride: initialRide,
         currentStep: ActiveRideState.mapStatusToStep(initialRide.status),
       ) {
    debugPrint('[D-ActiveRide] init: rideId=${initialRide.id}, status=${initialRide.status}');
    if (_isLiveStatus(initialRide.status)) {
      _locationStream?.start(initialRide.id);
    }
    _updateProximity(_locationStream?.currentState.lastPosition);
    _locationStreamSub = _locationStream?.stream.listen((state) {
      _updateProximity(state.lastPosition);
    });
  }

  ActiveRideState get state => _state;

  LocationStreamService? get locationStream => _locationStream;

  static bool _isLiveStatus(RideStatus status) =>
      status == RideStatus.accepted ||
      status == RideStatus.arrived ||
      status == RideStatus.inProgress;

  Future<void> arriveAtPickup({bool force = false}) async {
    if (_state.isTransitioning) return;

    final ride = _state.ride;
    if (ride == null) return;

    debugPrint('[D-ActiveRide] arriveAtPickup: rideId=${ride.id}, force=$force');
    // Capture current GPS position before transitioning.
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('[D-ActiveRide] arriveAtPickup: GPS error: $e');
      _state = _state.copyWith(
        isTransitioning: false,
        errorMessage:
            'Unable to get GPS location. Please enable location services.',
      );
      notifyListeners();
      return;
    }

    final driverLatLng = _Position(
      currentPosition.latitude,
      currentPosition.longitude,
    );
    final pickupLatLng = _Position(ride.origin.lat, ride.origin.lng);
    final distanceToPickup = _haversineDistance(driverLatLng, pickupLatLng);
    const pickupThreshold = 50.0; // 50 meters

    if (!force && distanceToPickup > pickupThreshold) {
      debugPrint('[D-ActiveRide] arriveAtPickup: too far (${distanceToPickup.toStringAsFixed(0)}m > ${pickupThreshold}m)');
      _state = _state.copyWith(
        isTransitioning: false,
        errorMessage:
            'You are ${distanceToPickup.toStringAsFixed(0)}m away from the pickup point. '
            'You must be within ${pickupThreshold.toStringAsFixed(0)}m to mark as arrived.',
      );
      notifyListeners();
      return;
    }

    final lat = currentPosition.latitude;
    final lng = currentPosition.longitude;

    _state = _state.copyWith(isTransitioning: true, errorMessage: null);
    notifyListeners();
    try {
      final latLng = LatLng(
        (b) => b
          ..lat = lat
          ..lng = lng,
      );
      await _repo.arriveAtPickup(ride.id, latLng);
      debugPrint('[D-ActiveRide] arriveAtPickup: API success');
      _state = _state.copyWith(
        isTransitioning: false,
        currentStep: ActiveRideStep.arrived,
      );
      notifyListeners();
    } catch (e) {
      final msg = _errorMessage(e);
      debugPrint('[D-ActiveRide] arriveAtPickup error: $msg');
      // If the backend still says too far, offer force option.
      if (msg.contains('DRIVER_TOO_FAR')) {
        _state = _state.copyWith(
          isTransitioning: false,
          errorMessage:
              'You are still outside the pickup area (${distanceToPickup.toStringAsFixed(0)}m). '
              'Move closer and try again, or contact support if GPS is inaccurate.',
        );
      } else {
        _state = _state.copyWith(isTransitioning: false, errorMessage: msg);
      }
      notifyListeners();
    }
  }

  Future<void> startRide() async {
    if (_state.isTransitioning) return;
    debugPrint('[D-ActiveRide] startRide: rideId=${_state.ride?.id}');
    _state = _state.copyWith(isTransitioning: true, errorMessage: null);
    notifyListeners();
    try {
      await _repo.startRide(_state.ride!.id);
      debugPrint('[D-ActiveRide] startRide: API success');
      _state = _state.copyWith(
        isTransitioning: false,
        currentStep: ActiveRideStep.inProgress,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('[D-ActiveRide] startRide error: $e');
      _state = _state.copyWith(
        isTransitioning: false,
        errorMessage: _errorMessage(e),
      );
      notifyListeners();
    }
  }

  Future<void> completeRide({bool force = false}) async {
    if (_state.isTransitioning) return;

    final ride = _state.ride;
    if (ride == null) return;

    debugPrint('[D-ActiveRide] completeRide: rideId=${ride.id}, force=$force');
    // Capture current GPS position before transitioning.
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('[D-ActiveRide] completeRide: GPS error: $e');
      _state = _state.copyWith(
        isTransitioning: false,
        errorMessage:
            'Unable to get GPS location. Please enable location services.',
      );
      notifyListeners();
      return;
    }

    final driverLatLng = _Position(
      currentPosition.latitude,
      currentPosition.longitude,
    );
    final destLatLng = _Position(ride.destination.lat, ride.destination.lng);
    final distanceToDest = _haversineDistance(driverLatLng, destLatLng);
    const destinationThreshold = 100.0; // 100 meters

    if (!force && distanceToDest > destinationThreshold) {
      debugPrint('[D-ActiveRide] completeRide: too far (${distanceToDest.toStringAsFixed(0)}m > ${destinationThreshold}m)');
      _state = _state.copyWith(
        isTransitioning: false,
        errorMessage:
            'You are ${distanceToDest.toStringAsFixed(0)}m away from the destination. '
            'You must be within ${destinationThreshold.toStringAsFixed(0)}m to complete the ride.',
      );
      notifyListeners();
      return;
    }

    final lat = currentPosition.latitude;
    final lng = currentPosition.longitude;

    _state = _state.copyWith(isTransitioning: true, errorMessage: null);
    notifyListeners();
    try {
      final latLng = LatLng(
        (b) => b
          ..lat = lat
          ..lng = lng,
      );
      await _repo.completeRide(ride.id, latLng);
      debugPrint('[D-ActiveRide] completeRide: API success');
      _locationStream?.stop();
      _state = _state.copyWith(isTransitioning: false);
      notifyListeners();
      final completedRide = _state.ride;
      if (completedRide != null) {
        onCompleted?.call(completedRide);
      }
    } catch (e) {
      final msg = _errorMessage(e);
      debugPrint('[D-ActiveRide] completeRide error: $msg');
      if (msg.contains('DRIVER_TOO_FAR_FROM_DESTINATION')) {
        _state = _state.copyWith(
          isTransitioning: false,
          errorMessage:
              'You are still outside the destination area (${distanceToDest.toStringAsFixed(0)}m). '
              'Move closer and try again, or contact support if GPS is inaccurate.',
        );
      } else {
        _state = _state.copyWith(isTransitioning: false, errorMessage: msg);
      }
      notifyListeners();
    }
  }

  Future<void> cancelRide({String? reasonText}) async {
    if (_state.isTransitioning) return;
    if (_state.currentStep == ActiveRideStep.inProgress) return;
    debugPrint('[D-ActiveRide] cancelRide: rideId=${_state.ride?.id}, reason=$reasonText');
    _state = _state.copyWith(isTransitioning: true, errorMessage: null);
    notifyListeners();
    try {
      await _repo.cancelRide(_state.ride!.id, reasonText: reasonText);
      debugPrint('[D-ActiveRide] cancelRide: API success');
      _locationStream?.stop();
      _state = _state.copyWith(isTransitioning: false);
      notifyListeners();
      onCancelled?.call();
    } catch (e) {
      debugPrint('[D-ActiveRide] cancelRide error: $e');
      _state = _state.copyWith(
        isTransitioning: false,
        errorMessage: _errorMessage(e),
      );
      notifyListeners();
    }
  }

  void handleStatusChanged(RideStatus newStatus) {
    debugPrint('[D-ActiveRide] WS handleStatusChanged: $newStatus');
    final newStep = ActiveRideState.mapStatusToStep(newStatus);
    _state = _state.copyWith(
      currentStep: newStep,
      isTransitioning: false,
      errorMessage: null,
    );
    if (newStatus == RideStatus.completed ||
        newStatus == RideStatus.cancelled) {
      debugPrint('[D-ActiveRide] handleStatusChanged: terminal status, stopping location stream');
      _locationStream?.stop();
    } else if (_isLiveStatus(newStatus)) {
      final ride = _state.ride;
      if (ride != null) {
        _locationStream?.start(ride.id);
      }
    }
    notifyListeners();
    final ride = _state.ride;
    if (newStatus == RideStatus.completed && ride != null) {
      onCompleted?.call(ride);
    }
    if (newStatus == RideStatus.cancelled) onCancelled?.call();
  }

  @override
  void dispose() {
    debugPrint('[D-ActiveRide] dispose: rideId=${_state.ride?.id}');
    _locationStreamSub?.cancel();
    _locationStream?.stop();
    super.dispose();
  }

  void _updateProximity(Position? position) {
    final ride = _state.ride;
    if (ride == null || position == null) {
      if (_state.isNearPickup || _state.isNearDestination) {
        _state = _state.copyWith(
          isNearPickup: false,
          isNearDestination: false,
        );
        notifyListeners();
      }
      return;
    }

    final driverLatLng = _Position(position.latitude, position.longitude);
    final pickupLatLng = _Position(ride.origin.lat, ride.origin.lng);
    final destLatLng = _Position(ride.destination.lat, ride.destination.lng);

    final distanceToPickup = _haversineDistance(driverLatLng, pickupLatLng);
    final distanceToDest = _haversineDistance(driverLatLng, destLatLng);

    final isNearPickup = distanceToPickup <= 50.0;
    final isNearDestination = distanceToDest <= 100.0;

    if (isNearPickup != _state.isNearPickup ||
        isNearDestination != _state.isNearDestination) {
      debugPrint('[D-ActiveRide] proximity changed: isNearPickup=$isNearPickup, isNearDestination=$isNearDestination');
      _state = _state.copyWith(
        isNearPickup: isNearPickup,
        isNearDestination: isNearDestination,
      );
      notifyListeners();
    }
  }

  void clearError() {
    debugPrint('[D-ActiveRide] clearError');
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  String _errorMessage(dynamic e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    if (msg.contains('409')) {
      if (msg.contains('DRIVER_TOO_FAR_FROM_DESTINATION')) {
        return 'You must be within 100 meters of the destination.';
      }
      if (msg.contains('DRIVER_TOO_FAR')) {
        return 'You must be within 50 meters of the pickup location.';
      }
      return 'Cannot perform this action in current state.';
    }
    return msg.isEmpty ? 'Something went wrong. Try again.' : msg;
  }

  /// Haversine distance in meters between two lat/lng points.
  static double _haversineDistance(_Position a, _Position b) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = _toRad(b.lat - a.lat);
    final dLng = _toRad(b.lng - a.lng);
    final x =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(a.lat)) * cos(_toRad(b.lat)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * asin(sqrt(x));
  }

  static double _toRad(double deg) => deg * pi / 180.0;
}

/// Simple lat/lng pair for distance calculations.
class _Position {
  final double lat;
  final double lng;

  const _Position(this.lat, this.lng);
}
