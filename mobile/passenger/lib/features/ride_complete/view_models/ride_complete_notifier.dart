import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart' show rideCompleteRepositoryProvider;
import '../models/rating_exception.dart';
import '../models/rating_state.dart';
import '../models/ride_completion_summary.dart';
import '../models/tip_option.dart';
import '../repositories/ride_complete_repository.dart';

/// State for the RideCompleteNotifier.
class RideCompleteState {
  const RideCompleteState({
    this.loading = true,
    this.summary,
    this.rating = const RatingState(),
    this.selectedTip,
    this.customTipAmount,
    this.error,
    this.showThankYou = false,
    this.shouldNavigateHome = false,
  });

  final bool loading;
  final RideCompletionSummary? summary;
  final RatingState rating;
  final TipOption? selectedTip;
  final double? customTipAmount;
  final String? error;
  final bool showThankYou;
  final bool shouldNavigateHome;

  double get finalTotal {
    if (summary == null) return 0;
    double total = summary!.baseFare;
    if (selectedTip != null) {
      total += selectedTip!.amount;
    } else if (customTipAmount != null) {
      total += customTipAmount!;
    }
    return total;
  }

  RideCompleteState copyWith({
    bool? loading,
    RideCompletionSummary? summary,
    RatingState? rating,
    TipOption? selectedTip,
    double? customTipAmount,
    String? error,
    bool? showThankYou,
    bool? shouldNavigateHome,
  }) {
    return RideCompleteState(
      loading: loading ?? this.loading,
      summary: summary ?? this.summary,
      rating: rating ?? this.rating,
      selectedTip: selectedTip ?? this.selectedTip,
      customTipAmount: customTipAmount ?? this.customTipAmount,
      error: error,
      showThankYou: showThankYou ?? this.showThankYou,
      shouldNavigateHome: shouldNavigateHome ?? this.shouldNavigateHome,
    );
  }
}

/// Notifier managing the ride completion screen state.
class RideCompleteNotifier extends Notifier<RideCompleteState> {
  Timer? _autoCloseTimer;

  @override
  RideCompleteState build() {
    // Start auto-close timer when provider is created
    _startAutoCloseTimer();
    return const RideCompleteState();
  }

  /// Start countdown timer for auto-navigation.
  void _startAutoCloseTimer() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.rating.countdownActive && state.rating.secondsRemaining > 0) {
        state = state.copyWith(
          rating: state.rating.copyWith(
            secondsRemaining: state.rating.secondsRemaining - 1,
          ),
        );
      } else if (state.rating.countdownActive &&
          state.rating.secondsRemaining <= 0) {
        _autoCloseTimer?.cancel();
        state = state.copyWith(shouldNavigateHome: true);
      }
    });
  }

  /// Initialize the notifier with the ride ID (called by the screen).
  void init(String rideId) {
    // Called from initState of the screen; loadRide is called separately.
  }

  RideCompleteRepository get _repo => ref.read(rideCompleteRepositoryProvider);

  /// Load ride details when screen initializes.
  Future<void> loadRide(String rideId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final ride = await _repo.getRideDetails(rideId);
      final summary = RideCompletionSummary.fromRideResponse(ride);
      state = state.copyWith(loading: false, summary: summary);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Failed to load ride details',
      );
    }
  }

  // --- Rating ---

  void setStars(int stars) {
    state = state.copyWith(rating: state.rating.copyWith(stars: stars));
  }

  void setFeedback(String feedback) {
    state = state.copyWith(rating: state.rating.copyWith(feedback: feedback));
  }

  Future<bool> submitRating(String rideId) async {
    if (state.rating.stars < 1 || state.rating.stars > 5) return false;
    if (state.rating.stars == 0) return false;

    state = state.copyWith(
      rating: state.rating.copyWith(submitting: true, error: null),
    );
    try {
      await _repo.submitRating(
        rideId,
        state.rating.stars,
        state.rating.feedback?.isEmpty ?? true ? null : state.rating.feedback,
      );
      state = state.copyWith(
        rating: state.rating.copyWith(
          submitted: true,
          submitting: false,
          countdownActive: true,
          secondsRemaining: 15,
        ),
        showThankYou: true,
      );
      return true;
    } on RatingException catch (e) {
      state = state.copyWith(
        rating: state.rating.copyWith(submitting: false, error: e.userMessage),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        rating: state.rating.copyWith(
          submitting: false,
          error: 'Failed to submit rating. Please try again.',
        ),
      );
      return false;
    }
  }

  void skipRating() {
    state = state.copyWith(
      rating: state.rating.copyWith(
        skipped: true,
        countdownActive: true,
        secondsRemaining: 5,
      ),
    );
  }

  // --- Tip ---

  void selectPresetTip(TipOption tip) {
    state = state.copyWith(selectedTip: tip, customTipAmount: null);
  }

  void setCustomTip(double amount) {
    state = state.copyWith(customTipAmount: amount, selectedTip: null);
  }

  void skipTip() {
    state = state.copyWith(selectedTip: null, customTipAmount: null);
  }

  Future<bool> submitTip(String rideId) async {
    final tipAmount = state.selectedTip?.amount ?? state.customTipAmount ?? 0;
    if (tipAmount <= 0) return true; // No tip to submit

    try {
      await _repo.addTip(rideId, tipAmount);
      state = state.copyWith(
        summary: state.summary?.copyWith(tipAmount: tipAmount),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to process tip. You can add a tip later.',
      );
      return false;
    }
  }
}

final rideCompleteNotifierProvider =
    NotifierProvider<RideCompleteNotifier, RideCompleteState>(
      RideCompleteNotifier.new,
    );
