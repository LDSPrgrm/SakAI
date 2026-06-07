import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/app/providers.dart';
import 'package:passenger/features/home/repositories/geocoding_service.dart';
import 'package:passenger/features/home/views/destination_sheet.dart';
import 'package:passenger/features/home/views/location_picker_screen.dart';
import 'package:passenger/features/ride_history/models/ride_history_item.dart';
import 'package:passenger/features/ride_history/view_models/ride_history_list_view_model.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide LatLng, NearbyDriver, ServiceArea;

class _FakeRideHistoryNotifier extends RideHistoryListNotifier {
  _FakeRideHistoryNotifier(this._state);
  final RideHistoryListState _state;
  bool loadHistoryCalled = false;

  @override
  RideHistoryListState build() => _state;

  @override
  Future<void> loadHistory({bool refresh = false}) async {
    loadHistoryCalled = true;
  }
}

class _FakeGeocodingService extends GeocodingService {
  @override
  Future<RideLocation> geocode(String query) async {
    if (query.contains('error') || query.contains('Fail')) {
      throw Exception('Failed to geocode');
    }
    return RideLocation(lat: 1.23, lng: 4.56, address: query);
  }

  @override
  Future<List<String>> getSuggestions(
    String query, {
    String? location,
    double? radius,
    bool strictBounds = false,
  }) async {
    return ['Suggestion 1 for $query', 'Suggestion 2 for $query'];
  }
}

RideHistoryItem _item(int i, {String? origin, String? destination}) =>
    RideHistoryItem(
      id: 'r$i',
      status: RideStatus.completed,
      originAddress: origin ?? 'Origin $i, Area $i',
      destinationAddress: destination ?? 'Destination $i, Area $i',
      fare: 150 + i.toDouble(),
      estimatedFare: 150 + i.toDouble(),
      paymentMethod: 'cash',
      createdAt: DateTime.now().subtract(Duration(days: i)),
      updatedAt: DateTime.now().subtract(Duration(days: i)),
    );

void main() {
  setUp(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = true;
  });

  tearDown(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = false;
  });

  testWidgets(
    'Triggers ride history load in initState when status is RideHistoryStatus.initial',
    (WidgetTester tester) async {
      final fakeHistory = _FakeRideHistoryNotifier(
        const RideHistoryListState(status: RideHistoryStatus.initial),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideHistoryListNotifierProvider.overrideWith(() => fakeHistory),
            geocodingServiceProvider.overrideWithValue(_FakeGeocodingService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const LocationPickerScreen(mode: LocationSearchMode.pickup),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(fakeHistory.loadHistoryCalled, isTrue);
    },
  );

  testWidgets(
    'Falls back to suggested transit points when history status is success but items are empty',
    (WidgetTester tester) async {
      final fakeHistory = _FakeRideHistoryNotifier(
        const RideHistoryListState(
          status: RideHistoryStatus.success,
          items: [],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideHistoryListNotifierProvider.overrideWith(() => fakeHistory),
            geocodingServiceProvider.overrideWithValue(_FakeGeocodingService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const LocationPickerScreen(mode: LocationSearchMode.pickup),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('SUGGESTED TRANSIT POINTS'), findsOneWidget);
      expect(find.text('Central Business District Office'), findsOneWidget);
      expect(find.text('Metro Residences Sector 4'), findsOneWidget);
    },
  );

  testWidgets(
    'Falls back to suggested transit points when history status is success but items have only empty addresses',
    (WidgetTester tester) async {
      final fakeHistory = _FakeRideHistoryNotifier(
        RideHistoryListState(
          status: RideHistoryStatus.success,
          items: [_item(1, origin: '   ', destination: '')],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideHistoryListNotifierProvider.overrideWith(() => fakeHistory),
            geocodingServiceProvider.overrideWithValue(_FakeGeocodingService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const LocationPickerScreen(mode: LocationSearchMode.pickup),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('SUGGESTED TRANSIT POINTS'), findsOneWidget);
      expect(find.text('Central Business District Office'), findsOneWidget);
    },
  );

  testWidgets(
    'Displays RECENT PICKUPS with formatted and duplicate-filtered unique items capped at 6 for LocationSearchMode.pickup',
    (WidgetTester tester) async {
      final fakeHistory = _FakeRideHistoryNotifier(
        RideHistoryListState(
          status: RideHistoryStatus.success,
          items: [
            _item(1, origin: 'Mall of Asia, Pasay'),
            _item(2, origin: 'Mall of Asia, Pasay'), // Duplicate
            _item(3, origin: 'Ayala Malls, Makati'),
            _item(4, origin: 'Ortigas Center, Pasig'),
            _item(5, origin: 'Greenhills, San Juan'),
            _item(6, origin: 'Cubao, Quezon City'),
            _item(7, origin: 'BGC, Taguig'),
            _item(
              8,
              origin: 'Manila Bay, Manila',
            ), // 7th unique item, should be capped out
          ],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideHistoryListNotifierProvider.overrideWith(() => fakeHistory),
            geocodingServiceProvider.overrideWithValue(_FakeGeocodingService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const LocationPickerScreen(mode: LocationSearchMode.pickup),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('RECENT PICKUPS'), findsOneWidget);

      // Verify format and items present
      expect(find.text('Mall of Asia'), findsOneWidget);
      expect(find.text('Recent Pickup · Pasay'), findsOneWidget);

      expect(find.text('Ayala Malls'), findsOneWidget);
      expect(find.text('Recent Pickup · Makati'), findsOneWidget);

      expect(find.text('BGC'), findsOneWidget);
      expect(find.text('Recent Pickup · Taguig'), findsOneWidget);

      // Manila Bay should not be present because it exceeds the limit of 6
      expect(find.text('Manila Bay'), findsNothing);
    },
  );

  testWidgets(
    'Displays RECENT DESTINATIONS with formatted and duplicate-filtered unique items capped at 6 for LocationSearchMode.destination',
    (WidgetTester tester) async {
      final fakeHistory = _FakeRideHistoryNotifier(
        RideHistoryListState(
          status: RideHistoryStatus.success,
          items: [
            _item(1, destination: 'NAIA Terminal 3, Pasay'),
            _item(2, destination: 'NAIA Terminal 3, Pasay'), // Duplicate
            _item(3, destination: 'Alabang Town Center, Muntinlupa'),
            _item(4, destination: 'UP Town Center, Quezon City'),
            _item(5, destination: 'Eastwood City, Libis'),
            _item(6, destination: 'Robinsons Galleria, Ortigas'),
            _item(7, destination: 'SM North Edsa, Quezon City'),
            _item(
              8,
              destination: 'Intramuros, Manila',
            ), // 7th unique item, should be capped out
          ],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideHistoryListNotifierProvider.overrideWith(() => fakeHistory),
            geocodingServiceProvider.overrideWithValue(_FakeGeocodingService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const LocationPickerScreen(
                mode: LocationSearchMode.destination,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('RECENT DESTINATIONS'), findsOneWidget);

      // Verify items present
      expect(find.text('NAIA Terminal 3'), findsOneWidget);
      expect(find.text('Recent Destination · Pasay'), findsOneWidget);

      expect(find.text('Alabang Town Center'), findsOneWidget);
      expect(find.text('Recent Destination · Muntinlupa'), findsOneWidget);

      expect(find.text('SM North Edsa'), findsOneWidget);
      expect(find.text('Recent Destination · Quezon City'), findsNWidgets(2));

      // Intramuros should not be present because it exceeds the limit of 6
      expect(find.text('Intramuros'), findsNothing);
    },
  );

  testWidgets(
    'Tapping fallback suggested item immediately pops resolved RideLocation',
    (WidgetTester tester) async {
      final fakeHistory = _FakeRideHistoryNotifier(
        const RideHistoryListState(
          status: RideHistoryStatus.success,
          items: [],
        ),
      );

      RideLocation? poppedLocation;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideHistoryListNotifierProvider.overrideWith(() => fakeHistory),
            geocodingServiceProvider.overrideWithValue(_FakeGeocodingService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      poppedLocation = await Navigator.of(context)
                          .push<RideLocation>(
                            MaterialPageRoute(
                              builder: (_) => const LocationPickerScreen(
                                mode: LocationSearchMode.pickup,
                              ),
                            ),
                          );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open LocationPickerScreen
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap first suggested transit point which does not have lat/lng coordinates defined in static fallback
      // Wait, static fallback suggests:
      // name: 'Central Business District Office', address: '120 Pine St', lat/lng is null.
      // So it will trigger geocode.
      await tester.tap(find.text('Central Business District Office'));
      await tester.pumpAndSettle();

      // Verify it popped successfully
      expect(poppedLocation, isNotNull);
      expect(
        poppedLocation!.address,
        equals('Central Business District Office, 120 Pine St'),
      );
    },
  );

  testWidgets(
    'Tapping a recent address suggestions geocodes and pops resolved RideLocation',
    (WidgetTester tester) async {
      final fakeHistory = _FakeRideHistoryNotifier(
        RideHistoryListState(
          status: RideHistoryStatus.success,
          items: [_item(1, origin: 'Mall of Asia, Pasay')],
        ),
      );

      RideLocation? poppedLocation;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideHistoryListNotifierProvider.overrideWith(() => fakeHistory),
            geocodingServiceProvider.overrideWithValue(_FakeGeocodingService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      poppedLocation = await Navigator.of(context)
                          .push<RideLocation>(
                            MaterialPageRoute(
                              builder: (_) => const LocationPickerScreen(
                                mode: LocationSearchMode.pickup,
                              ),
                            ),
                          );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open LocationPickerScreen
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap recent pickup suggestion
      await tester.tap(find.text('Mall of Asia'));
      await tester.pumpAndSettle();

      // Verify it popped successfully with the resolved mock location
      expect(poppedLocation, isNotNull);
      expect(poppedLocation!.address, equals('Mall of Asia, Pasay'));
      expect(poppedLocation!.lat, equals(1.23));
      expect(poppedLocation!.lng, equals(4.56));
    },
  );

  testWidgets(
    'Displays error snackbar if geocoding fails on tapping suggestion',
    (WidgetTester tester) async {
      final fakeHistory = _FakeRideHistoryNotifier(
        RideHistoryListState(
          status: RideHistoryStatus.success,
          items: [_item(1, origin: 'Fail Location, Area')],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideHistoryListNotifierProvider.overrideWith(() => fakeHistory),
            geocodingServiceProvider.overrideWithValue(_FakeGeocodingService()),
          ],
          child: MaterialApp(
            theme: SakaiTheme.light(SakaiThemeConfig.passenger()),
            home: Scaffold(
              body: const LocationPickerScreen(mode: LocationSearchMode.pickup),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap suggestion to trigger geocode
      await tester.tap(find.text('Fail Location'));
      await tester.pump(); // Start execution

      // Pump and wait for snackbar
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(
        find.text('Could not resolve address. Try again.'),
        findsOneWidget,
      );
    },
  );
}
