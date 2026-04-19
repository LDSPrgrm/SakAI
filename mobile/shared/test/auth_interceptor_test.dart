import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;
  DateTime? expiry;

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    expiry = expiresAt;
  }

  @override
  Future<void> saveAccessToken(String token) async => accessToken = token;

  @override
  Future<void> saveRefreshToken(String token) async => refreshToken = token;

  @override
  Future<void> saveExpiry(DateTime expiresAt) async => expiry = expiresAt;

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<DateTime?> getExpiry() async => expiry;

  @override
  Future<bool> hasToken() async =>
      accessToken != null && accessToken!.isNotEmpty;

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    expiry = null;
  }
}

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
  test('refresh uses snake_case contract and retries request', () async {
    final storage = _FakeTokenStorage(
      accessToken: 'expired-access',
      refreshToken: 'old-refresh',
    );
    Map<String, dynamic>? refreshPayload;

    final refreshDio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    refreshDio.httpClientAdapter = _TestAdapter((options) async {
      if (options.path == '/auth/refresh') {
        refreshPayload = Map<String, dynamic>.from(options.data as Map);
        return _jsonResponse({
          'access_token': 'new-access',
          'refresh_token': 'new-refresh',
          'access_token_expires_at': '2030-01-01T00:00:00Z',
        }, 200);
      }
      if (options.path == '/protected') {
        expect(options.headers['Authorization'], 'Bearer new-access');
        return _jsonResponse({'ok': true}, 200);
      }
      return _jsonResponse({'error': 'not_found'}, 404);
    });

    final interceptor = AuthInterceptor(storage, dioFactory: (_) => refreshDio);

    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.httpClientAdapter = _TestAdapter((options) async {
      if (options.path == '/protected') {
        return _jsonResponse({'code': 'UNAUTHORIZED'}, 401);
      }
      return _jsonResponse({'error': 'not_found'}, 404);
    });
    dio.interceptors.add(interceptor);

    final response = await dio.get('/protected');

    expect(response.statusCode, 200);
    expect(refreshPayload?['refresh_token'], 'old-refresh');
    expect(await storage.getAccessToken(), 'new-access');
    expect(await storage.getRefreshToken(), 'new-refresh');
    expect(await storage.getExpiry(), DateTime.parse('2030-01-01T00:00:00Z'));
  });

  test(
    'refresh failure clears storage and triggers invalidation callback',
    () async {
      final storage = _FakeTokenStorage(
        accessToken: 'expired-access',
        refreshToken: 'old-refresh',
      );
      var invalidated = false;

      final refreshDio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      refreshDio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path == '/auth/refresh') {
          return _jsonResponse({'code': 'REFRESH_TOKEN_INVALID'}, 401);
        }
        return _jsonResponse({'error': 'not_found'}, 404);
      });

      final interceptor = AuthInterceptor(
        storage,
        onSessionInvalidated: () => invalidated = true,
        dioFactory: (_) => refreshDio,
      );

      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path == '/protected') {
          return _jsonResponse({'code': 'UNAUTHORIZED'}, 401);
        }
        return _jsonResponse({'error': 'not_found'}, 404);
      });
      dio.interceptors.add(interceptor);

      await expectLater(dio.get('/protected'), throwsA(isA<DioException>()));
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(invalidated, isTrue);
    },
  );
}
