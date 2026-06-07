import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:passenger/features/ride_history/repositories/ride_history_repository_impl.dart';

import 'ride_history_repository_impl_test.mocks.dart';

@GenerateMocks([SakaiApiClient, RidesApi])
void main() {
  late MockSakaiApiClient mockClient;
  late MockRidesApi mockRidesApi;
  late RideHistoryRepositoryImpl repository;

  setUp(() {
    mockClient = MockSakaiApiClient();
    mockRidesApi = MockRidesApi();

    when(mockClient.getRidesApi()).thenReturn(mockRidesApi);
    repository = RideHistoryRepositoryImpl(mockClient);
  });

  group('RideHistoryRepositoryImpl.getRideHistory', () {
    test('successfully fetches ride history and updates hasMore', () async {
      final now = DateTime.now();
      final mockApiResponse = UserRideListResponse(
        (b) => b
          ..data.addAll([
            UserRideItem(
              (r) => r
                ..id = 'r-1'
                ..status = RideStatus.completed
                ..originAddress = 'A'
                ..destinationAddress = 'B'
                ..estimatedFare = 150.0
                ..paymentMethod = UserRideItemPaymentMethodEnum.cash
                ..createdAt = now
                ..updatedAt = now,
            ),
          ])
          ..pagination = PaginationMeta(
            (p) => p
              ..currentPage = 1
              ..totalPages = 2
              ..totalItems = 21
              ..limit = 20,
          ).toBuilder(),
      );

      when(
        mockRidesApi.rideList(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
          status: anyNamed('status'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: mockApiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final rides = await repository.getRideHistory(page: 1);

      expect(rides.length, 1);
      expect(rides.first.id, 'r-1');
      expect(repository.hasMore, isTrue);
    });

    test('sets hasMore to false when on last page', () async {
      final mockApiResponse = UserRideListResponse(
        (b) => b
          ..data.addAll([])
          ..pagination = PaginationMeta(
            (p) => p
              ..currentPage = 2
              ..totalPages = 2
              ..totalItems = 21
              ..limit = 20,
          ).toBuilder(),
      );

      when(
        mockRidesApi.rideList(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
          status: anyNamed('status'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: mockApiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      await repository.getRideHistory(page: 2);
      expect(repository.hasMore, isFalse);
    });
  });

  group('RideHistoryRepositoryImpl.getRideDetail', () {
    test('successfully fetches ride detail', () async {
      final now = DateTime.now();
      final passenger = $UserProfile(
        (b) => b
          ..id = 'u-1'
          ..email = 'rider@test.com'
          ..name = 'Rider'
          ..role = UserProfileRoleEnum.passenger
          ..createdAt = now,
      );

      final mockApiResponse = $RideResponse(
        (r) => r
          ..id = 'r-1'
          ..status = RideStatus.completed
          ..passenger = passenger
          ..originAddress = 'Origin'
          ..destinationAddress = 'Destination'
          ..origin = LatLng(
            (l) => l
              ..lat = 1.0
              ..lng = 1.0,
          ).toBuilder()
          ..destination = LatLng(
            (l) => l
              ..lat = 2.0
              ..lng = 2.0,
          ).toBuilder()
          ..createdAt = now
          ..updatedAt = now,
      );

      when(mockRidesApi.rideGet(rideId: 'r-1')).thenAnswer(
        (_) async => Response(
          data: mockApiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final detail = await repository.getRideDetail('r-1');
      expect(detail.id, 'r-1');
      expect(detail.status, RideStatus.completed);
    });

    test('throws RideHistoryException when response data is null', () async {
      when(mockRidesApi.rideGet(rideId: 'r-1')).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => repository.getRideDetail('r-1'),
        throwsA(
          isA<RideHistoryException>().having(
            (e) => e.userMessage,
            'userMessage',
            'Ride details not found.',
          ),
        ),
      );
    });
  });
}
