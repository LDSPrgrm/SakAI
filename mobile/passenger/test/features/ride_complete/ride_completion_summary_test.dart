import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/ride_complete/models/ride_completion_summary.dart';
import 'package:sakai_shared/sakai_shared.dart';

void main() {
  UserProfile mockPassenger(DateTime now) => $UserProfile(
    (u) => u
      ..id = 'user-1'
      ..email = 'test@example.com'
      ..name = 'Test User'
      ..role = UserProfileRoleEnum.passenger
      ..createdAt = now,
  );

  RideResponse buildRide({required DateTime now, double? fare}) {
    return $RideResponse(
      (b) => b
        ..id = 'ride-1'
        ..status = RideStatus.completed
        ..originAddress = 'Origin'
        ..destinationAddress = 'Dest'
        ..fare = fare
        ..origin.replace(
          LatLng(
            (l) => l
              ..lat = 0
              ..lng = 0,
          ),
        )
        ..destination.replace(
          LatLng(
            (l) => l
              ..lat = 1
              ..lng = 1,
          ),
        )
        ..passenger = mockPassenger(now)
        ..createdAt = now
        ..updatedAt = now,
    );
  }

  group('RideCompletionSummary.fromRideResponse', () {
    test('reads fare from backend payload (no more 0.0 placeholder)', () {
      final now = DateTime.now().toUtc();
      final summary = RideCompletionSummary.fromRideResponse(
        buildRide(now: now, fare: 234.5),
      );
      expect(summary.baseFare, 234.5);
      expect(summary.finalTotal, 234.5);
    });

    test('falls back to 0.0 when backend omits fare', () {
      final now = DateTime.now().toUtc();
      final summary = RideCompletionSummary.fromRideResponse(
        buildRide(now: now, fare: null),
      );
      expect(summary.baseFare, 0.0);
    });
  });
}
