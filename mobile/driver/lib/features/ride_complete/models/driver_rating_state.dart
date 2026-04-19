/// State model for the driver's rating selection UI with auto-close support.
class DriverRatingState {
  const DriverRatingState({
    this.rideId = '',
    this.passengerName = '',
    this.stars = 0,
    this.feedback,
    this.isSubmitted = false,
    this.isSubmitting = false,
    this.error,
    this.countdownActive = false,
    this.secondsRemaining = 0,
    this.shouldNavigateHome = false,
  });

  final String rideId;
  final String passengerName;
  final int stars; // 0 = not selected, 1-5 = selected
  final String? feedback;
  final bool isSubmitted;
  final bool isSubmitting;
  final String? error;

  // Auto-close fields
  final bool countdownActive;
  final int secondsRemaining;
  final bool shouldNavigateHome;

  DriverRatingState copyWith({
    String? rideId,
    String? passengerName,
    int? stars,
    String? feedback,
    bool? isSubmitted,
    bool? isSubmitting,
    String? error,
    bool? countdownActive,
    int? secondsRemaining,
    bool? shouldNavigateHome,
  }) {
    return DriverRatingState(
      rideId: rideId ?? this.rideId,
      passengerName: passengerName ?? this.passengerName,
      stars: stars ?? this.stars,
      feedback: feedback ?? this.feedback,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      countdownActive: countdownActive ?? this.countdownActive,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      shouldNavigateHome: shouldNavigateHome ?? this.shouldNavigateHome,
    );
  }
}
