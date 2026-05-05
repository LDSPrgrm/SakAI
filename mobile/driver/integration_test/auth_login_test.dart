import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DriverTestHarness.ensureDotenv();
  });

  testWidgets('driver login: bad creds → error → good creds → home',
      (tester) async {
    final harness = DriverTestHarness();
    harness.authRepository.failNextLogin = true;

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'driver.bad@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'wrongpass',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(await harness.tokenStorage.hasToken(), isFalse);

    harness.authRepository.failNextLogin = false;
    await tester.enterText(
      find.byKey(const Key('login_email')),
      'driver@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'password123',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Driver home shows the Start shift toggle.
    expect(find.textContaining('Start shift'), findsOneWidget);
    expect(await harness.tokenStorage.hasToken(), isTrue);
  });
}
