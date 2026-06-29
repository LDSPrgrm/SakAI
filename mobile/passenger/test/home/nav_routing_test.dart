library;

/// nav_routing_test.dart
///
/// Regression test for the passenger bottom-nav Account tab.
///
/// Context: `RiderHomeScreen`'s `_currentIndex` switch previously routed
/// index 3 ("Account") to the dead `InboxScreen` mock instead of the real
/// `ProfileScreen`. This test proves the Account tab renders `ProfileScreen`
/// after the fix.
///
/// NOTE: This test intentionally does NOT import or reference `InboxScreen`.
/// A follow-up task deletes the inbox feature entirely; asserting its
/// absence by type here would create a coupling that breaks that deletion.
/// Proving the positive (ProfileScreen renders) is sufficient.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide LatLng, NearbyDriver, ServiceArea;

import 'package:passenger/features/home/view_models/home_notifier.dart';
import 'package:passenger/features/home/views/rider_home_screen.dart';
import 'package:passenger/features/home/views/profile_screen.dart';
import 'package:passenger/features/profile/models/user_profile.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

/// Deterministic idle `HomeNotifier` — avoids Geolocator/network during the
/// `initState` postFrameCallback in `RiderHomeScreen`.
class _FakeHomeNotifier extends HomeNotifier {
  @override
  HomeState build() => const HomeState(status: HomeStatus.idle);

  @override
  Future<void> initLocation() async {}
}

/// Deterministic loaded `ProfileNotifier` — avoids the real API call that
/// `ProfileScreen` triggers on first build when status is `initial`.
class _FakeProfileNotifier extends ProfileNotifier {
  @override
  ProfileState build() => ProfileState(
        status: ProfileStatus.loaded,
        profile: UserProfileModel(
          id: 'fake-user-id',
          name: 'Test Rider',
          email: 'rider@example.com',
          role: 'passenger',
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      );

  @override
  Future<void> loadProfile() async {}

  @override
  Future<void> refresh() async {}
}

// ─────────────────────────────────────────────────────────────────────────────
// Harness
// ─────────────────────────────────────────────────────────────────────────────

Future<void> pumpRiderHome(WidgetTester tester) async {
  SakaiAnimatedBackdrop.debugDisableAnimations = true;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeNotifierProvider.overrideWith(() => _FakeHomeNotifier()),
        profileNotifierProvider.overrideWith(() => _FakeProfileNotifier()),
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

  testWidgets('Account tab opens Profile', (tester) async {
    await pumpRiderHome(tester);

    // Tap the 4th bottom-nav item ("Account", person icon) by index.
    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('Account nav label is present and tappable', (tester) async {
    await pumpRiderHome(tester);

    expect(find.text('Account'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
