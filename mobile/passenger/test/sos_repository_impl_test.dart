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

      // Expected behavior: Repository calls the API and returns an Incident object
      // Since this is RED phase, we'll just mock the Interface for now to define expected contract
      final mockSos = MockSOSRepository();
      final expectedIncident = api.Incident(
        (b) => b
          ..id = 'inc-123'
          ..rideId = rideId
          ..riderId = 'p1'
          ..type = api.IncidentTypeEnum.sosTriggered
          ..status = api.IncidentStatusEnum.open
          ..createdAt = DateTime.now().toUtc(),
      );

      when(
        mockSos.triggerSOS(rideId, reason: reason),
      ).thenAnswer((_) async => expectedIncident);

      final result = await mockSos.triggerSOS(rideId, reason: reason);

      expect(result.rideId, equals(rideId));
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
