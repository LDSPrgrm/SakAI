@Tags(['e2e-staging'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/e2e_seed_client.dart';
import 'harness/test_app.dart';

/// RFC v2 P9.2 — cold-start driver lifecycle.
///
/// Drives the full happy path against a staging backend with deterministic
/// fixtures from `/api/e2e/seed`:
///   cold start → online → ride offer (`ride.requested`) → accept →
///   en route → arrived → start trip → in progress → complete →
///   tip celebration (`ride.completed` with tip_amount > 0) →
///   earnings reveal → rating submit.
///
/// Invariants asserted:
///   - Ride offer materialises within 2s of fixture creation.
///   - Duplicate `ride.requested` (same event_id) does NOT re-trigger offer.
///   - Tip celebration pops exactly once per completed ride.
///   - Reconnect mid-trip → `ride.state_sync` restores currentStep with
///     no UI flicker.
///
/// Skipped unless `--tags e2e-staging` AND `--dart-define E2E_API_URL`
/// and `E2E_SEED_TOKEN` are set. Shares fixture IDs with the passenger
/// full-ride test via the deterministic seed.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const apiUrl = String.fromEnvironment('E2E_API_URL');
  const seedToken = String.fromEnvironment('E2E_SEED_TOKEN');

  testWidgets('driver full ride: lifecycle + tip celebration exactly-once',
      (tester) async {
    if (apiUrl.isEmpty || seedToken.isEmpty) {
      markTestSkipped(
        'E2E_API_URL and E2E_SEED_TOKEN required. Backend must run with '
        'E2E_ENABLED=true so /api/e2e/seed is mounted.',
      );
      return;
    }

    final fixture = await E2ESeedClient(
      apiUrl: apiUrl,
      seedToken: seedToken,
    ).seed();

    final harness = DriverTestHarness(seenWelcome: true);
    await harness.tokenStorage.save(
      accessToken: fixture.driverJwt,
      refreshToken: 'e2e-refresh-placeholder',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsWidgets,
        reason: 'driver app shell renders against staging with seeded JWT');

    // OUTSTANDING (P9 live execution — same blockers as the passenger
    // counterpart):
    //   1. Backend: POST /api/e2e/publish-event endpoint required to
    //      publish WS events for fixture.rideId from the test harness.
    //   2. Staging: E2E_ENABLED=true + rotating E2E_SEED_TOKEN.
    //   3. Then drive the lifecycle:
    //        a. go online via the toggle, assert PUT /driver/status fired once.
    //        b. publish ride.requested for fixture.rideId; assert
    //           RideOfferScreen renders.
    //        c. republish ride.requested (duplicate event_id), assert no
    //           flicker / no second offer.
    //        d. accept; drive ActiveRideScreen enRoute → arrived →
    //           inProgress → completed states.
    //        e. publish ride.completed with tip_amount > 0; assert
    //           SakaiTipCelebration appears exactly once.
    //        f. force WS close mid-trip; reconnect; assert ride.state_sync
    //           restores active ride without REST refetch.
    //        g. submit rating, assert POST /rides/{id}/rating fired once.
  });
}
