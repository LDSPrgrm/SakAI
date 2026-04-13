import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

// tests for EarningsItem
void main() {
  final instance = EarningsItemBuilder();
  // TODO add properties to the builder and call build()

  group(EarningsItem, () {
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // String rideId
    test('to test the property `rideId`', () async {
      // TODO
    });

    // Driver's share of the fare (before commission)
    // double fareAmount
    test('to test the property `fareAmount`', () async {
      // TODO
    });

    // Tip amount (0 if no tip)
    // double tipAmount
    test('to test the property `tipAmount`', () async {
      // TODO
    });

    // Total earnings for this ride (fare + tip)
    // double totalAmount
    test('to test the property `totalAmount`', () async {
      // TODO
    });

    // ISO 4217 currency code
    // String currency (default value: 'USD')
    test('to test the property `currency`', () async {
      // TODO
    });

    // When the ride was completed
    // DateTime completedAt
    test('to test the property `completedAt`', () async {
      // TODO
    });

  });
}
