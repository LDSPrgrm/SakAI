@Tags(['e2e-staging'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/e2e_seed_client.dart';
import 'harness/test_app.dart';

/// RFC v2 P9.3 — multi-device fanout invariant.
///
/// Per §7.4 + §20 decision 2, a single user may have at most 3 concurrent
/// WebSocket connections. Each connection must:
///   - Receive every event exactly once (no duplicate handlers).
///   - Honor the ACK protocol independently — a single client ACK on any
///     device suffices for the server-side ack_tracker to drop pending.
///
/// This test models two devices (phone + tablet) by mounting the harness
/// twice within the same Flutter binding. Both sessions auth as the same
/// passenger (seeded by /api/e2e/seed) and subscribe to the same ride.
/// When the backend publishes `ride.completed`, both devices must surface
/// the receipt UI; the server must clear the pending ACK after either
/// side acknowledges.
///
/// Skipped unless `--tags e2e-staging` AND `--dart-define E2E_API_URL`
/// and `E2E_SEED_TOKEN` are set.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const apiUrl = String.fromEnvironment('E2E_API_URL');
  const seedToken = String.fromEnvironment('E2E_SEED_TOKEN');

  testWidgets('multi-device: event fires once per device, ack from either',
      (tester) async {
    if (apiUrl.isEmpty || seedToken.isEmpty) {
      markTestSkipped(
        'E2E_API_URL and E2E_SEED_TOKEN required. Backend must expose the '
        'ack_tracker counter for the assertion in step 4 to be meaningful.',
      );
      return;
    }

    final fixture = await E2ESeedClient(
      apiUrl: apiUrl,
      seedToken: seedToken,
    ).seed();

    final phone = TestHarness(seenWelcome: true);
    final tablet = TestHarness(seenWelcome: true);
    await phone.tokenStorage.save(
      accessToken: fixture.passengerJwt,
      refreshToken: 'e2e-refresh-phone',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    await tablet.tokenStorage.save(
      accessToken: fixture.passengerJwt,
      refreshToken: 'e2e-refresh-tablet',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    await tester.pumpWidget(phone.buildApp());
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets,
        reason: 'phone shell mounts first');

    await tester.pumpWidget(tablet.buildApp());
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets,
        reason: 'tablet shell mounts second');

    // OUTSTANDING (P9 multi-device live execution):
    //   1. Backend: ship POST /api/e2e/publish-event AND expose
    //      GET /api/e2e/ack-tracker-state so step 4 below can verify
    //      the server actually dropped the pending entry rather than
    //      timing out silently.
    //   2. Backend: the current hub.Register evicts the prior connection
    //      for a userID (see hub.go:147). Multi-device fanout (§7.4 N≤3)
    //      requires the hub to hold a list of clients per user, not a
    //      single slot. Until that lands, this test cannot exercise the
    //      true two-device path — it'll just see the tablet evict the
    //      phone connection.
    //   3. Then drive:
    //        a. open both sessions as the same passenger; backend must
    //           serve both upgrades.
    //        b. publish ride.completed with AckRequired:true.
    //        c. assert receipt UI surfaces on BOTH devices exactly once.
    //        d. ACK only on the phone; query ack-tracker-state and assert
    //           pending=0 (no second delivery to the tablet on reconnect).
  });
}
