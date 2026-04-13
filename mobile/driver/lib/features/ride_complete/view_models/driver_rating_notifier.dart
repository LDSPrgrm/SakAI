import 'package:flutter/foundation.dart';

import '../models/driver_rating_state.dart';
import '../repositories/driver_rating_repository.dart';

/// ChangeNotifier managing the driver's rating UI state.
class DriverRatingNotifier extends ChangeNotifier {
  DriverRatingNotifier({required DriverRatingRepository repository, required DriverRatingState initialState})
      : _repository = repository,
        _state = initialState;

  final DriverRatingRepository _repository;
  DriverRatingState _state;

  DriverRatingState get state => _state;

  void setStars(int stars) {
    _state = _state.copyWith(stars: stars, error: null);
    notifyListeners();
  }

  void setFeedback(String? feedback) {
    _state = _state.copyWith(feedback: feedback);
    notifyListeners();
  }

  Future<bool> submitRating() async {
    if (_state.stars < 1 || _state.isSubmitting) return false;

    _state = _state.copyWith(isSubmitting: true, error: null);
    notifyListeners();

    try {
      await _repository.submitRating(
        _state.rideId,
        _state.stars,
        (_state.feedback != null && _state.feedback!.isNotEmpty)
            ? _state.feedback
            : null,
      );
      _state = _state.copyWith(isSubmitted: true, isSubmitting: false);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit rating. Please try again.',
      );
      notifyListeners();
      return false;
    }
  }

  void skipRating() {
    _state = _state.copyWith(isSubmitted: true);
    notifyListeners();
  }
}
