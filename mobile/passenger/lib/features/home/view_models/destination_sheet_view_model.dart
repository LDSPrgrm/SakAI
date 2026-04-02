import 'package:flutter/foundation.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../repositories/geocoding_service.dart';

/// MVVM ViewModel for [DestinationSheet].
///
/// Responsibilities:
/// - Hold the geocoding busy/error state.
/// - Call [GeocodingService.geocode] and return the resolved [RideLocation].
/// - Keep all network access out of the View layer.
///
/// The View observes this via [ListenableBuilder] and calls [geocodeAndConfirm].
class DestinationSheetViewModel extends ChangeNotifier {
  DestinationSheetViewModel(this._geocodingService);

  final GeocodingService _geocodingService;

  // ── State ──────────────────────────────────────────────────────────────────

  bool _geocoding = false;
  bool get geocoding => _geocoding;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Geocodes [query] and returns a [RideLocation] on success, or `null` on
  /// error (caller should check [errorMessage]).
  Future<RideLocation?> geocodeAndConfirm(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _errorMessage = 'Please enter a destination.';
      notifyListeners();
      return null;
    }

    _geocoding = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loc = await _geocodingService.geocode(trimmed);
      return loc;
    } on GeocodingException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _geocoding = false;
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
