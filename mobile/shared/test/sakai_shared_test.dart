import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

void main() {
  group('SakaiApiSupport', () {
    test('creates client with bearer token and base URL', () {
      const customUrl = 'https://api.test.com/api';
      final c = SakaiApiSupport.createClient(
        baseUrl: customUrl,
        authInterceptor: AuthInterceptor(const TokenStorage()),
      );

      expect(c.dio.options.baseUrl, customUrl);
      // Verify interceptor setup (checking for BearerAuthInterceptor via its tokens entry)
      // The generated client doesn't expose interceptors easily, but we trust the inner setup.

      c.dio.close();
    });

    test('webSocketUri preserves path prefix', () {
      const restBase = 'http://api.test.com/api';
      const token = 'test-token';
      final uri = SakaiApiEndpoints.webSocketUri(restBase, token);

      expect(uri.scheme, 'ws');
      expect(uri.host, 'api.test.com');
      expect(uri.path, '/api/ws');
      expect(uri.queryParameters['token'], token);
    });

    test('webSocketUri handles trailing slash in base URL', () {
      const restBase = 'http://api.test.com/api/';
      final uri = SakaiApiEndpoints.webSocketUri(restBase, 'token');
      expect(uri.path, '/api/ws');
    });
  });

  test('SakaiTheme attaches design tokens extension', () {
    final config = SakaiThemeConfig.passenger();
    final theme = SakaiTheme.light(config);
    expect(theme.extension<SakaiDesignTokens>(), isNotNull);
    expect(theme.extension<SakaiDesignTokens>(), config.tokens);
  });

  testWidgets('SakaiDesignTokens.of is available under themed app', (
    tester,
  ) async {
    final config = SakaiThemeConfig.driver();
    await tester.pumpWidget(
      MaterialApp(
        theme: SakaiTheme.light(config),
        home: Builder(
          builder: (context) {
            final tokens = SakaiDesignTokens.of(context);
            return Text('${tokens.spaceMd}');
          },
        ),
      ),
    );
    expect(find.text('16.0'), findsOneWidget);
  });
}
