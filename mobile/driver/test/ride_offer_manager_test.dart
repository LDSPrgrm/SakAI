import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:driver/features/ride_offer/models/ride_offer_state.dart';
import 'package:driver/features/ride_offer/view_models/ride_offer_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:sakai_shared/sakai_shared.dart';

class _TestAdapter implements HttpClientAdapter {
  _TestAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late SakaiApiClient client;
  late RideOfferManager manager;
  late RideOfferState mockOffer;

  setUp(() {
    client = SakaiApiClient(basePathOverride: 'https://api.test');
    final now = DateTime.now();
    mockOffer = RideOfferState(
      rideId: 'ride-123',
      passenger: $UserProfile(
        (u) => u
          ..id = 'user-1'
          ..email = 'test@test.com'
          ..name = 'Test'
          ..role = UserProfileRoleEnum.passenger
          ..createdAt = now,
      ),
      origin: LatLng(
        (l) => l
          ..lat = 0
          ..lng = 0,
      ),
      destination: LatLng(
        (l) => l
          ..lat = 1
          ..lng = 1,
      ),
      expiresAt: now.add(const Duration(seconds: 30)),
    );
    manager = RideOfferManager(apiClient: client, offer: mockOffer);
  });

  group('RideOfferManager.acceptRide', () {
    test('successfully accepts ride', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.contains('/rides/ride-123/accept') &&
            options.method == 'POST') {
          called = true;
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      String? acceptedRideId;
      manager.onAccepted = (id) => acceptedRideId = id;

      await manager.acceptRide();

      expect(called, isTrue);
      expect(acceptedRideId, 'ride-123');
      expect(manager.accepting, isFalse);
      expect(manager.error, isNull);
    });

    test('handles 409 conflict (already accepted)', () async {
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Conflict'}),
          409,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await manager.acceptRide();

      expect(manager.error, contains('no longer available'));
      expect(manager.accepting, isFalse);
    });

    test('retries on failure and eventually fails', () async {
      int attempts = 0;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        attempts++;
        return ResponseBody.fromString('Error', 500);
      });

      // Override the delay to make tests faster if needed, but here we just wait
      // In a real scenario we might want to mock the delay if it was long.
      // But 3 attempts with 1s delay = 2s total waiting.

      final future = manager.acceptRide();
      await future;

      expect(attempts, 3);
      expect(manager.error, contains('Accept failed'));
    });
  });

  group('RideOfferManager.declineRide', () {
    test('successfully declines ride', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.contains('/rides/ride-123/decline') &&
            options.method == 'POST') {
          called = true;
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      bool declinedTriggered = false;
      manager.onDeclined = () => declinedTriggered = true;

      await manager.declineRide();

      expect(called, isTrue);
      expect(declinedTriggered, isTrue);
      expect(manager.declining, isFalse);
    });
  });

  group('RideOfferManager countdown', () {
    test('notifies on expiration', () async {
      final now = DateTime.now();
      // Create an offer that expires in 1 second

      final manager2 = RideOfferManager(
        apiClient: client,
        offer: RideOfferState(
          rideId: 'ride-exp',
          passenger: mockOffer.passenger,
          origin: mockOffer.origin,
          destination: mockOffer.destination,
          expiresAt: now.add(const Duration(milliseconds: 500)),
        ),
      );

      bool expired = false;
      manager2.onExpired = () => expired = true;

      manager2.startCountdown();

      // Wait for more than 1 second to ensure the periodic timer ticks
      await Future.delayed(const Duration(milliseconds: 1200));

      expect(expired, isTrue);
      manager2.dispose();
    });
  });
}
