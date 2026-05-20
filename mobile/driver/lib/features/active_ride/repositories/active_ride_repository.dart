import 'package:sakai_api_client/sakai_api_client.dart';

/// Repository interface for active ride operations.
abstract class ActiveRideRepository {
  /// Gets the current active ride for the authenticated user.
  /// Returns null if no active ride exists.
  Future<RideResponse?> getActiveRide();

  /// Marks the driver as arrived at pickup (accepted → arrived).
  /// Requires driver's current GPS location for proximity validation.
  Future<void> arriveAtPickup(String rideId, LatLng driverLocation);

  /// Starts the ride (arrived → in_progress).
  Future<void> startRide(String rideId);

  /// Completes the ride (in_progress → completed).
  /// Requires driver's current GPS location for proximity validation.
  Future<void> completeRide(String rideId, LatLng driverLocation);

  /// Cancels the ride (any non-terminal state → cancelled).
  ///
  /// [reasonText] carries the driver's selected reason from the cancel
  /// sheet. Wire-level reason codes for driver actors land with the
  /// OpenAPI v2 bump (RFC v2 §8.6, API-1) — until then the picker
  /// serialises the wire code as a prefix in [reasonText] so the
  /// backend audit still records it.
  Future<void> cancelRide(String rideId, {String? reasonText});
}
