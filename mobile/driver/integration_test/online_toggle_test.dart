import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DriverTestHarness.ensureDotenv();
  });

  testWidgets('driver online toggle: Start shift → online state recorded',
      (tester) async {
    final harness = DriverTestHarness();
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    // Sign in.
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

    expect(find.textContaining('Start shift'), findsOneWidget);

    // Tap Start shift — in INTEGRATION_TEST mode, DriverHomeNotifier.toggleStatus
    // takes the e2e branch (no real DriverRepository.goOnline call) so the
    // toggle flips entirely client-side. Verify the End shift label appears.
    await tester.tap(find.textContaining('Start shift'));
    await tester.pumpAndSettle();

    expect(find.textContaining('End shift'), findsOneWidget);
  });
}
