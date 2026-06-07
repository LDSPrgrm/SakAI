@Tags(['e2e-staging'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/test_app.dart';

/// Canonical passenger journey:
///   login → home → request → match → trip → complete → pay → receipt
///   → history shows trip.
///
/// Requires a backend reachable at `--dart-define API_URL=...` plus a
/// deterministic seed:
///   - Test passenger account
///   - Pre-positioned driver in the service area
///
/// Skipped automatically unless `--tags e2e-staging` is passed AND
/// `--dart-define E2E_API_URL` is non-empty. The seed contract still
/// needs a `BACKEND REQUIRED` ticket — see plan file.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const apiUrl = String.fromEnvironment('E2E_API_URL');

  testWidgets('passenger journey: request → complete → receipt', (
    tester,
  ) async {
    if (apiUrl.isEmpty) {
      markTestSkipped(
        'E2E_API_URL not set. Pass --dart-define E2E_API_URL=https://staging '
        'and ensure the backend has the deterministic e2e seed endpoint live.',
      );
      return;
    }

    final harness = TestHarness(seenWelcome: true);
    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    // Login → enter destination → request → wait for match → trip → complete.
    // Detailed step asserts are intentionally TODO — implementation depends on
    // the staging seed contract finalizing. Each step should assert via UI
    // text and provider snapshots; see plan §Phase 5.
    expect(
      find.byType(Scaffold),
      findsWidgets,
      reason: 'app shell renders against staging',
    );

    // TODO(e2e): drive the full journey once the seed endpoint is in place.
  });
}
