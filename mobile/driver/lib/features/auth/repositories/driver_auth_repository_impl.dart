import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import '../models/auth_exception.dart';
import '../models/auth_session.dart';
import '../models/session_check_result.dart';
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
      debugPrint('[AuthRepo] Base URL: ${_client.dio.options.baseUrl}');
      debugPrint('[AuthRepo] Login attempt for: $email');
      final response = await _client.getAuthApi().authLogin(
        loginRequest: request,
      );
      final data = response.data;
      if (data == null) {
        debugPrint('[AuthRepo] Login failed: Empty response');
        throw const AuthException(userMessage: 'Empty response from server');
      }
      debugPrint('[AuthRepo] Login success for $email');
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
    required String vehicleType,
  }) async {
    try {
      // Use raw Dio to send vehicle_type which isn't yet in the generated client
      final baseUrl = _client.dio.options.baseUrl;
      final response = await _client.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': 'driver',
          'vehicle': {
            'make': vehicleMake,
            'model': vehicleModel,
            'plate': vehiclePlate,
            'color': vehicleColor,
            'vehicle_type': vehicleType,
          },
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (data.isEmpty) {
        debugPrint('[AuthRepo] Register failed: Empty response');
        throw const AuthException(userMessage: 'Empty response from server');
      }
      debugPrint('[AuthRepo] Register success for $email');
      return AuthSession(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        accessTokenExpiresAt: DateTime.parse(
          data['access_token_expires_at'] as String,
        ),
      );
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  @override
  Future<SessionCheckResult> checkSession() async {
    try {
      debugPrint(
        '[AuthRepo] Checking session at: ${_client.dio.options.baseUrl}/users/me',
      );
      await _client.getUsersApi().usersGetMe();
      return const SessionCheckResult.authenticated();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const SessionCheckResult.unauthenticated();
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const SessionCheckResult.transientError(
          reason: SessionCheckFailureReason.network,
        );
      }

      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return const SessionCheckResult.transientError(
          reason: SessionCheckFailureReason.server,
        );
      }

      return const SessionCheckResult.transientError();
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    if (refreshToken.isEmpty) return;
    final request = LogoutRequest((b) => b..refreshToken = refreshToken);
    await _client.getAuthApi().authLogout(logoutRequest: request);
  }

  AuthException _fromDio(DioException e) {
    debugPrint('[AuthRepo] Error: ${e.type} - ${e.message}');
    debugPrint('[AuthRepo] Requested URI: ${e.requestOptions.uri}');
    debugPrint('[AuthRepo] Base URL was: ${e.requestOptions.baseUrl}');
    if (e.response != null) {
      debugPrint('[AuthRepo] Status: ${e.response?.statusCode}');
      debugPrint('[AuthRepo] Response: ${e.response?.data}');
    }

    final data = e.response?.data;
    if (data != null) {
      try {
        final err =
            standardSerializers.deserialize(
                  data,
                  specifiedType: const FullType(ErrorResponse),
                )
                as ErrorResponse;
        return AuthException(
          userMessage: _friendlyMessage(err.code, err.message),
        );
      } catch (_) {
        /* fall through */
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AuthException(
        userMessage: 'Connection timed out. Try again.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const AuthException(
        userMessage: 'No connection. Check network or server URL.',
      );
    }
    return AuthException(
      userMessage: e.message ?? 'Something went wrong. Try again.',
    );
  }

  String _friendlyMessage(ErrorCode code, String serverMessage) {
    switch (code) {
      case ErrorCode.INVALID_CREDENTIALS:
        return 'Invalid email or password.';
      case ErrorCode.RATE_LIMIT_EXCEEDED:
        return 'Too many attempts. Wait a moment and try again.';
      default:
        return serverMessage;
    }
  }
}
