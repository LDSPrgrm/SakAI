import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:passenger/features/profile/repositories/profile_repository.dart';

import 'profile_repository_impl_test.mocks.dart';

@GenerateMocks([SakaiApiClient, UsersApi])
void main() {
  late MockSakaiApiClient mockClient;
  late MockUsersApi mockUsersApi;
  late ProfileRepositoryImpl repository;

  setUp(() {
    mockClient = MockSakaiApiClient();
    mockUsersApi = MockUsersApi();

    when(mockClient.getUsersApi()).thenReturn(mockUsersApi);
    repository = ProfileRepositoryImpl(mockClient);
  });

  group('ProfileRepositoryImpl.getProfile', () {
    test('successfully fetches profile and rating', () async {
      final now = DateTime.now();
      final user = $UserProfile(
        (b) => b
          ..id = 'u-1'
          ..email = 'rider@test.com'
          ..name = 'Test Rider'
          ..role = UserProfileRoleEnum.passenger
          ..createdAt = now,
      );

      final ratingResponse = UserRatingResponse(
        (b) => b
          ..userId = 'u-1'
          ..averageRating = 4.8
          ..ratingCount = 10,
      );

      when(mockUsersApi.usersGetMe()).thenAnswer(
        (_) async => Response(
          data: user,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      when(mockUsersApi.getUserRating(userId: 'u-1')).thenAnswer(
        (_) async => Response(
          data: ratingResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final profile = await repository.getProfile();

      expect(profile.id, 'u-1');
      expect(profile.name, 'Test Rider');
      expect(profile.rating, 4.8);
      verify(mockUsersApi.usersGetMe()).called(1);
      verify(mockUsersApi.getUserRating(userId: 'u-1')).called(1);
    });

    test('returns profile even if rating fetch fails', () async {
      final now = DateTime.now();
      final user = $UserProfile(
        (b) => b
          ..id = 'u-1'
          ..email = 'rider@test.com'
          ..name = 'Test Rider'
          ..role = UserProfileRoleEnum.passenger
          ..createdAt = now,
      );

      when(mockUsersApi.usersGetMe()).thenAnswer(
        (_) async => Response(
          data: user,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      when(
        mockUsersApi.getUserRating(userId: 'u-1'),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final profile = await repository.getProfile();

      expect(profile.id, 'u-1');
      expect(profile.rating, isNull);
    });

    test('throws ProfileNotFoundError when response data is null', () async {
      when(mockUsersApi.usersGetMe()).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => repository.getProfile(),
        throwsA(
          isA<ProfileNotFoundError>().having(
            (e) => e.message,
            'message',
            'Profile not found',
          ),
        ),
      );
    });
  });
}
