import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/app/providers.dart';
import 'package:passenger/features/home/repositories/geocoding_service.dart';
import 'package:passenger/features/home/models/location_search_mode.dart';
import 'package:passenger/features/home/views/location_picker_screen.dart';
import 'package:passenger/features/ride_history/view_models/ride_history_list_view_model.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide LatLng, NearbyDriver, ServiceArea;
import 'package:shared_preferences/shared_preferences.dart';

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

/// Builds the JSON-encoded string list persisted by
/// [RecentLocationsNotifier] under `recent_pickup_locations` /
/// `recent_destination_locations`.
List<String> _storedRecents(List<RideLocation> locations) => locations
    .map(
      (loc) => jsonEncode({'lat': loc.lat, 'lng': loc.lng, 'address': loc.address}),
    )
    .toList();

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SakaiAnimatedBackdrop.debugDisableAnimations = true;
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
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
            sharedPreferencesProvider.overrideWithValue(prefs),
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
    'Hides the recents section when no recent locations are stored in SharedPreferences',
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
            sharedPreferencesProvider.overrideWithValue(prefs),
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

      expect(find.text('RECENT PICKUPS'), findsNothing);
    },
  );

  testWidgets(
    'Displays RECENT PICKUPS with formatted items from SharedPreferences capped at 6 for LocationSearchMode.pickup',
    (WidgetTester tester) async {
      // Use a tall viewport so all 6 recent tiles lay out without scrolling.
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final fakeHistory = _FakeRideHistoryNotifier(
        const RideHistoryListState(
          status: RideHistoryStatus.success,
          items: [],
        ),
      );

      await prefs.setStringList(
        'recent_pickup_locations',
        _storedRecents([
          const RideLocation(lat: 1, lng: 1, address: 'Mall of Asia, Pasay'),
          const RideLocation(lat: 2, lng: 2, address: 'Ayala Malls, Makati'),
          const RideLocation(lat: 3, lng: 3, address: 'Ortigas Center, Pasig'),
          const RideLocation(lat: 4, lng: 4, address: 'Greenhills, San Juan'),
          const RideLocation(lat: 5, lng: 5, address: 'Cubao, Quezon City'),
          const RideLocation(lat: 6, lng: 6, address: 'BGC, Taguig'),
          const RideLocation(
            lat: 7,
            lng: 7,
            address: 'Manila Bay, Manila',
          ), // 7th item, should be capped out
        ]),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
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
    'Displays RECENT DESTINATIONS with formatted items from SharedPreferences capped at 6 for LocationSearchMode.destination',
    (WidgetTester tester) async {
      // Use a tall viewport so all 6 recent tiles lay out without scrolling.
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final fakeHistory = _FakeRideHistoryNotifier(
        const RideHistoryListState(
          status: RideHistoryStatus.success,
          items: [],
        ),
      );

      await prefs.setStringList(
        'recent_destination_locations',
        _storedRecents([
          const RideLocation(lat: 1, lng: 1, address: 'NAIA Terminal 3, Pasay'),
          const RideLocation(
            lat: 2,
            lng: 2,
            address: 'Alabang Town Center, Muntinlupa',
          ),
          const RideLocation(
            lat: 3,
            lng: 3,
            address: 'UP Town Center, Quezon City',
          ),
          const RideLocation(lat: 4, lng: 4, address: 'Eastwood City, Libis'),
          const RideLocation(
            lat: 5,
            lng: 5,
            address: 'Robinsons Galleria, Ortigas',
          ),
          const RideLocation(
            lat: 6,
            lng: 6,
            address: 'SM North Edsa, Quezon City',
          ),
          const RideLocation(
            lat: 7,
            lng: 7,
            address: 'Intramuros, Manila',
          ), // 7th item, should be capped out
        ]),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
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
    'Tapping a stored recent location immediately pops it without re-geocoding',
    (WidgetTester tester) async {
      final fakeHistory = _FakeRideHistoryNotifier(
        const RideHistoryListState(
          status: RideHistoryStatus.success,
          items: [],
        ),
      );

      await prefs.setStringList(
        'recent_pickup_locations',
        _storedRecents([
          const RideLocation(
            lat: 14.5378,
            lng: 120.9822,
            address: 'Mall of Asia, Pasay',
          ),
        ]),
      );

      RideLocation? poppedLocation;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
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

      // Tap the stored recent pickup tile.
      await tester.tap(find.text('Mall of Asia'));
      await tester.pumpAndSettle();

      // Verify it popped immediately with the stored coordinates (no
      // geocoding call needed for a recent tap).
      expect(poppedLocation, isNotNull);
      expect(poppedLocation!.address, equals('Mall of Asia, Pasay'));
      expect(poppedLocation!.lat, equals(14.5378));
      expect(poppedLocation!.lng, equals(120.9822));
    },
  );

  testWidgets(
    'Displays error snackbar if geocoding fails on confirming a search suggestion',
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
            sharedPreferencesProvider.overrideWithValue(prefs),
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

      // Type a query that yields autocomplete suggestions containing
      // 'Fail', which the fake geocoding service rejects on confirm.
      await tester.enterText(find.byType(TextField), 'Fail');
      await tester.pump(const Duration(milliseconds: 400)); // debounce
      await tester.pumpAndSettle();

      // Tap suggestion to trigger geocode.
      await tester.tap(find.text('Suggestion 1 for Fail'));
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
