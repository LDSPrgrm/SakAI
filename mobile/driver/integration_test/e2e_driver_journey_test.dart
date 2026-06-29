@Tags(['e2e-staging'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/test_app.dart';

/// Canonical driver journey:
///   login → online → offer → accept → arrive (test-bypass GPS proximity)
///   → start → complete → earnings increment.
///
/// Requires staging backend + deterministic seed (test driver, approved docs,
/// pre-positioned passenger waiting in the service area).
///
/// Skipped unless `--tags e2e-staging` AND `--dart-define E2E_API_URL` set.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const apiUrl = String.fromEnvironment('E2E_API_URL');

  testWidgets('driver journey: online → accept → complete', (tester) async {
    if (apiUrl.isEmpty) {
      markTestSkipped(
        'E2E_API_URL not set. Pass --dart-define E2E_API_URL=https://staging '
        'and ensure the backend has the deterministic e2e seed endpoint live.',
      );
      return;
    }

    final harness = DriverTestHarness(seenWelcome: true);
    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsWidgets,
        reason: 'app shell renders against staging');

    // TODO(e2e): drive the full journey once the seed endpoint is in place.
    // Coordinate with the passenger run via a shared sentinel ride ID (env
    // or file) per plan §Phase 5.
  });
}
