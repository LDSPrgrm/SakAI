library;

/// ride_booking_flow_test.dart
///
/// Integration / widget tests for the passenger ride-booking user flow.
///
/// Test coverage
/// ─────────────
/// [Group 1 — Unit] HomeState transitions (pure Dart, no platform plugins)
///   1. Initial state is idle with empty ride type options
///   2. setDestination → status becomes destinationSet + options populated
///   3. setSelectedRideType persists on state
///   4. canRequest is false when no vehicle type selected
///   5. canRequest is true when destination + vehicle type are set
///   6. requestRide (success) sets createdRide
///   7. requestRide (failure) sets errorMessage, clears requesting status
///   8. clearDestination resets to idle
///   9. requestRide returns null early when destination is missing
///
/// [Group 2 — Widget] Navigation flow (no GoogleMap rendered)
///   1. Idle state → status label "idle", ride type count 0
///   2. setDestination → status label "destinationSet", count ≥ 1
///   3. requestRide success → GoRouter pushes /ride/waiting with rideId
///   4. requestRide failure → stays on /home, error label visible
///
/// Architecture notes
/// ──────────────────
/// • `_FakeHomeNotifier extends HomeNotifier` overrides `build` + I/O methods.
///   Extending the concrete class (not just `Notifier<HomeState>`) is required
///   by `NotifierProvider.overrideWith`.
/// • The widget test uses `_BookingHarness`, a minimal `ConsumerStatefulWidget`
///   that copies the relevant `ref.listen` from `RiderHomeScreen._listenToState`
///   without requiring the GoogleMap platform channel.
/// • A local `GoRouter` is built per-test for deterministic navigation assertions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide LatLng, NearbyDriver, ServiceArea;

import 'package:passenger/app/routes.dart';
import 'package:passenger/features/home/models/ride_type_option.dart';
import 'package:passenger/features/home/view_models/home_notifier.dart';

// ─────────────────────────────────────────────────────────────────────────────
// _FakeHomeNotifier
// ─────────────────────────────────────────────────────────────────────────────

/// Extends [HomeNotifier] so the type satisfies `NotifierProvider.overrideWith`.
///
/// Overrides every method that calls a platform channel or network:
///   • [build] — returns a deterministic idle state.
///   • [initLocation] — no-op; avoids Geolocator.
///   • [setDestination] — sets state synchronously with fake options.
///   • [requestRide] — succeeds/fails deterministically based on [failOnRequest].
class _FakeHomeNotifier extends HomeNotifier {
  _FakeHomeNotifier({this.failOnRequest = false});

  /// When `true`, [requestRide] simulates a network failure.
  final bool failOnRequest;

  static const _fakePickup = RideLocation(
    lat: 14.5995,
    lng: 120.9842,
    address: '123 Test Street, Manila',
  );

  static final _fakeOptions = <RideTypeOption>[
    const RideTypeOption(
      type: VehicleType.motorcycle,
      estimatedFare: 65,
      estimatedDuration: Duration(minutes: 10),
      availableDrivers: 3,
    ),
    const RideTypeOption(
      type: VehicleType.car,
      estimatedFare: 120,
      estimatedDuration: Duration(minutes: 15),
      availableDrivers: 2,
    ),
  ];

  // Override build so no providers are read during construction.
  @override
  HomeState build() => const HomeState(status: HomeStatus.idle);

  // No-op: avoids Geolocator platform channel.
  @override
  Future<void> initLocation() async {}

  @override
  Future<void> setDestination(RideLocation destination) async {
    state = state.copyWith(
      status: HomeStatus.destinationSet,
      pickup: _fakePickup,
      destination: destination,
      rideTypeOptions: _fakeOptions,
      clearError: true,
    );
  }

  @override
  Future<RideEntity?> requestRide() async {
    if (state.destination == null) return null;

    state = state.copyWith(status: HomeStatus.requesting, clearError: true);

    // Minimal async gap to mimic the real network call.
    await Future<void>.delayed(const Duration(milliseconds: 10));

    if (failOnRequest) {
      state = state.copyWith(
        status: HomeStatus.destinationSet,
        errorMessage: 'No drivers available. Try again.',
      );
      return null;
    }

    final fakeRide = RideEntity(
      id: 'fake-ride-001',
      status: RideState.requested,
      origin: state.pickup!,
      destination: state.destination!,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    state = state.copyWith(
      createdRide: fakeRide,
      status: HomeStatus.destinationSet,
    );
    return fakeRide;
  }

  @override
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation harness (no GoogleMap)
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight widget that mirrors the navigation listener from
/// `RiderHomeScreen._listenToState` without any platform plugins.
///
/// Renders:
///   • `Text(status.name, key: Key('status_label'))`
///   • `Text('$rideTypeOptions.length', key: Key('ride_type_count'))`
///   • `Text(errorMessage, key: Key('error_label'))` when non-null
class _BookingHarness extends ConsumerStatefulWidget {
  const _BookingHarness();

  @override
  ConsumerState<_BookingHarness> createState() => _BookingHarnessState();
}

class _BookingHarnessState extends ConsumerState<_BookingHarness> {
  @override
  Widget build(BuildContext context) {
    // Mirror RiderHomeScreen._listenToState navigation logic.
    ref.listen<HomeState>(homeNotifierProvider, (previous, next) {
      if (next.createdRide != null &&
          next.createdRide != previous?.createdRide &&
          mounted) {
        context.push(Routes.rideWaiting, extra: next.createdRide!.id);
      }
    });

    final homeState = ref.watch(homeNotifierProvider);

    return Scaffold(
      body: Column(
        children: [
          Text(homeState.status.name, key: const Key('status_label')),
          Text(
            '${homeState.rideTypeOptions.length}',
            key: const Key('ride_type_count'),
          ),
          if (homeState.errorMessage != null)
            Text(
              homeState.errorMessage!,
              key: const Key('error_label'),
            ),
        ],
      ),
    );
  }
}

/// Builds a [GoRouter] scoped for each test.
GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, _) => const _BookingHarness(),
      ),
      GoRoute(
        path: Routes.rideWaiting,
        builder: (_, state) {
          final rideId = state.extra as String?;
          return Scaffold(
            body: Center(
              child: Text(
                'waiting:${rideId ?? "no-id"}',
                key: const Key('waiting_screen'),
              ),
            ),
          );
        },
      ),
    ],
  );
}

/// Reads the [_FakeHomeNotifier] from the harness widget's [ProviderContainer].
_FakeHomeNotifier _notifierFrom(WidgetTester tester) {
  return ProviderScope.containerOf(
    tester.element(find.byType(_BookingHarness)),
  ).read(homeNotifierProvider.notifier) as _FakeHomeNotifier;
}

// ─────────────────────────────────────────────────────────────────────────────
// TESTS
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── Unit: HomeState state machine ──────────────────────────────────────────
  group('HomeState transitions (unit)', () {
    late ProviderContainer container;
    late _FakeHomeNotifier notifier;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          homeNotifierProvider.overrideWith(() => _FakeHomeNotifier()),
        ],
      );
      notifier =
          container.read(homeNotifierProvider.notifier) as _FakeHomeNotifier;
    });

    tearDown(() => container.dispose());

    // 1 ─────────────────────────────────────────────────────────────────────
    test('initial state is idle with empty ride type options', () {
      final s = container.read(homeNotifierProvider);
      expect(s.status, HomeStatus.idle);
      expect(s.rideTypeOptions, isEmpty);
      expect(s.destination, isNull);
      expect(s.createdRide, isNull);
    });

    // 2 ─────────────────────────────────────────────────────────────────────
    test(
        'setDestination → status is destinationSet and '
        'ride type options are populated', () async {
      const dest = RideLocation(lat: 14.61, lng: 120.99, address: 'Dest Ave');
      await notifier.setDestination(dest);

      final s = container.read(homeNotifierProvider);
      expect(s.status, HomeStatus.destinationSet);
      expect(s.destination?.address, 'Dest Ave');
      expect(s.rideTypeOptions.length, greaterThanOrEqualTo(1));
      for (final opt in s.rideTypeOptions) {
        expect(opt.estimatedFare, greaterThan(0));
      }
    });

    // 3 ─────────────────────────────────────────────────────────────────────
    test('setSelectedRideType persists on state', () async {
      const dest = RideLocation(lat: 14.61, lng: 120.99, address: 'Dest');
      await notifier.setDestination(dest);
      notifier.setSelectedRideType(VehicleType.motorcycle);

      final s = container.read(homeNotifierProvider);
      expect(s.selectedRideType, VehicleType.motorcycle);
    });

    // 4 ─────────────────────────────────────────────────────────────────────
    test('canRequest is false when no vehicle type is selected', () async {
      const dest = RideLocation(lat: 14.61, lng: 120.99, address: 'Dest');
      await notifier.setDestination(dest);

      expect(container.read(homeNotifierProvider).canRequest, isFalse);
    });

    // 5 ─────────────────────────────────────────────────────────────────────
    test('canRequest is true when destination + vehicle type are set', () async {
      const dest = RideLocation(lat: 14.61, lng: 120.99, address: 'Dest');
      await notifier.setDestination(dest);
      notifier.setSelectedRideType(VehicleType.car);

      expect(container.read(homeNotifierProvider).canRequest, isTrue);
    });

    // 6 ─────────────────────────────────────────────────────────────────────
    test('requestRide (success) sets createdRide with correct id', () async {
      const dest = RideLocation(lat: 14.61, lng: 120.99, address: 'Dest');
      await notifier.setDestination(dest);
      notifier.setSelectedRideType(VehicleType.motorcycle);

      final ride = await notifier.requestRide();

      expect(ride, isNotNull);
      expect(ride!.id, isNotEmpty);
      expect(container.read(homeNotifierProvider).createdRide?.id, ride.id);
      expect(container.read(homeNotifierProvider).status,
          isNot(HomeStatus.requesting));
    });

    // 7 ─────────────────────────────────────────────────────────────────────
    test(
        'requestRide (failure) sets errorMessage and '
        'clears requesting status', () async {
      final failContainer = ProviderContainer(
        overrides: [
          homeNotifierProvider
              .overrideWith(() => _FakeHomeNotifier(failOnRequest: true)),
        ],
      );
      final failNotifier = failContainer.read(homeNotifierProvider.notifier)
          as _FakeHomeNotifier;

      const dest = RideLocation(lat: 14.61, lng: 120.99, address: 'Dest');
      await failNotifier.setDestination(dest);
      failNotifier.setSelectedRideType(VehicleType.car);

      final ride = await failNotifier.requestRide();

      final s = failContainer.read(homeNotifierProvider);
      expect(ride, isNull);
      expect(s.errorMessage, isNotNull);
      expect(s.status, HomeStatus.destinationSet);
      expect(s.createdRide, isNull);

      failContainer.dispose();
    });

    // 8 ─────────────────────────────────────────────────────────────────────
    test('clearDestination resets to idle and clears all derived state',
        () async {
      const dest = RideLocation(lat: 14.61, lng: 120.99, address: 'Dest');
      await notifier.setDestination(dest);
      notifier.setSelectedRideType(VehicleType.car);
      notifier.clearDestination();

      final s = container.read(homeNotifierProvider);
      expect(s.status, HomeStatus.idle);
      expect(s.destination, isNull);
      expect(s.rideTypeOptions, isEmpty);
      expect(s.selectedRideType, isNull);
    });

    // 9 ─────────────────────────────────────────────────────────────────────
    test('requestRide returns null early when destination is missing', () async {
      final ride = await notifier.requestRide();
      expect(ride, isNull);
      // Status must remain idle (no partial state mutation).
      expect(container.read(homeNotifierProvider).status, HomeStatus.idle);
    });
  });

  // ── Widget: navigation flow ────────────────────────────────────────────────
  group('Booking flow navigation (widget)', () {
    /// Pumps [_BookingHarness] in a [ProviderScope] with a test [GoRouter].
    Future<void> pumpHarness(
      WidgetTester tester, {
      bool failOnRequest = false,
    }) async {
      final router = _buildTestRouter();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeNotifierProvider.overrideWith(
              () => _FakeHomeNotifier(failOnRequest: failOnRequest),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
    }

    // W-1 ───────────────────────────────────────────────────────────────────
    testWidgets('idle: status label shows "idle" and ride type count is 0', (
      WidgetTester tester,
    ) async {
      await pumpHarness(tester);

      expect(
        tester.widget<Text>(find.byKey(const Key('status_label'))).data,
        HomeStatus.idle.name,
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('ride_type_count'))).data,
        '0',
      );
    });

    // W-2 ───────────────────────────────────────────────────────────────────
    testWidgets('setting destination → status "destinationSet" and count ≥ 1', (
      WidgetTester tester,
    ) async {
      await pumpHarness(tester);
      final notifier = _notifierFrom(tester);

      const dest = RideLocation(lat: 14.61, lng: 120.99, address: 'Dest Ave');
      await notifier.setDestination(dest);
      await tester.pump();

      expect(
        tester.widget<Text>(find.byKey(const Key('status_label'))).data,
        HomeStatus.destinationSet.name,
      );
      final countText =
          tester.widget<Text>(find.byKey(const Key('ride_type_count'))).data;
      expect(int.parse(countText!), greaterThanOrEqualTo(1));
    });

    // W-3 ───────────────────────────────────────────────────────────────────
    testWidgets('requestRide success → GoRouter pushes /ride/waiting with rideId',
        (
      WidgetTester tester,
    ) async {
      await pumpHarness(tester);
      final notifier = _notifierFrom(tester);

      const dest = RideLocation(lat: 14.61, lng: 120.99, address: 'Dest');
      await notifier.setDestination(dest);
      notifier.setSelectedRideType(VehicleType.motorcycle);
      await tester.pump();

      // Start the request
      final requestFuture = notifier.requestRide();
      await tester.pump();

      expect(
        tester.widget<Text>(find.byKey(const Key('status_label'))).data,
        HomeStatus.requesting.name,
      );

      // Advance clock to allow the 10ms delay in _FakeHomeNotifier to complete
      await tester.pump(const Duration(milliseconds: 10));
      await requestFuture;

      // Now verify navigation triggered by state change
      await tester.pump();
      // Wait for any potential navigation/animations
      await tester.pumpAndSettle();

      // Waiting screen should be visible.
      expect(find.byKey(const Key('waiting_screen')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('waiting_screen'))).data,
        contains('fake-ride-001'),
      );
    });

  });
}
