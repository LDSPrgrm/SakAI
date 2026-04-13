import 'package:flutter/foundation.dart';

import '../models/ride_exception.dart';
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
  }) : _rideRepository = rideRepository,
       _rideId = rideId;

  final RideRepository _rideRepository;
  final String _rideId;

  bool _disposed = false;

  // ── State ──────────────────────────────────────────────────────────────────

  bool _cancelling = false;
  bool get cancelling => _cancelling;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Set to `true` once the ride has been successfully cancelled.
  /// The View should pop when this becomes true.
  bool _cancelled = false;
  bool get cancelled => _cancelled;

  /// External signal (e.g. from WebSocket) that the ride was cancelled.
  /// Ensures the UI reflects the cancellation even if the HTTP response is slow or lost.
  void onRideCancelledByServer() {
    debugPrint('[WaitingVM] onRideCancelledByServer()');
    if (!_cancelled) {
      _cancelled = true;
      _safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Cancels the ride. On success, sets [cancelled] = true.
  /// On failure, sets [errorMessage].
  Future<void> cancel() async {
    debugPrint('[WaitingVM] cancel() called, _cancelling=$_cancelling');
    if (_cancelling) return;

    _cancelling = true;
    _errorMessage = null;
    debugPrint('[WaitingVM] calling notifyListeners (start cancelling)');
    _safeNotifyListeners();

    try {
      debugPrint('[WaitingVM] calling cancelRide for $_rideId');
      await _rideRepository.cancelRide(_rideId);
      debugPrint('[WaitingVM] cancelRide succeeded');
      _cancelled = true;
    } catch (e, st) {
      debugPrint('[WaitingVM] cancelRide failed: $e');
      debugPrint('[WaitingVM] stack: $st');
      if (e is RideException) {
        debugPrint(
          '[WaitingVM] RideException: code=${e.machineCode}, msg=${e.userMessage}',
        );
      }
      if (e is RideException && e.userMessage.isNotEmpty) {
        _errorMessage = e.userMessage;
      } else {
        _errorMessage = 'Could not cancel. Try again.';
      }
    } finally {
      _cancelling = false;
      debugPrint(
        '[WaitingVM] calling notifyListeners (done, cancelled=$_cancelled, error=$_errorMessage)',
      );
      _safeNotifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      _safeNotifyListeners();
    }
  }
}
