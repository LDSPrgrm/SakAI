import 'package:sakai_api_client/sakai_api_client.dart';

/// REST and WebSocket entry points aligned with `openapi/swagger.yaml` servers.
abstract final class SakaiApiEndpoints {
  SakaiApiEndpoints._();

  /// Default local API (see OpenAPI `servers[0]`).
  static const String defaultRestBaseUrl = 'http://localhost:8080/api/v1';

  /// `ws://{host}/ws` or `wss://…` using the same host as [restBaseUrl].
  static Uri webSocketUri(String restBaseUrl, String accessToken) {
    final rest = Uri.parse(restBaseUrl);
    final scheme = rest.scheme == 'https' ? 'wss' : 'ws';
    return Uri(
      scheme: scheme,
      host: rest.host,
      port: rest.hasPort ? rest.port : null,
      path: '/ws',
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
    final client = SakaiApiClient(basePathOverride: baseUrl);
    if (accessToken != null && accessToken.isNotEmpty) {
      client.setBearerAuth(bearerAuthName, accessToken);
    }
    return client;
  }
}
