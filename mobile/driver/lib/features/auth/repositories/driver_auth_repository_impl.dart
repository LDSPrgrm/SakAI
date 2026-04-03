import 'package:dio/dio.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import '../models/auth_exception.dart';
import '../models/auth_session.dart';
import 'driver_auth_repository.dart';

class DriverAuthRepositoryImpl implements DriverAuthRepository {
  DriverAuthRepositoryImpl(this._client);

  final SakaiApiClient _client;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(
        (b) => b
          ..email = email
          ..password = password,
      );
      final response = await _client.getAuthApi().authLogin(
        loginRequest: request,
      );
      final data = response.data;
      if (data == null) {
        throw const AuthException(userMessage: 'Empty response from server');
      }
      return AuthSession(
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        accessTokenExpiresAt: data.accessTokenExpiresAt,
      );
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  @override
  Future<AuthSession> registerDriver({
    required String name,
    required String email,
    required String password,
    required String vehicleMake,
    required String vehicleModel,
    required String vehiclePlate,
    required String vehicleColor,
    required int vehicleYear,
  }) async {
    try {
      final request = RegisterRequest(
        (b) => b
          ..name = name
          ..email = email
          ..password = password
          ..role = RegisterRequestRoleEnum.driver,
      );
      final response = await _client.getAuthApi().authRegister(
        registerRequest: request,
      );
      final data = response.data;
      if (data == null) {
        throw const AuthException(userMessage: 'Empty response from server');
      }
      return AuthSession(
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        accessTokenExpiresAt: data.accessTokenExpiresAt,
      );
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  @override
  Future<bool> hasValidSession() async {
    try {
      await _client.getUsersApi().usersGetMe();
      return true;
    } on DioException {
      return false;
    }
  }

  AuthException _fromDio(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      return const AuthException(userMessage: 'Invalid email or password.');
    }
    if (status == 409) {
      return const AuthException(
        userMessage: 'An account with that email already exists.',
      );
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const AuthException(
        userMessage: 'No connection. Check network or server URL.',
      );
    }
    return AuthException(
      userMessage: e.message ?? 'Something went wrong. Try again.',
    );
  }
}
