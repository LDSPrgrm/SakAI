/// Typed domain errors from ride operations.
class RideException implements Exception {
  const RideException({required this.userMessage, this.machineCode});

  final String userMessage;

  /// Matches `ErrorCode` values from the OpenAPI spec (e.g. `NO_DRIVERS_AVAILABLE`).
  final String? machineCode;

  @override
  String toString() => 'RideException[$machineCode]: $userMessage';
}
