import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';


/// tests for DriverApi
void main() {
  final instance = SakaiApiClient().getDriverApi();

  group(DriverApi, () {
    // Get the current pending ride offer for this driver
    //
    // Returns the ride offer currently assigned to the driver, if any. Use this as a **polling fallback** when the WebSocket event may have been missed (e.g., app just reconnected). Returns `404` if no offer is pending. 
    //
    //Future<RideResponse> driverGetIncomingRide() async
    test('test driverGetIncomingRide', () async {
      // TODO
    });

    // Set driver online/offline status
    //
    // Toggles the driver's availability. Only users with `role=driver` may call this. Setting to `online` enters the driver into the matching pool. Setting to `offline` removes the driver immediately — they will not receive new rides. Cannot go offline while a ride is `in_progress`. 
    //
    //Future<DriverStatusResponse> driverSetStatus(DriverStatusRequest driverStatusRequest) async
    test('test driverSetStatus', () async {
      // TODO
    });

    // Update driver's current location
    //
    // Called periodically by the driver app (recommended every 3–5 seconds) while the driver is online. Location is stored in PostGIS and used for geospatial proximity matching.  **Rate limit:** 30 requests/min per driver. Exceeding this returns `429`.  During an active ride, each update also pushes a `driver.location_updated` WebSocket event to the passenger. 
    //
    //Future driverUpdateLocation(LocationUpdateRequest locationUpdateRequest) async
    test('test driverUpdateLocation', () async {
      // TODO
    });

  });
}
