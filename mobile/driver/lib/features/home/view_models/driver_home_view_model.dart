import 'package:flutter/foundation.dart';

/// MVVM ViewModel for [DriverHomeScreen].
///
/// Responsibilities:
/// - Track driver online/offline status.
/// - Stub for going online (to be wired to a real Driver API in the future).
///
/// The View observes via [ListenableBuilder] and calls [goOnline] / [goOffline].
class DriverHomeViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  bool _online = false;
  bool get online => _online;

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Marks the driver as online.
  ///
  /// [vehiclePlate] will be sent to the driver API when wired.
  Future<void> goOnline(String vehiclePlate) async {
    if (_online || _loading) return;

    _loading = true;
    _errorMessage = null;
    notifyListeners();

    // TODO(REQ-driver): Call DriverRepository.goOnline(vehiclePlate) here.
    // Simulated async work until the real API is wired.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    _online = true;
    _loading = false;
    notifyListeners();
  }

  /// Marks the driver as offline.
  Future<void> goOffline() async {
    if (!_online || _loading) return;

    _loading = true;
    notifyListeners();

    // TODO(REQ-driver): Call DriverRepository.goOffline() here.
    await Future<void>.delayed(const Duration(milliseconds: 200));

    _online = false;
    _loading = false;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
