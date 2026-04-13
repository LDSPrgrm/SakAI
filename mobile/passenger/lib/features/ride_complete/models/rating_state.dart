/// State model for the rating selection UI.
class RatingState {
  const RatingState({
    this.stars = 0,
    this.feedback,
    this.submitted = false,
    this.skipped = false,
    this.submitting = false,
    this.error,
  });

  final int stars; // 0 = not selected, 1-5 = selected
  final String? feedback;
  final bool submitted;
  final bool skipped;
  final bool submitting;
  final String? error;

  RatingState copyWith({
    int? stars,
    String? feedback,
    bool? submitted,
    bool? skipped,
    bool? submitting,
    String? error,
  }) {
    return RatingState(
      stars: stars ?? this.stars,
      feedback: feedback ?? this.feedback,
      submitted: submitted ?? this.submitted,
      skipped: skipped ?? this.skipped,
      submitting: submitting ?? this.submitting,
      error: error,
    );
  }
}
