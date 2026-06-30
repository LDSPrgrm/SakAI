/// Typed domain errors from driver rating submission operations.
class DriverRatingException implements Exception {
  const DriverRatingException({
    required this.userMessage,
    this.machineCode,
  });

  final String userMessage;

  /// Matches `ErrorCode` values from the OpenAPI spec (e.g. `ALREADY_RATED`).
  final String? machineCode;

  @override
  String toString() => 'DriverRatingException[$machineCode]: $userMessage';
}
