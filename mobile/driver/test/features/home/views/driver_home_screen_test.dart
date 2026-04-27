import 'package:driver/app/providers.dart';
import 'package:driver/features/home/views/driver_home_screen.dart';
import 'package:driver/features/home/repositories/driver_repository.dart';
import 'package:driver/features/active_ride/repositories/active_ride_repository.dart';
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
  Future<void> cancelRide(String rideId) async {}
}

final _mockDriverRepo = MockDriverRepository();
final _mockActiveRideRepo = MockActiveRideRepository();

void main() {
  testWidgets('DriverHomeScreen renders toggle button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wsClientProvider.overrideWithValue(WsClient()),
          apiClientProvider.overrideWithValue(_mockApiClient),
          driverRepositoryProvider.overrideWithValue(_mockDriverRepo),
          activeRideRepositoryProvider.overrideWithValue(_mockActiveRideRepo),
        ],
        child: MaterialApp(
          theme: SakaiTheme.light(_themeConfig),
          home: DriverHomeScreen(),
        ),
      ),
    );

    // Initially driver is offline
    expect(find.text('Unavailable'), findsOneWidget);
    expect(find.text('Start shift'), findsOneWidget);
    expect(find.text('View earnings'), findsOneWidget);
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
}
