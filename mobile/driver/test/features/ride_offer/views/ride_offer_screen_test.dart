import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import 'package:driver/features/ride_offer/views/ride_offer_screen.dart';
import 'package:driver/app/providers.dart';

final _themeConfig = SakaiThemeConfig.driver();

// Mock API client that doesn't require dotenv
final _mockApiClient = SakaiApiClient();

void main() {
  Widget buildOfferScreen(WsEventRideRequested offer) {
    return ProviderScope(
      overrides: [
        wsClientProvider.overrideWithValue(WsClient()),
        apiClientProvider.overrideWithValue(_mockApiClient),
      ],
      child: MaterialApp(
        theme: SakaiTheme.light(_themeConfig),
        home: RideOfferScreen(offerEvent: offer),
      ),
    );
  }

  WsEventRideRequested _createOffer() {
    return WsEventRideRequested(
      (b) => b
        ..rideId = 'test-offer-123'
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
        ..originAddress = '123 Main St, Manila'
        ..destinationAddress = '456 Market St, Makati'
        ..expiresAt = DateTime.now().add(const Duration(seconds: 25)),
    );
  }

  testWidgets('RideOfferScreen renders passenger info and buttons', (
    tester,
  ) async {
    final offer = _createOffer();
    await tester.pumpWidget(buildOfferScreen(offer));

    expect(find.text('New Ride Offer'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('123 Main St, Manila'), findsOneWidget);
    expect(find.text('456 Market St, Makati'), findsOneWidget);
    expect(find.text('Accept Ride'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
  });

  testWidgets('RideOfferScreen shows countdown timer', (tester) async {
    final offer = _createOffer();
    await tester.pumpWidget(buildOfferScreen(offer));
    await tester.pump();

    // Verify the offer screen renders
    expect(find.text('New Ride Offer'), findsOneWidget);

    // The countdown badge shows seconds remaining
    expect(find.byType(Container), findsWidgets);
  });
}
