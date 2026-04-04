import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/auth/models/session_check_result.dart';
import 'package:passenger/features/auth/repositories/auth_repository_impl.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

class _TestAdapter implements HttpClientAdapter {
  _TestAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Map<String, dynamic> data, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  group('AuthRepositoryImpl.checkSession', () {
    test('returns authenticated when /users/me succeeds', () async {
      final client = SakaiApiClient(basePathOverride: 'https://api.test');
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path == '/users/me') {
          return _jsonResponse({
            'id': 'user-1',
            'name': 'User One',
            'email': 'user@example.com',
            'role': 'passenger',
            'created_at': '2026-01-01T00:00:00Z',
          }, 200);
        }
        return _jsonResponse({'error': 'not_found'}, 404);
      });

      final repo = AuthRepositoryImpl(client);
      final result = await repo.checkSession();
      expect(result.status, SessionCheckStatus.authenticated);
    });

    test('returns unauthenticated when /users/me returns 401', () async {
      final client = SakaiApiClient(basePathOverride: 'https://api.test');
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path == '/users/me') {
          return _jsonResponse({'code': 'UNAUTHORIZED'}, 401);
        }
        return _jsonResponse({'error': 'not_found'}, 404);
      });

      final repo = AuthRepositoryImpl(client);
      final result = await repo.checkSession();
      expect(result.status, SessionCheckStatus.unauthenticated);
    });

    test('returns transientError(network) on connection error', () async {
      final client = SakaiApiClient(basePathOverride: 'https://api.test');
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'network down',
        );
      });

      final repo = AuthRepositoryImpl(client);
      final result = await repo.checkSession();
      expect(result.status, SessionCheckStatus.transientError);
      expect(result.reason, SessionCheckFailureReason.network);
    });

    test('returns transientError(server) on 5xx', () async {
      final client = SakaiApiClient(basePathOverride: 'https://api.test');
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path == '/users/me') {
          return _jsonResponse({'code': 'INTERNAL_ERROR'}, 503);
        }
        return _jsonResponse({'error': 'not_found'}, 404);
      });

      final repo = AuthRepositoryImpl(client);
      final result = await repo.checkSession();
      expect(result.status, SessionCheckStatus.transientError);
      expect(result.reason, SessionCheckFailureReason.server);
    });
  });

  test('logout sends refresh_token and does not throw on 204', () async {
    final client = SakaiApiClient(basePathOverride: 'https://api.test');
    Map<String, dynamic>? body;
    client.dio.httpClientAdapter = _TestAdapter((options) async {
      if (options.path == '/auth/logout') {
        body = Map<String, dynamic>.from(options.data as Map);
        return ResponseBody.fromString('', 204);
      }
      return _jsonResponse({'error': 'not_found'}, 404);
    });

    final repo = AuthRepositoryImpl(client);
    await repo.logout(refreshToken: 'refresh-123');

    expect(body?['refresh_token'], 'refresh-123');
  });
}
