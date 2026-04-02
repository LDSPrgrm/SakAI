import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

void main() {
  test('SakaiApiSupport creates client with bearer token', () {
    final c = SakaiApiSupport.createClient(accessToken: 'test');
    expect(c.dio.options.baseUrl, SakaiApiEndpoints.defaultRestBaseUrl);
    c.dio.close();
  });

  test('SakaiTheme attaches design tokens extension', () {
    final config = SakaiThemeConfig.passenger();
    final theme = SakaiTheme.light(config);
    expect(theme.extension<SakaiDesignTokens>(), isNotNull);
    expect(theme.extension<SakaiDesignTokens>(), config.tokens);
  });

  testWidgets('SakaiDesignTokens.of is available under themed app',
      (tester) async {
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
