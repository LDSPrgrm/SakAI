import '../models/cancellation_details.dart';

/// Abstract repository interface for cancelled ride operations.
abstract class CancelledRideRepository {
  /// Fetch cancellation details for a cancelled ride.
  Future<CancellationDetails> getCancellationDetails(String rideId);
}

/// Custom domain error for cancelled ride operations.
class CancelledRideException implements Exception {
  const CancelledRideException({
    required this.userMessage,
    this.machineCode,
  });

  final String userMessage;
  final String? machineCode;

  @override
  String toString() => 'CancelledRideException[$machineCode]: $userMessage';
}
