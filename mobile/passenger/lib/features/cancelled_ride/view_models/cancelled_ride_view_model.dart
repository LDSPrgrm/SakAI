import 'package:flutter/foundation.dart';

import '../models/cancellation_details.dart';
import '../repositories/cancelled_ride_repository.dart';

enum CancelledRideStatus { initial, loading, success, error }

class CancelledRideState {
  const CancelledRideState({
    this.status = CancelledRideStatus.initial,
    this.details,
    this.error,
    this.selectedReason,
    this.reasonText,
    this.isCancelling = false,
  });

  final CancelledRideStatus status;
  final CancellationDetails? details;
  final String? error;
  final CancellationReason? selectedReason;
  final String? reasonText;
  final bool isCancelling;

  CancelledRideState copyWith({
    CancelledRideStatus? status,
    CancellationDetails? details,
    String? error,
    bool clearError = false,
    CancellationReason? selectedReason,
    String? reasonText,
    bool? isCancelling,
  }) {
    return CancelledRideState(
      status: status ?? this.status,
      details: details ?? this.details,
      error: clearError ? null : (error ?? this.error),
      selectedReason: selectedReason ?? this.selectedReason,
      reasonText: reasonText ?? this.reasonText,
      isCancelling: isCancelling ?? this.isCancelling,
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

  /// Available cancellation reasons.
  List<CancellationReason> get reasonOptions =>
      CancellationReason.predefinedReasons;

  /// Select a cancellation reason.
  void selectReason(CancellationReason reason) {
    _state = _state.copyWith(selectedReason: reason);
    if (reason != CancellationReason.other) {
      _state = _state.copyWith(reasonText: null);
    }
    notifyListeners();
  }

  /// Set the reason text for "Other" option.
  void setReasonText(String? text) {
    _state = _state.copyWith(reasonText: text);
    notifyListeners();
  }

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

  /// Cancel the ride with the selected reason.
  Future<bool> cancelRideWithReason(String rideId) async {
    final selectedReason = _state.selectedReason;
    if (selectedReason == null) {
      _state = _state.copyWith(
        error: 'Please select a reason for cancellation.',
      );
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(isCancelling: true, clearError: true);
    notifyListeners();

    try {
      final reasonText = selectedReason == CancellationReason.other
          ? _state.reasonText
          : null;
      await _repo.cancelRide(
        rideId,
        reasonCode: selectedReason.code,
        reasonText: reasonText,
      );

      // Reload details after cancellation.
      await loadCancellation(rideId);
      return true;
    } catch (e) {
      final message = e is CancelledRideException
          ? e.userMessage
          : 'Failed to cancel ride.';
      _state = _state.copyWith(error: message, isCancelling: false);
      notifyListeners();
      return false;
    }
  }
}
