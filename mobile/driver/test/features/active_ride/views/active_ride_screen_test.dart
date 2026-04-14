import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'package:driver/features/active_ride/views/active_ride_screen.dart';
import 'package:driver/features/active_ride/repositories/active_ride_repository.dart';
import 'package:driver/app/providers.dart';

class _MockActiveRideRepository implements ActiveRideRepository {
  @override
  Future<void> arriveAtPickup(String rideId, LatLng driverLocation) async {}

  @override
  Future<void> startRide(String rideId) async {}

  @override
  Future<void> completeRide(String rideId, LatLng driverLocation) async {}

  @override
  Future<void> cancelRide(String rideId) async {}

  @override
  Future<RideResponse?> getActiveRide() async {
    return null;
  }
}

void main() {
  final mockRepo = _MockActiveRideRepository();
  final themeConfig = SakaiThemeConfig.driver();

  $RideResponse createMockRide(RideStatus status) {
    return $RideResponse(
      (b) => b
        ..id = 'ride-123'
        ..status = status
        ..passenger = $UserProfile(
          (b) => b
            ..id = 'user-123'
            ..name = 'John Doe'
            ..email = 'john@example.com'
            ..role = UserProfileRoleEnum.passenger
            ..createdAt = DateTime.now(),
        )
        ..origin = LatLng(
          (b) => b
            ..lat = 14.5995
            ..lng = 120.9842,
        ).toBuilder()
        ..destination = LatLng(
          (b) => b
            ..lat = 14.6090
            ..lng = 121.0200,
        ).toBuilder()
        ..originAddress = '123 Main St'
        ..destinationAddress = '456 Market St'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),
    );
  }

  group('ActiveRideScreen', () {
    testWidgets('shows en route state with correct buttons', (tester) async {
      final ride = createMockRide(RideStatus.accepted);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [activeRideRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp(
            theme: SakaiTheme.light(themeConfig),
            home: ActiveRideScreen(initialRide: ride),
          ),
        ),
      );

      expect(find.text('Active Ride'), findsOneWidget);
      expect(find.text('En Route'), findsOneWidget);
      expect(find.text("I've Arrived"), findsOneWidget);
      expect(find.text('Navigate'), findsOneWidget);
      expect(find.text('Cancel Ride'), findsOneWidget);
      expect(find.text('Start Ride'), findsNothing);
      expect(find.text('Complete Ride'), findsNothing);
    });

    testWidgets('shows arrived state with correct buttons', (tester) async {
      final ride = createMockRide(RideStatus.arrived);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [activeRideRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp(
            theme: SakaiTheme.light(themeConfig),
            home: ActiveRideScreen(initialRide: ride),
          ),
        ),
      );

      expect(find.text('Arrived'), findsOneWidget);
      expect(find.text('Start Ride'), findsOneWidget);
      expect(find.text('Cancel Ride'), findsOneWidget);
      expect(find.text("I've Arrived"), findsNothing);
      expect(find.text('Complete Ride'), findsNothing);
    });

    testWidgets('shows in progress state with complete button only', (
      tester,
    ) async {
      final ride = createMockRide(RideStatus.inProgress);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [activeRideRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp(
            theme: SakaiTheme.light(themeConfig),
            home: ActiveRideScreen(initialRide: ride),
          ),
        ),
      );

      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Complete Ride'), findsOneWidget);
      expect(
        find.text('Cancel Ride'),
        findsNothing,
      ); // Cancel hidden when in progress
      expect(find.text('Start Ride'), findsNothing);
      expect(find.text("I've Arrived"), findsNothing);
    });
  });
}
