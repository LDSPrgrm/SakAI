import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

/// REST and WebSocket entry points aligned with `openapi/swagger.yaml` servers.
abstract final class SakaiApiEndpoints {
  SakaiApiEndpoints._();

  /// Default local API. Uses Dart environment `API_URL` if passed via
  /// --dart-define, otherwise falls back to dotenv.
  static String get defaultRestBaseUrl =>
      const String.fromEnvironment('API_URL').isNotEmpty
      ? const String.fromEnvironment('API_URL')
      : dotenv.env['API_URL'] ?? '';

  /// `ws://{host}{path}/ws` or `wss://…` using the same host and prefix as [restBaseUrl].
  static Uri webSocketUri(String restBaseUrl, String accessToken) {
    final rest = Uri.parse(restBaseUrl);
    final scheme = rest.scheme == 'https' ? 'wss' : 'ws';
    // Ensure we don't end up with double slashes if path is empty or just /
    final basePath = rest.path.endsWith('/')
        ? rest.path.substring(0, rest.path.length - 1)
        : rest.path;
    return Uri(
      scheme: scheme,
      host: rest.host,
      port: rest.hasPort ? rest.port : null,
      path: '$basePath/ws',
      queryParameters: {'token': accessToken},
    );
  }
}

/// Factory helpers for the generated OpenAPI client.
abstract final class SakaiApiSupport {
  SakaiApiSupport._();

  /// OpenAPI security scheme name for JWT (see `BearerAuth` in swagger.yaml).
  static const String bearerAuthName = 'BearerAuth';

  /// Creates a [SakaiApiClient] with optional [authInterceptor] attached.
  static SakaiApiClient createClient({
    String? baseUrl,
    Interceptor? authInterceptor,
  }) {
    final effectiveBaseUrl = baseUrl ?? SakaiApiEndpoints.defaultRestBaseUrl;
    final client = SakaiApiClient(
      basePathOverride: effectiveBaseUrl.isNotEmpty ? effectiveBaseUrl : null,
    );
    if (authInterceptor != null) {
      client.dio.interceptors.add(authInterceptor);
    }
    return client;
  }
}
