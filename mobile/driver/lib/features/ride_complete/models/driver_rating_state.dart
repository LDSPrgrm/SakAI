/// State model for the driver's rating selection UI.
class DriverRatingState {
  const DriverRatingState({
    required this.rideId,
    required this.passengerName,
    this.stars = 0,
    this.feedback,
    this.isSubmitted = false,
    this.isSubmitting = false,
    this.error,
  });

  final String rideId;
  final String passengerName;
  final int stars; // 0 = not selected, 1-5 = selected
  final String? feedback;
  final bool isSubmitted;
  final bool isSubmitting;
  final String? error;

  DriverRatingState copyWith({
    String? rideId,
    String? passengerName,
    int? stars,
    String? feedback,
    bool? isSubmitted,
    bool? isSubmitting,
    String? error,
  }) {
    return DriverRatingState(
      rideId: rideId ?? this.rideId,
      passengerName: passengerName ?? this.passengerName,
      stars: stars ?? this.stars,
      feedback: feedback ?? this.feedback,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}
