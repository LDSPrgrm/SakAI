import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await TestHarness.ensureDotenv();
  });

  testWidgets('register: switch from login, submit form, land on home', (
    tester,
  ) async {
    final harness = TestHarness();
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    // Toggle from login to register form.
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('register_name')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('register_name')), 'New Rider');
    await tester.enterText(
      find.byKey(const Key('register_email')),
      'new.rider@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register_password')),
      'password123',
    );

    await tester.tap(find.byKey(const Key('register_submit')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.textContaining('Where to?'), findsOneWidget);
    expect(await harness.tokenStorage.hasToken(), isTrue);
    expect(
      await harness.tokenStorage.getAccessToken(),
      'integration-access-reg',
    );
  });

  testWidgets('register: failure surfaces error and stays on register form', (
    tester,
  ) async {
    final harness = TestHarness();
    harness.authRepository.failNextRegister = true;

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('register_name')), 'Dup Rider');
    await tester.enterText(
      find.byKey(const Key('register_email')),
      'dup@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register_password')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('register_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Email already exists'), findsOneWidget);
    expect(await harness.tokenStorage.hasToken(), isFalse);
    expect(find.byKey(const Key('register_submit')), findsOneWidget);
  });
}
