import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:passenger/features/ride_history/models/ride_detail.dart';
import 'package:passenger/features/ride_history/models/ride_history_item.dart';

RideHistoryItem makeItem({
  required RideStatus status,
  double? fare,
  double estimatedFare = 0,
}) {
  return RideHistoryItem(
    id: 'r1',
    status: status,
    originAddress: 'Origin',
    destinationAddress: 'Destination',
    fare: fare,
    estimatedFare: estimatedFare,
    paymentMethod: 'cash',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

RideDetail makeDetail({
  required RideStatus status,
  double? fare,
  double estimatedFare = 0,
}) {
  return RideDetail(
    id: 'r1',
    status: status,
    originAddress: 'Origin',
    destinationAddress: 'Destination',
    fare: fare,
    estimatedFare: estimatedFare,
    paymentMethod: 'cash',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    origin: LatLng((b) => b
      ..lat = 0
      ..lng = 0),
    destination: LatLng((b) => b
      ..lat = 0
      ..lng = 0),
  );
}

void main() {
  group('RideHistoryItem.displayFare', () {
    test('completed ride with actual fare shows ₱ amount', () {
      final item = makeItem(status: RideStatus.completed, fare: 123.5);
      expect(item.displayFare, '₱123.50');
    });
    test('completed ride with null fare shows Fare pending, not ₱0.00', () {
      final item = makeItem(status: RideStatus.completed, fare: null);
      expect(item.displayFare, 'Fare pending');
    });
    test('non-completed ride shows the estimate', () {
      final item = makeItem(
          status: RideStatus.requested, fare: null, estimatedFare: 100);
      expect(item.displayFare, '₱100.00');
    });
  });

  group('RideDetail.displayFare', () {
    test('completed ride with actual fare shows ₱ amount', () {
      final detail = makeDetail(status: RideStatus.completed, fare: 123.5);
      expect(detail.displayFare, '₱123.50');
    });
    test('completed ride with null fare shows Fare pending, not ₱0.00', () {
      final detail = makeDetail(status: RideStatus.completed, fare: null);
      expect(detail.displayFare, 'Fare pending');
    });
    test('non-completed ride shows the estimate', () {
      final detail = makeDetail(
          status: RideStatus.requested, fare: null, estimatedFare: 100);
      expect(detail.displayFare, '₱100.00');
    });
  });
}
