import 'package:sakai_api_client/sakai_api_client.dart';

/// Repository interface for driver-specific operations.
abstract class DriverRepository {
  /// Sets the driver's status to online.
  Future<void> goOnline();

  /// Sets the driver's status to offline.
  Future<void> goOffline();

  /// Updates the driver's current location.
  Future<void> updateLocation(double lat, double lng, {double? heading});

  /// Polls for any pending incoming ride offer (for missed offers on reconnect).
  /// Returns null if no pending offer exists.
  Future<RideResponse?> getIncomingRide();
}
