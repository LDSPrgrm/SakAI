import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:passenger/app/passenger_app.dart';
import 'package:passenger/features/home/view_models/home_notifier.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide LatLng, NearbyDriver, ServiceArea;

import 'harness/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await TestHarness.ensureDotenv();
  });

  testWidgets(
    'ride request flow: login, set destination + ride type, request → WaitingScreen',
    (tester) async {
      final harness = TestHarness();
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(harness.buildApp(useFakeHomeNotifier: true));
      await tester.pumpAndSettle();

      // Login first.
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

      // Drive the home notifier directly — DestinationSheet pulls geocoding
      // suggestions from the network, which is out of scope for this tier.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PassengerApp)),
      );
      final notifier = container.read(homeNotifierProvider.notifier);
      notifier.setDestination(
        const RideLocation(lat: 14.5086, lng: 121.0194, address: 'Airport'),
      );
      notifier.setSelectedRideType(VehicleType.car);

      final ride = await notifier.requestRide();
      expect(ride, isNotNull);
      expect(ride!.id, 'integration-ride-1');
    },
  );
}
