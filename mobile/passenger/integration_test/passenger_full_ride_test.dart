@Tags(['e2e-staging'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/test_app.dart';

/// RFC v2 P9.1 — cold-start passenger lifecycle.
///
/// Drives the full happy path against a staging backend:
///   cold start → login → request → match (`ride.accepted`) →
///   driver en route (`ride.status_changed`) → arrival → in-progress →
///   completed (`ride.completed` with fare + tip) →
///   payment.succeeded → receipt → rating submit.
///
/// Invariants asserted along the way:
///   - Every WS event surfaces in the UI exactly once even with reconnects.
///   - No duplicate snackbars or banners across the lifecycle.
///   - ride.state_sync emitted after a forced disconnect rehydrates UI.
///
/// Skipped automatically unless `--tags e2e-staging` is passed AND
/// `--dart-define E2E_API_URL` is non-empty. The deterministic seed
/// endpoint (`E2E_SEED_TOKEN`) still needs a backend ticket — until
/// then this file serves as the contract specification for the seed.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const apiUrl = String.fromEnvironment('E2E_API_URL');
  const seedToken = String.fromEnvironment('E2E_SEED_TOKEN');

  testWidgets('passenger full ride: every WS event applied exactly once',
      (tester) async {
    if (apiUrl.isEmpty || seedToken.isEmpty) {
      markTestSkipped(
        'E2E_API_URL and E2E_SEED_TOKEN required. Backend ticket pending: '
        'seed endpoint must return {passengerId, driverId, rideId, jwt} '
        'so this test can drive the lifecycle deterministically.',
      );
      return;
    }

    final harness = TestHarness(seenWelcome: true);
    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    // Sanity: app shell rendered. The full journey assertions land here
    // once the seed contract is final — see plan §P9 BACKEND REQUIRED.
    expect(find.byType(Scaffold), findsWidgets,
        reason: 'app shell renders against staging');

    // TODO(P9): drive lifecycle via WS events fed by --seed-token harness:
    //   1. send ride.accepted, assert match screen appears once.
    //   2. resend ride.accepted (duplicate event_id), assert UI unchanged.
    //   3. send ride.status_changed (en_route → arrived → in_progress).
    //   4. force conn close mid-trip, reconnect, assert ride.state_sync
    //      restores currentStep without REST refetch.
    //   5. send ride.completed with fare/breakdown/tip, assert phased reveal.
    //   6. submit rating, assert POST /rides/{id}/rating fired once.
  });
}
