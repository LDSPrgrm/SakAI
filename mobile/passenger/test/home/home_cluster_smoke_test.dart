library;

/// Task 15 — structural smoke coverage for the passenger home cluster
/// (RiderHomeScreen idle dashboard: header, services grid, wallet cards,
/// promotions) under light theme.
///
/// Pixel goldens are not used here — see mobile/shared's 8 pre-existing
/// environment-only golden failures (Task 3 stash A/B). This reuses the
/// proven `pumpRiderHome` harness from `nav_routing_test.dart` (Task 6) and
/// asserts the dashboard renders its real cluster widgets without a bare
/// default-themed AppBar (the dashboard has no Scaffold.appBar — branding
/// comes from `HomeDashboardHeader` instead).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide LatLng, NearbyDriver, ServiceArea;

import 'package:passenger/features/home/view_models/home_notifier.dart';
import 'package:passenger/features/home/views/rider_home_screen.dart';
import 'package:passenger/features/home/views/widgets/home_dashboard_header.dart';
import 'package:passenger/features/home/views/widgets/home_services_grid.dart';
import 'package:passenger/features/home/views/widgets/home_wallet_cards.dart';

class _FakeHomeNotifier extends HomeNotifier {
  @override
  HomeState build() => const HomeState(status: HomeStatus.idle);

  @override
  Future<void> initLocation() async {}
}

Future<void> _pumpRiderHomeLight(WidgetTester tester) async {
  SakaiAnimatedBackdrop.debugDisableAnimations = true;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeNotifierProvider.overrideWith(() => _FakeHomeNotifier()),
      ],
      child: MaterialApp(
        theme: SakaiTheme.light(SakaiThemeConfig.passenger()),
        home: const RiderHomeScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  tearDown(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = false;
  });

  testWidgets(
    'RiderHomeScreen idle dashboard pumps under light theme with the real '
    'cluster widgets, not a bare AppBar',
    (tester) async {
      await _pumpRiderHomeLight(tester);

      // No Scaffold.appBar on the dashboard — branding lives in
      // HomeDashboardHeader, so a bare default-themed AppBar can never leak
      // through here.
      expect(find.byType(AppBar), findsNothing);

      expect(find.byType(HomeDashboardHeader), findsOneWidget);
      expect(find.byType(HomeServicesGrid), findsOneWidget);
      expect(find.byType(HomeWalletCards), findsOneWidget);
      expect(find.text('My Wallet'), findsOneWidget);
      expect(find.text('Promotions'), findsOneWidget);
    },
  );
}
