import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart' show apiClientProvider;
import '../models/driver_rating_state.dart' as local;
import '../repositories/driver_rating_repository.dart';
import '../repositories/driver_rating_repository_impl.dart';

/// Notifier managing the driver's rating UI state with auto-close support.
class DriverRatingNotifier extends Notifier<local.DriverRatingState> {
  Timer? _autoCloseTimer;

  @override
  local.DriverRatingState build() {
    // Start auto-close timer when provider is created
    _startAutoCloseTimer();
    return const local.DriverRatingState();
  }

  /// Start countdown timer for auto-navigation (15 seconds after submission).
  void _startAutoCloseTimer() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownActive && state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else if (state.countdownActive && state.secondsRemaining <= 0) {
        _autoCloseTimer?.cancel();
        state = state.copyWith(shouldNavigateHome: true);
      }
    });
  }

  /// Initialize with ride context (called by screen).
  void init({String rideId = '', String passengerName = ''}) {
    state = state.copyWith(rideId: rideId, passengerName: passengerName);
  }

  DriverRatingRepository get _repo => ref.read(driverRatingRepositoryProvider);

  void setStars(int stars) {
    state = state.copyWith(stars: stars, error: null);
  }

  void setFeedback(String feedback) {
    state = state.copyWith(feedback: feedback.isEmpty ? null : feedback);
  }

  Future<bool> submitRating() async {
    if (state.stars < 1 || state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _repo.submitRating(
        state.rideId,
        state.stars,
        state.feedback?.isEmpty ?? true ? null : state.feedback,
      );
      state = state.copyWith(
        isSubmitted: true,
        isSubmitting: false,
        countdownActive: true,
        secondsRemaining: 15,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit rating. Please try again.',
      );
      return false;
    }
  }

  void skipRating() {
    _autoCloseTimer?.cancel();
    state = state.copyWith(
      isSubmitted: true,
      countdownActive: true,
      secondsRemaining: 5,
    );
  }

  /// Navigate home manually (resets timer).
  void navigateHome() {
    _autoCloseTimer?.cancel();
    state = state.copyWith(shouldNavigateHome: true);
  }
}

final driverRatingNotifierProvider =
    NotifierProvider<DriverRatingNotifier, local.DriverRatingState>(
      DriverRatingNotifier.new,
    );

/// Repository provider for driver rating.
final driverRatingRepositoryProvider = Provider<DriverRatingRepository>((ref) {
  return DriverRatingRepositoryImpl(ref.watch(apiClientProvider));
});
