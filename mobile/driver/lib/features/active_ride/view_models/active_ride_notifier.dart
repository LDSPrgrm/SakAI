import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../repositories/active_ride_repository.dart';
import '../models/active_ride_step.dart';

typedef OnRideCompleted = void Function(RideResponse ride);
typedef OnRideCancelled = void Function();

class ActiveRideState {
  const ActiveRideState({
    this.ride,
    required this.currentStep,
    this.isTransitioning = false,
    this.errorMessage,
  });

  final RideResponse? ride;
  final ActiveRideStep currentStep;
  final bool isTransitioning;
  final String? errorMessage;

  ActiveRideState copyWith({
    RideResponse? ride,
    ActiveRideStep? currentStep,
    bool? isTransitioning,
    String? errorMessage,
  }) {
    return ActiveRideState(
      ride: ride ?? this.ride,
      currentStep: currentStep ?? this.currentStep,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      errorMessage: errorMessage,
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
  ActiveRideState _state;

  OnRideCompleted? onCompleted;
  OnRideCancelled? onCancelled;

  ActiveRideManager({
    required ActiveRideRepository repo,
    required RideResponse initialRide,
  }) : _repo = repo,
       _state = ActiveRideState(
         ride: initialRide,
         currentStep: ActiveRideState.mapStatusToStep(initialRide.status),
       );

  ActiveRideState get state => _state;

  Future<void> arriveAtPickup() async {
    if (_state.isTransitioning) return;

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
      _state = _state.copyWith(
        isTransitioning: false,
        errorMessage:
            'Unable to get GPS location. Please enable location services.',
      );
      notifyListeners();
      return;
    }

    // Geolocator.getCurrentPosition either returns a valid Position or throws.
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
      await _repo.arriveAtPickup(_state.ride!.id, latLng);
      _state = _state.copyWith(
        isTransitioning: false,
        currentStep: ActiveRideStep.arrived,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isTransitioning: false,
        errorMessage: _errorMessage(e),
      );
      notifyListeners();
    }
  }

  Future<void> startRide() async {
    if (_state.isTransitioning) return;
    _state = _state.copyWith(isTransitioning: true, errorMessage: null);
    notifyListeners();
    try {
      await _repo.startRide(_state.ride!.id);
      _state = _state.copyWith(
        isTransitioning: false,
        currentStep: ActiveRideStep.inProgress,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isTransitioning: false,
        errorMessage: _errorMessage(e),
      );
      notifyListeners();
    }
  }

  Future<void> completeRide() async {
    if (_state.isTransitioning) return;
    _state = _state.copyWith(isTransitioning: true, errorMessage: null);
    notifyListeners();
    try {
      await _repo.completeRide(_state.ride!.id);
      _state = _state.copyWith(isTransitioning: false);
      notifyListeners();
      final completedRide = _state.ride;
      if (completedRide != null) {
        onCompleted?.call(completedRide);
      }
    } catch (e) {
      _state = _state.copyWith(
        isTransitioning: false,
        errorMessage: _errorMessage(e),
      );
      notifyListeners();
    }
  }

  Future<void> cancelRide() async {
    if (_state.isTransitioning) return;
    if (_state.currentStep == ActiveRideStep.inProgress) return;
    _state = _state.copyWith(isTransitioning: true, errorMessage: null);
    notifyListeners();
    try {
      await _repo.cancelRide(_state.ride!.id);
      _state = _state.copyWith(isTransitioning: false);
      notifyListeners();
      onCancelled?.call();
    } catch (e) {
      _state = _state.copyWith(
        isTransitioning: false,
        errorMessage: _errorMessage(e),
      );
      notifyListeners();
    }
  }

  void handleStatusChanged(RideStatus newStatus) {
    final newStep = ActiveRideState.mapStatusToStep(newStatus);
    _state = _state.copyWith(
      currentStep: newStep,
      isTransitioning: false,
      errorMessage: null,
    );
    notifyListeners();
    final ride = _state.ride;
    if (newStatus == RideStatus.completed && ride != null) {
      onCompleted?.call(ride);
    }
    if (newStatus == RideStatus.cancelled) onCancelled?.call();
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  String _errorMessage(dynamic e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    if (msg.contains('409')) {
      if (msg.contains('DRIVER_TOO_FAR')) {
        return 'You must be within 200 meters of the pickup location.';
      }
      return 'Cannot perform this action in current state.';
    }
    return msg.isEmpty ? 'Something went wrong. Try again.' : msg;
  }
}
