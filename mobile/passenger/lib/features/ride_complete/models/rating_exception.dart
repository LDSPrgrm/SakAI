/// Typed domain errors from rating submission operations.
class RatingException implements Exception {
  const RatingException({required this.userMessage, this.machineCode});

  final String userMessage;

  /// Matches `ErrorCode` values from the OpenAPI spec (e.g. `ALREADY_RATED`).
  final String? machineCode;

  @override
  String toString() => 'RatingException[$machineCode]: $userMessage';
}
