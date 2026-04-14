/// State model for the rating selection UI with auto-close support.
class RatingState {
  const RatingState({
    this.stars = 0,
    this.feedback,
    this.submitted = false,
    this.skipped = false,
    this.submitting = false,
    this.error,
    this.countdownActive = false,
    this.secondsRemaining = 0,
  });

  final int stars; // 0 = not selected, 1-5 = selected
  final String? feedback;
  final bool submitted;
  final bool skipped;
  final bool submitting;
  final String? error;

  // Auto-close fields
  final bool countdownActive;
  final int secondsRemaining;

  RatingState copyWith({
    int? stars,
    String? feedback,
    bool? submitted,
    bool? skipped,
    bool? submitting,
    String? error,
    bool? countdownActive,
    int? secondsRemaining,
  }) {
    return RatingState(
      stars: stars ?? this.stars,
      feedback: feedback ?? this.feedback,
      submitted: submitted ?? this.submitted,
      skipped: skipped ?? this.skipped,
      submitting: submitting ?? this.submitting,
      error: error,
      countdownActive: countdownActive ?? this.countdownActive,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }
}
