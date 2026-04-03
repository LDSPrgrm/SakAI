/// Repository interface for driver-specific operations.
abstract class DriverRepository {
  /// Sets the driver's status to online.
  Future<void> goOnline();

  /// Sets the driver's status to offline.
  Future<void> goOffline();

  /// Updates the driver's current location.
  Future<void> updateLocation(double lat, double lng, {double? heading});
}
