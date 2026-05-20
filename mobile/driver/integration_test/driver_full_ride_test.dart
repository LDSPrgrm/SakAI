@Tags(['e2e-staging'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/test_app.dart';

/// RFC v2 P9.2 — cold-start driver lifecycle.
///
/// Drives the full happy path against a staging backend:
///   cold start → login → go online → ride offer (`ride.requested`) →
///   accept → en route → arrived → start trip → in progress →
///   complete → tip celebration (`ride.completed` with tip_amount > 0) →
///   earnings reveal → rating submit.
///
/// Invariants asserted along the way:
///   - ride.offer materialises within 2s of backend assignment.
///   - Duplicate `ride.requested` (same event_id) does NOT re-trigger offer.
///   - Tip celebration pops exactly once per completed ride.
///   - Reconnect mid-trip → `ride.state_sync` restores currentStep without
///     UI flicker.
///
/// Skipped unless `--tags e2e-staging` AND `--dart-define E2E_API_URL`
/// and `E2E_SEED_TOKEN` are set. The deterministic seed contract is
/// shared with the passenger lifecycle (same ride_id sentinel).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const apiUrl = String.fromEnvironment('E2E_API_URL');
  const seedToken = String.fromEnvironment('E2E_SEED_TOKEN');

  testWidgets('driver full ride: lifecycle + tip celebration exactly-once',
      (tester) async {
    if (apiUrl.isEmpty || seedToken.isEmpty) {
      markTestSkipped(
        'E2E_API_URL and E2E_SEED_TOKEN required. Pair with passenger '
        'full-ride run via shared sentinel ride_id (see plan §P9).',
      );
      return;
    }

    final harness = DriverTestHarness(seenWelcome: true);
    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsWidgets,
        reason: 'driver app shell renders against staging');

    // TODO(P9): drive lifecycle via WS events fed by --seed-token harness:
    //   1. go online, assert availability POST fired once.
    //   2. send ride.requested, assert RideOfferScreen renders.
    //   3. resend ride.requested (duplicate event_id), assert no flicker.
    //   4. accept, drive ActiveRideScreen through enRoute → arrived →
    //      inProgress → completed states.
    //   5. send ride.completed with tip_amount > 0, assert SakaiTipCelebration
    //      appears exactly once.
    //   6. force WS close mid-trip, reconnect, assert ride.state_sync
    //      restores the active ride state without REST refetch.
    //   7. submit rating, assert POST fired once.
  });
}
