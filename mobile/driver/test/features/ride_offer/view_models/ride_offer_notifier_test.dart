import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import 'package:driver/features/ride_offer/models/ride_offer_state.dart';

void main() {
  group('RideOfferState', () {
    test('calculates countdown from expiresAt', () {
      final expiresAt = DateTime.now().add(const Duration(seconds: 25));
      final state = RideOfferState(
        rideId: 'test-123',
        passenger: $UserProfile(
          (b) => b
            ..id = 'user-123'
            ..name = 'John Doe'
            ..email = 'john@example.com'
            ..role = UserProfileRoleEnum.passenger
            ..createdAt = DateTime.now(),
        ),
        origin: LatLng(
          (b) => b
            ..lat = 14.5995
            ..lng = 120.9842,
        ),
        destination: LatLng(
          (b) => b
            ..lat = 14.6090
            ..lng = 121.0200,
        ),
        expiresAt: expiresAt,
        countdownSeconds: 25,
      );

      expect(state.countdownSeconds, 25);
      expect(state.rideId, 'test-123');
    });

    test('copyWith updates countdown', () {
      final expiresAt = DateTime.now().add(const Duration(seconds: 30));
      final state = RideOfferState(
        rideId: 'test-123',
        passenger: $UserProfile(
          (b) => b
            ..id = 'user-123'
            ..name = 'John Doe'
            ..email = 'john@example.com'
            ..role = UserProfileRoleEnum.passenger
            ..createdAt = DateTime.now(),
        ),
        origin: LatLng(
          (b) => b
            ..lat = 14.5995
            ..lng = 120.9842,
        ),
        destination: LatLng(
          (b) => b
            ..lat = 14.6090
            ..lng = 121.0200,
        ),
        expiresAt: expiresAt,
      );

      final updated = state.copyWith(countdownSeconds: 15);
      expect(updated.countdownSeconds, 15);
      expect(updated.rideId, 'test-123'); // unchanged
    });

    test('haversine distance is approximately correct', () {
      // Distance from Manila to Makati is roughly 5-6 km
      final state = RideOfferState(
        rideId: 'test-123',
        passenger: $UserProfile(
          (b) => b
            ..id = 'user-123'
            ..name = 'John Doe'
            ..email = 'john@example.com'
            ..role = UserProfileRoleEnum.passenger
            ..createdAt = DateTime.now(),
        ),
        origin: LatLng(
          (b) => b
            ..lat = 14.5995
            ..lng = 120.9842,
        ),
        destination: LatLng(
          (b) => b
            ..lat = 14.6090
            ..lng = 121.0200,
        ),
        expiresAt: DateTime.now().add(const Duration(seconds: 30)),
        distanceToPickupMeters: 5000, // ~5km
      );

      expect(state.distanceToPickupMeters, 5000);
    });
  });
}
