import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

// tests for AdminRideItem
void main() {
  final instance = AdminRideItemBuilder();
  // TODO add properties to the builder and call build()

  group(AdminRideItem, () {
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // RideStatus status
    test('to test the property `status`', () async {
      // TODO
    });

    // UserProfile passenger
    test('to test the property `passenger`', () async {
      // TODO
    });

    // Null until a driver is matched and accepts.
    // DriverSummary driver
    test('to test the property `driver`', () async {
      // TODO
    });

    // LatLng origin
    test('to test the property `origin`', () async {
      // TODO
    });

    // LatLng destination
    test('to test the property `destination`', () async {
      // TODO
    });

    // String originAddress
    test('to test the property `originAddress`', () async {
      // TODO
    });

    // String destinationAddress
    test('to test the property `destinationAddress`', () async {
      // TODO
    });

    // String notes
    test('to test the property `notes`', () async {
      // TODO
    });

    // Set only when status is `cancelled`
    // String cancelledBy
    test('to test the property `cancelledBy`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // DateTime updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });

    // String passengerName
    test('to test the property `passengerName`', () async {
      // TODO
    });

    // String driverName
    test('to test the property `driverName`', () async {
      // TODO
    });

    // Final fare charged for the ride (null for non-completed rides)
    // num totalFare
    test('to test the property `totalFare`', () async {
      // TODO
    });

    // Payment method used; populated once the ride is completed
    // String paymentMethod
    test('to test the property `paymentMethod`', () async {
      // TODO
    });

  });
}
