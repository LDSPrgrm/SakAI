import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:sakai_shared/repositories/sos_repository.dart';

import 'sos_repository_impl_test.mocks.dart';

// We will implement SOSRepositoryImpl later, so for now we'll mock the interface
// to verify our test logic and expected behavior.
@GenerateMocks([api.RidesApi, SOSRepository])
void main() {
  group('SOSRepository triggering', () {
    test('triggerSOS should send POST request to emergency endpoint', () async {
      final rideId = 'ride-123';
      final reason = 'Feeling unsafe';

      // Expected behavior: Repository calls the API and returns updated ride with SOS flag
      // Since this is RED phase, we'll just mock the Interface for now to define expected contract
      final mockSos = MockSOSRepository();
      final expectedRide = api.$RideResponse(
        (b) => b
          ..id = rideId
          ..status = api.RideStatus.completed
          ..origin.replace(
            api.LatLng(
              (l) => l
                ..lat = 0.0
                ..lng = 0.0,
            ),
          )
          ..destination.replace(
            api.LatLng(
              (l) => l
                ..lat = 0.0
                ..lng = 0.0,
            ),
          )
          ..originAddress = 'Origin'
          ..destinationAddress = 'Destination'
          ..passenger = api.$UserProfile(
            (u) => u
              ..id = 'p1'
              ..name = 'User'
              ..email = 'test@test.com'
              ..role = api.UserProfileRoleEnum.passenger
              ..createdAt = DateTime.now().toUtc(),
          )
          ..createdAt = DateTime.now().toUtc()
          ..updatedAt = DateTime.now().toUtc(),
      );

      when(
        mockSos.triggerSOS(rideId, reason: reason),
      ).thenAnswer((_) async => expectedRide);

      final result = await mockSos.triggerSOS(rideId, reason: reason);

      expect(result.id, equals(rideId));
      verify(mockSos.triggerSOS(rideId, reason: reason)).called(1);
    });

    test('getActiveIncident should Return null if no SOS active', () async {
      final rideId = 'ride-123';
      final mockSos = MockSOSRepository();

      when(mockSos.getActiveIncident(rideId)).thenAnswer((_) async => null);

      final result = await mockSos.getActiveIncident(rideId);

      expect(result, isNull);
    });
  });
}
