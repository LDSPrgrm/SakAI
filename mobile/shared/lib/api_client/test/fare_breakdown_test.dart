import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

// tests for FareBreakdown
void main() {
  final instance = FareBreakdownBuilder();
  // TODO add properties to the builder and call build()

  group(FareBreakdown, () {
    // double baseFare
    test('to test the property `baseFare`', () async {
      // TODO
    });

    // double distanceCharge
    test('to test the property `distanceCharge`', () async {
      // TODO
    });

    // double timeCharge
    test('to test the property `timeCharge`', () async {
      // TODO
    });

    // double bookingFee
    test('to test the property `bookingFee`', () async {
      // TODO
    });

    // Active surge multiplier (1.0 means no surge). Omitted when 1.0.
    // double surgeMultiplier
    test('to test the property `surgeMultiplier`', () async {
      // TODO
    });

    // Total promo / loyalty discount applied. Omitted when zero.
    // double discount
    test('to test the property `discount`', () async {
      // TODO
    });

  });
}
