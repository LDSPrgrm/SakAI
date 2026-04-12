import 'package:flutter/foundation.dart';

import '../models/cancellation_details.dart';
import '../repositories/cancelled_ride_repository.dart';

enum CancelledRideStatus { initial, loading, success, error }

class CancelledRideState {
  const CancelledRideState({
    this.status = CancelledRideStatus.initial,
    this.details,
    this.error,
  });

  final CancelledRideStatus status;
  final CancellationDetails? details;
  final String? error;

  CancelledRideState copyWith({
    CancelledRideStatus? status,
    CancellationDetails? details,
    String? error,
    bool clearError = false,
  }) {
    return CancelledRideState(
      status: status ?? this.status,
      details: details ?? this.details,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// ViewModel for the cancelled ride screen.
/// Uses ChangeNotifier pattern for state management.
class CancelledRideViewModel extends ChangeNotifier {
  CancelledRideViewModel({required CancelledRideRepository repository})
    : _repo = repository;

  final CancelledRideRepository _repo;
  CancelledRideState _state = const CancelledRideState();

  CancelledRideState get state => _state;

  /// Load cancellation details for the given ride.
  Future<void> loadCancellation(String rideId) async {
    _state = _state.copyWith(
      status: CancelledRideStatus.loading,
      clearError: true,
    );
    notifyListeners();

    try {
      final details = await _repo.getCancellationDetails(rideId);
      _state = _state.copyWith(
        status: CancelledRideStatus.success,
        details: details,
      );
    } catch (e) {
      final message = e is CancelledRideException
          ? e.userMessage
          : 'Failed to load cancellation details.';
      _state = _state.copyWith(
        status: CancelledRideStatus.error,
        error: message,
      );
    }
    notifyListeners();
  }
}
