import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SakaiApiClient _client;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest((b) => b
        ..email = email
        ..password = password);
      final response = await _client.getAuthApi().authLogin(loginRequest: request);
      final data = response.data;
      if (data == null) {
        throw AuthException(userMessage: 'Empty response from server');
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

  AuthException _fromDio(DioException e) {
    final data = e.response?.data;
    if (data != null) {
      try {
        final err = standardSerializers.deserialize(
          data,
          specifiedType: const FullType(ErrorResponse),
        ) as ErrorResponse;
        return AuthException(
          machineCode: err.code.name,
          userMessage: _friendlyMessage(err.code, err.message),
        );
      } catch (_) {
        /* fall through */
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AuthException(userMessage: 'Connection timed out. Try again.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return AuthException(
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
      case ErrorCode.VALIDATION_ERROR:
        return 'Please check your email and password.';
      case ErrorCode.RATE_LIMIT_EXCEEDED:
        return 'Too many attempts. Wait a moment and try again.';
      default:
        return serverMessage;
    }
  }
}
