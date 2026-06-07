import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await TestHarness.ensureDotenv();
  });

  testWidgets(
    'session restore: pre-seeded token bypasses login and lands on home',
    (tester) async {
      final harness = TestHarness();
      await harness.tokenStorage.save(
        accessToken: 'restored-access',
        refreshToken: 'restored-refresh',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );

      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('Where to?'), findsOneWidget);
      // The login form's email field key should never have been pumped.
      expect(find.byKey(const Key('login_email')), findsNothing);
    },
  );
}
