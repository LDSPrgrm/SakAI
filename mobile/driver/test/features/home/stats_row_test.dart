import 'package:driver/app/providers.dart';
import 'package:driver/features/active_ride/repositories/active_ride_repository.dart';
import 'package:driver/features/earnings/models/session_earnings.dart';
import 'package:driver/features/earnings/view_models/earnings_notifier.dart';
import 'package:driver/features/home/repositories/driver_repository.dart';
import 'package:driver/features/home/views/driver_home_screen.dart';
import 'package:driver/features/profile/repositories/driver_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

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

/// Notifier that returns a fixed [EarningsState] without hitting the
/// repository, so tests control earnings data directly.
class FakeEarningsNotifier extends EarningsNotifier {
  FakeEarningsNotifier(this._fixedState);

  final EarningsState _fixedState;

  @override
  EarningsState build() => _fixedState;
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
final _mockDriverProfileRepo = MockDriverProfileRepository();

Future<void> pumpStatsRow(
  WidgetTester tester, {
  required double totalEarnings,
  required int completedRides,
}) async {
  final fixedState = EarningsState(
    earnings: SessionEarnings(
      totalEarnings: totalEarnings,
      completedRidesCount: completedRides,
    ),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        wsClientProvider.overrideWithValue(WsClient()),
        apiClientProvider.overrideWithValue(_mockApiClient),
        driverRepositoryProvider.overrideWithValue(_mockDriverRepo),
        activeRideRepositoryProvider.overrideWithValue(_mockActiveRideRepo),
        earningsNotifierProvider.overrideWith(
          () => FakeEarningsNotifier(fixedState),
        ),
        driverProfileRepositoryProvider.overrideWithValue(_mockDriverProfileRepo),
      ],
      child: MaterialApp(
        theme: SakaiTheme.light(_themeConfig),
        home: const DriverHomeScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('stats row shows real earnings, not hardcoded mock', (
    tester,
  ) async {
    await pumpStatsRow(tester, totalEarnings: 250.0, completedRides: 7);

    expect(find.text('₱250.00'), findsOneWidget);
    expect(find.text('7 Rides'), findsOneWidget);
    expect(find.text('—'), findsOneWidget); // shift hours: no backend field
    expect(find.text('₱184.50'), findsNothing); // old mock gone
    expect(find.text('12 Rides'), findsNothing); // old mock gone
  });
}
