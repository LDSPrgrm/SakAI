import 'package:sakai_shared/sakai_shared.dart';

/// Port for ride operations (Clean Architecture domain boundary).
/// Pure Dart — no Flutter, no dio.
abstract class RideRepository {
  /// Request a new ride.
  ///
  /// [idempotencyKey] must be a UUID generated once per request attempt
  /// and reused on retries. See REQ-3.2.4.
  Future<RideEntity> requestRide({
    required RideLocation origin,
    required RideLocation destination,
    String? notes,
    required String idempotencyKey,
  });

  /// Re-hydrate local state after a cold start or WS reconnect.
  /// Returns `null` when no active ride exists (API 404).
  Future<RideEntity?> getActiveRide();

  /// Cancel the given ride.
  Future<void> cancelRide(String rideId);
}
