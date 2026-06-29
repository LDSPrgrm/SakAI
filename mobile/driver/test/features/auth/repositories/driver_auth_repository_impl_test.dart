import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:driver/features/auth/repositories/driver_auth_repository_impl.dart';
import 'package:driver/features/auth/models/auth_exception.dart';
import 'package:driver/features/auth/models/session_check_result.dart';
import 'package:built_value/serializer.dart';

import 'driver_auth_repository_impl_test.mocks.dart';

@GenerateMocks([SakaiApiClient, AuthApi, UsersApi])
void main() {
  late MockSakaiApiClient mockClient;
  late MockAuthApi mockAuthApi;
  late MockUsersApi mockUsersApi;
  late DriverAuthRepositoryImpl repository;

  setUp(() {
    mockClient = MockSakaiApiClient();
    mockAuthApi = MockAuthApi();
    mockUsersApi = MockUsersApi();
    
    when(mockClient.getAuthApi()).thenReturn(mockAuthApi);
    when(mockClient.getUsersApi()).thenReturn(mockUsersApi);
    
    final mockDio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
    when(mockClient.dio).thenReturn(mockDio);

    repository = DriverAuthRepositoryImpl(mockClient);
  });

  group('DriverAuthRepositoryImpl.login', () {
    test('successfully logs in and returns AuthSession', () async {
      final now = DateTime.now().toUtc();
      final user = $UserProfile((b) => b
        ..id = '1'
        ..email = 'driver@test.com'
        ..name = 'Driver'
        ..role = UserProfileRoleEnum.driver
        ..createdAt = now
      );

      final mockResponse = AuthResponse((b) => b
        ..accessToken = 'access_token'
        ..refreshToken = 'refresh_token'
        ..accessTokenExpiresAt = now
        ..user = user
      );


      when(mockAuthApi.authLogin(loginRequest: anyNamed('loginRequest')))
          .thenAnswer((_) async => Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final session = await repository.login(
        email: 'driver@test.com',
        password: 'password123',
      );

      expect(session.accessToken, 'access_token');
      expect(session.refreshToken, 'refresh_token');
    });

    test('throws AuthException when response data is null', () async {
      when(mockAuthApi.authLogin(loginRequest: anyNamed('loginRequest')))
          .thenAnswer((_) async => Response(
                data: null,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      expect(
        () => repository.login(email: 'test@test.com', password: 'pw'),
        throwsA(isA<AuthException>().having((e) => e.userMessage, 'userMessage', 'Empty response from server')),
      );
    });

    test('maps INVALID_CREDENTIALS error code to friendly message', () async {
      final errorResponse = ErrorResponse((b) => b
        ..code = ErrorCode.INVALID_CREDENTIALS
        ..message = 'Invalid credentials'
      );

      final serializedError = standardSerializers.serialize(errorResponse, specifiedType: const FullType(ErrorResponse));

      when(mockAuthApi.authLogin(loginRequest: anyNamed('loginRequest')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              data: serializedError,
              statusCode: 401,
              requestOptions: RequestOptions(path: ''),
            ),
          ));

      expect(
        () => repository.login(email: 'test@test.com', password: 'pw'),
        throwsA(isA<AuthException>().having((e) => e.userMessage, 'userMessage', 'Invalid email or password.')),
      );
    });
  });

  group('DriverAuthRepositoryImpl.checkSession', () {
    test('returns authenticated when usersGetMe succeeds', () async {
      final user = $UserProfile((b) => b
        ..id = '1'
        ..email = 'test@test.com'
        ..name = 'Test'
        ..role = UserProfileRoleEnum.driver
        ..createdAt = DateTime.now().toUtc()
      );

      when(mockUsersApi.usersGetMe()).thenAnswer((_) async => Response(
        data: user,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      final result = await repository.checkSession();
      expect(result.status, SessionCheckStatus.authenticated);
    });

    test('returns unauthenticated when status is 401', () async {
      when(mockUsersApi.usersGetMe()).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      final result = await repository.checkSession();
      expect(result.status, SessionCheckStatus.unauthenticated);
    });
  });
}
