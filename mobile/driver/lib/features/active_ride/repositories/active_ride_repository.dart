import 'package:sakai_api_client/sakai_api_client.dart';

/// Repository interface for active ride operations.
abstract class ActiveRideRepository {
  /// Gets the current active ride for the authenticated user.
  /// Returns null if no active ride exists.
  Future<RideResponse?> getActiveRide();

  /// Marks the driver as arrived at pickup (accepted → arrived).
  Future<void> arriveAtPickup(String rideId);

  /// Starts the ride (arrived → in_progress).
  Future<void> startRide(String rideId);

  /// Completes the ride (in_progress → completed).
  Future<void> completeRide(String rideId);

  /// Cancels the ride (any non-terminal state → cancelled).
  Future<void> cancelRide(String rideId);
}
