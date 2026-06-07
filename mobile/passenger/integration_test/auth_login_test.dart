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
    'login: bad credentials show error then good credentials reach home',
    (tester) async {
      final harness = TestHarness();
      harness.authRepository.failNextLogin = true;

      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_email')),
        'bad@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password')),
        'wrongpass',
      );
      await tester.tap(find.byKey(const Key('login_submit')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password'), findsOneWidget);
      expect(await harness.tokenStorage.hasToken(), isFalse);

      // Recover with valid credentials.
      harness.authRepository.failNextLogin = false;
      await tester.enterText(
        find.byKey(const Key('login_email')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_submit')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.textContaining('Where to?'), findsOneWidget);
      expect(await harness.tokenStorage.hasToken(), isTrue);
    },
  );
}
