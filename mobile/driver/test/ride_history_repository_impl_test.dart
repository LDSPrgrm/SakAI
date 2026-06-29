import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:driver/features/ride_history/repositories/ride_history_repository_impl.dart';
import 'package:driver/features/ride_history/repositories/ride_history_repository.dart';
import 'package:dio/dio.dart';

// Import generated mock
import 'ride_history_repository_impl_test.mocks.dart';

@GenerateMocks([DriverApi])
void main() {
  late MockDriverApi mockDriverApi;
  late RideHistoryRepository repository;

  setUp(() {
    mockDriverApi = MockDriverApi();
    repository = RideHistoryRepositoryImpl(mockDriverApi);
  });

  group('RideHistoryRepository.getRideHistory', () {
    test('successfully retrieves ride history', () async {
      final now = DateTime.now();
      final mockApiResponse = AdminListDriverRides200Response(
        (b) => b
          ..rides.addAll([
            $RideResponse(
              (r) => r
                ..id = 'ride-1'
                ..status = RideStatus.completed
                ..originAddress = 'A'
                ..destinationAddress = 'B'
                ..passenger =
                    ($UserProfileBuilder()
                          ..id = 'user-1'
                          ..email = 'test@example.com'
                          ..name = 'Test User'
                          ..role = UserProfileRoleEnum.passenger
                          ..createdAt = now)
                        .build()
                ..origin = (LatLngBuilder()
                  ..lat = 0.0
                  ..lng = 0.0)
                ..destination = (LatLngBuilder()
                  ..lat = 0.0
                  ..lng = 0.0)
                ..createdAt = now
                ..updatedAt = now,
            ),
          ]),
      );

      when(
        mockDriverApi.adminListDriverRides(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: mockApiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final rides = await repository.getRideHistory();
      expect(rides.length, 1);
      expect(rides.first.id, 'ride-1');
    });
  });
}
