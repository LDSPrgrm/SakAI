import 'package:sakai_api_client/sakai_api_client.dart';

/// REST and WebSocket entry points aligned with `openapi/swagger.yaml` servers.
abstract final class SakaiApiEndpoints {
  SakaiApiEndpoints._();

  /// Default local API. Uses Dart environment `API_URL` if passed via
  static const String defaultRestBaseUrl = String.fromEnvironment('API_URL');

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

  /// Creates a [SakaiApiClient] with optional JWT attached for protected routes.
  static SakaiApiClient createClient({
    String baseUrl = SakaiApiEndpoints.defaultRestBaseUrl,
    String? accessToken,
  }) {
    final client = SakaiApiClient(
      basePathOverride: baseUrl.isNotEmpty ? baseUrl : null,
    );
    if (accessToken != null && accessToken.isNotEmpty) {
      client.setBearerAuth(bearerAuthName, accessToken);
    }
    return client;
  }
}
