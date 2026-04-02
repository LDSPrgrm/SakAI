import 'package:flutter/foundation.dart';

import '../repositories/ride_repository.dart';

/// MVVM ViewModel for [WaitingScreen].
///
/// Responsibilities:
/// - Track cancellation in-progress state.
/// - Call [RideRepository.cancelRide] and surface errors.
/// - Signal completion so the View can pop when done.
///
/// The View observes via [ListenableBuilder] and calls [cancel].
class WaitingViewModel extends ChangeNotifier {
  WaitingViewModel({
    required RideRepository rideRepository,
    required String rideId,
  })  : _rideRepository = rideRepository,
        _rideId = rideId;

  final RideRepository _rideRepository;
  final String _rideId;

  // ── State ──────────────────────────────────────────────────────────────────

  bool _cancelling = false;
  bool get cancelling => _cancelling;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Set to `true` once the ride has been successfully cancelled.
  /// The View should pop when this becomes true.
  bool _cancelled = false;
  bool get cancelled => _cancelled;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Cancels the ride. On success, sets [cancelled] = true.
  /// On failure, sets [errorMessage].
  Future<void> cancel() async {
    if (_cancelling) return;

    _cancelling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _rideRepository.cancelRide(_rideId);
      _cancelled = true;
    } catch (_) {
      _errorMessage = 'Could not cancel. Try again.';
    } finally {
      _cancelling = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
