class DriverRatingState {
  final String rideId;
  final String passengerName;
  final int stars;
  final String feedback;
  final bool isSubmitted;

  const DriverRatingState({
    required this.rideId,
    required this.passengerName,
    this.stars = 0,
    this.feedback = '',
    this.isSubmitted = false,
  });

  DriverRatingState copyWith({
    int? stars,
    String? feedback,
    bool? isSubmitted,
  }) {
    return DriverRatingState(
      rideId: rideId,
      passengerName: passengerName,
      stars: stars ?? this.stars,
      feedback: feedback ?? this.feedback,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}
