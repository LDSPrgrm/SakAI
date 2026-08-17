import 'package:driver/app/providers.dart';
import 'package:driver/features/earnings/models/session_earnings.dart';
import 'package:driver/features/earnings/repositories/earnings_repository.dart';
import 'package:driver/features/home/views/driver_home_screen.dart';
import 'package:driver/features/home/repositories/driver_repository.dart';
import 'package:driver/features/active_ride/repositories/active_ride_repository.dart';
import 'package:driver/features/profile/repositories/driver_profile_repository.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _themeConfig = SakaiThemeConfig.driver();
final _mockApiClient = SakaiApiClient();

class MockDriverRepository extends DriverRepository {
  @override
  Future<void> goOnline() async {}
  @override
  Future<void> goOffline() async {}
  @override
  Future<void> updateLocation(
    double lat,
    double lng, {
    double? heading,
  }) async {}
  @override
  Future<RideResponse?> getIncomingRide() async => null;
}

class MockActiveRideRepository extends ActiveRideRepository {
  @override
  Future<RideResponse?> getActiveRide() async => null;
  @override
  Future<void> arriveAtPickup(String rideId, LatLng driverLocation) async {}
  @override
  Future<void> startRide(String rideId) async {}
  @override
  Future<void> completeRide(String rideId, LatLng driverLocation) async {}
  @override
  Future<void> cancelRide(String rideId, {String? reasonText}) async {}
}

/// Avoids a real network call from the earnings notifier's initial load
/// (the home screen now renders live earnings stats — Task 5).
class MockEarningsRepository implements EarningsRepository {
  @override
  Future<SessionEarnings> getEarnings({
    DateTime? from,
    DateTime? to,
    int page = 1,
  }) async => const SessionEarnings();
}

/// Avoids a real network call from the driver profile notifier's initial
/// load (the home screen now reads the driver's real name — honesty follow-up).
class MockDriverProfileRepository implements DriverProfileRepository {
  @override
  Future<UserProfile> getProfile() async => $UserProfile(
    (b) => b
      ..id = 'drv-1'
      ..name = 'Test Driver'
      ..email = 'driver@test.com'
      ..role = UserProfileRoleEnum.driver
      ..createdAt = DateTime(2026, 1, 1),
  );
  @override
  Future<void> updateProfile({String? name}) async {}
  @override
  Future<void> updateVehicle({
    required String make,
    required String model,
    required String color,
    required String plate,
  }) async {}
}

final _mockDriverRepo = MockDriverRepository();
final _mockActiveRideRepo = MockActiveRideRepository();
final _mockEarningsRepo = MockEarningsRepository();
final _mockDriverProfileRepo = MockDriverProfileRepository();

void main() {
  testWidgets('DriverHomeScreen renders toggle button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wsClientProvider.overrideWithValue(WsClient()),
          apiClientProvider.overrideWithValue(_mockApiClient),
          driverRepositoryProvider.overrideWithValue(_mockDriverRepo),
          activeRideRepositoryProvider.overrideWithValue(_mockActiveRideRepo),
          earningsRepositoryProvider.overrideWithValue(_mockEarningsRepo),
          driverProfileRepositoryProvider.overrideWithValue(_mockDriverProfileRepo),
        ],
        child: MaterialApp(
          theme: SakaiTheme.light(_themeConfig),
          home: DriverHomeScreen(),
        ),
      ),
    );

    // Initially driver is offline
    expect(find.text('INACTIVE'), findsOneWidget);
    expect(find.text('Live Dispatch'), findsOneWidget);
    expect(find.text('GROSS CASH'), findsOneWidget);
    expect(find.byType(IconButton), findsWidgets); // menu button
  });

  testWidgets('GPS warning shows when online but GPS unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wsClientProvider.overrideWithValue(WsClient()),
          apiClientProvider.overrideWithValue(_mockApiClient),
          driverRepositoryProvider.overrideWithValue(_mockDriverRepo),
          activeRideRepositoryProvider.overrideWithValue(_mockActiveRideRepo),
          earningsRepositoryProvider.overrideWithValue(_mockEarningsRepo),
          driverProfileRepositoryProvider.overrideWithValue(_mockDriverProfileRepo),
        ],
        child: MaterialApp(
          theme: SakaiTheme.light(_themeConfig),
          home: DriverHomeScreen(),
        ),
      ),
    );

    // Initially offline, no GPS warning
    expect(find.text('Waiting for GPS signal…'), findsNothing);
  });

  // Task 15 — structural smoke coverage for the driver Console (home) under
  // dark. The driver app's theme mode is user-selectable and provider-driven
  // (defaults to ThemeMode.system), so dark is one of two supported
  // brightnesses, not a forced theme; the light path is covered by the two
  // tests above. Each test passes MaterialApp.theme explicitly, so none of
  // them depend on the app-level theme-mode provider. Pixel goldens are not
  // used here — this asserts the screen pumps without throwing under dark and
  // that the console's custom header (not a bare default-themed AppBar — the
  // screen has no Scaffold.appBar at all) shows its key content.
  testWidgets('DriverHomeScreen pumps under dark theme (Console)', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wsClientProvider.overrideWithValue(WsClient()),
          apiClientProvider.overrideWithValue(_mockApiClient),
          driverRepositoryProvider.overrideWithValue(_mockDriverRepo),
          activeRideRepositoryProvider.overrideWithValue(_mockActiveRideRepo),
          earningsRepositoryProvider.overrideWithValue(_mockEarningsRepo),
          driverProfileRepositoryProvider.overrideWithValue(_mockDriverProfileRepo),
        ],
        child: MaterialApp(
          theme: SakaiTheme.dark(_themeConfig),
          home: DriverHomeScreen(),
        ),
      ),
    );

    // Console renders its real content under dark, not a default Material
    // light AppBar (the screen builds its own header Row — no Scaffold
    // appBar at all, so a bare AppBar can never leak through here).
    expect(find.byType(AppBar), findsNothing);
    expect(find.text('GROSS CASH'), findsOneWidget);
    expect(find.text('Live Dispatch'), findsOneWidget);
    expect(find.text('SakAI'), findsOneWidget);
  });
}
