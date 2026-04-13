import 'package:sakai_shared/sakai_shared.dart';

/// Port for ride operations (Clean Architecture domain boundary).
/// Pure Dart — no Flutter, no dio.
abstract class RideRepository {
  /// Request a new ride.
  ///
  /// [idempotencyKey] must be a UUID generated once per request attempt
  /// and reused on retries. See REQ-3.2.4.
  /// [rideType] specifies the vehicle type (motorcycle/car/tricycle).
  /// [paymentMethod] specifies the payment method (cash/card).
  Future<RideEntity> requestRide({
    required RideLocation origin,
    required RideLocation destination,
    String? notes,
    required String idempotencyKey,
    VehicleType? rideType,
    String? paymentMethod,
  });

  /// Re-hydrate local state after a cold start or WS reconnect.
  /// Returns `null` when no active ride exists (API 404).
  Future<RideEntity?> getActiveRide();

  /// Cancel the given ride with an optional reason code and text.
  Future<void> cancelRide(
    String rideId, {
    String? reasonCode,
    String? reasonText,
  });
}
