import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'token_storage.dart';

/// Dio interceptor that injects the Bearer token from [TokenStorage].
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._storage, {
    this.onSessionInvalidated,
    Dio Function(BaseOptions options)? dioFactory,
  }) : _dioFactory = dioFactory ?? ((options) => Dio(options));

  final TokenStorage _storage;
  final void Function()? onSessionInvalidated;
  final Dio Function(BaseOptions options) _dioFactory;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Wrap token read so a storage failure (e.g. flutter_secure_storage_web
    // throwing OperationError on subtle-crypto decrypt) does not stall the
    // Dio interceptor pipeline — handler.next must always run.
    try {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint(
          '[AuthInterceptor] Injected Bearer token for: ${options.path}',
        );
      } else {
        debugPrint('[AuthInterceptor] NO token found for: ${options.path}');
      }
    } catch (e) {
      debugPrint('[AuthInterceptor] Token read failed for ${options.path}: $e');
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // We only care about 401 Unauthorized.
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't attempt refresh if this was already a refresh request.
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await _clearSession();
      return handler.next(err);
    }

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearSession();
      return handler.next(err);
    }

    try {
      // Attempt to refresh.
      // We use a fresh Dio instance to avoid interceptor recursion.
      final dio = _dioFactory(BaseOptions(
        baseUrl: err.requestOptions.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ));
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        // Save new tokens.
        final accessToken = data['access_token'] as String?;
        final nextRefreshToken = data['refresh_token'] as String?;
        if (accessToken == null ||
            accessToken.isEmpty ||
            nextRefreshToken == null ||
            nextRefreshToken.isEmpty) {
          await _clearSession();
          return handler.next(err);
        }

        await _storage.saveAccessToken(accessToken);
        await _storage.saveRefreshToken(nextRefreshToken);
        if (data.containsKey('access_token_expires_at')) {
          final expiresAtStr = data['access_token_expires_at'] as String;
          await _storage.saveExpiry(DateTime.parse(expiresAtStr));
        }

        // Retry original request.
        final opts = err.requestOptions;
        final retryHeaders = Map<String, dynamic>.from(opts.headers);
        retryHeaders['Authorization'] = 'Bearer $accessToken';
        final retryResponse = await dio.request(
          opts.path,
          data: opts.data,
          queryParameters: opts.queryParameters,
          options: Options(
            method: opts.method,
            headers: retryHeaders,
            contentType: opts.contentType,
            responseType: opts.responseType,
            sendTimeout: opts.sendTimeout,
            receiveTimeout: opts.receiveTimeout,
            followRedirects: opts.followRedirects,
            maxRedirects: opts.maxRedirects,
            extra: opts.extra,
            validateStatus: opts.validateStatus,
          ),
          cancelToken: opts.cancelToken,
          onSendProgress: opts.onSendProgress,
          onReceiveProgress: opts.onReceiveProgress,
        );

        return handler.resolve(retryResponse);
      }
    } catch (e) {
      // Refresh failed (network error or expired refresh token).
      await _clearSession();
    }

    return handler.next(err);
  }

  Future<void> _clearSession() async {
    await _storage.clear();
    onSessionInvalidated?.call();
  }
}
