@TestOn('vm')
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:sakai_shared/ws/ws_client.dart';
import 'package:sakai_shared/ws/ws_dispatcher.dart';
import 'package:sakai_shared/ws/ws_events.dart';

/// A minimal stub WsClient that lets tests pump events without a socket.
class _StubClient implements WsClient {
  final _events = StreamController<WsEvent>.broadcast();
  final _malformed = StreamController<WsMalformedEvent>.broadcast();

  void pump(WsEvent event) => _events.add(event);

  @override
  Stream<WsEvent> get events => _events.stream;

  @override
  Stream<WsMalformedEvent> get malformed => _malformed.stream;

  Future<void> close() async {
    await _events.close();
    await _malformed.close();
  }

  // Unused members for the test.
  @override
  Future<void> connect({String? baseUrl, String? accessToken}) async {}
  @override
  Future<void> disconnect() async {}
  @override
  bool get isConnected => true;
  @override
  set onResync(VoidCallback cb) {}
}

void main() {
  group('WsDispatcher', () {
    test('routes ride.accepted to a typed handler', () async {
      final client = _StubClient();
      final dispatcher = WsDispatcher(client);

      WsEventRideAccepted? received;
      dispatcher.on<WsEventRideAccepted>(WsEventType.rideAccepted, (p) {
        received = p;
      });

      client.pump(WsEvent(
        type: 'ride.accepted',
        payload: {
          'ride_id': 'r1',
          'driver': {
            'id': 'd1',
            'name': 'Juan',
            'vehicle': {
              'make': 'Honda',
              'model': 'Click',
              'color': 'red',
              'plate': 'ABC123',
            },
          },
        },
      ));

      // Allow microtask drain.
      await Future<void>.delayed(Duration.zero);

      expect(received, isNotNull);
      expect(received!.rideId, 'r1');
      expect(received!.driver.name, 'Juan');

      dispatcher.dispose();
      await client.close();
    });

    test('driver.location_updated uses fast path (no built_value)', () async {
      final client = _StubClient();
      final dispatcher = WsDispatcher(client);

      DriverLocationFast? received;
      dispatcher.on<DriverLocationFast>(
        WsEventType.driverLocationUpdated,
        (p) => received = p,
      );

      client.pump(WsEvent(
        type: 'driver.location_updated',
        payload: {
          'ride_id': 'r1',
          'location': {'lat': 14.5, 'lng': 121.0},
          'heading': 270.0,
        },
      ));

      await Future<void>.delayed(Duration.zero);

      expect(received, isNotNull);
      expect(received!.rideId, 'r1');
      expect(received!.lat, 14.5);
      expect(received!.lng, 121.0);
      expect(received!.heading, 270.0);

      dispatcher.dispose();
      await client.close();
    });

    test('disposer removes handler', () async {
      final client = _StubClient();
      final dispatcher = WsDispatcher(client);

      var calls = 0;
      final remove = dispatcher.on<WsEventRideAccepted>(
        WsEventType.rideAccepted,
        (_) => calls++,
      );

      client.pump(WsEvent(
        type: 'ride.accepted',
        payload: {
          'ride_id': 'r1',
          'driver': {
            'id': 'd1',
            'name': 'Juan',
            'vehicle': {
              'make': 'Honda',
              'model': 'Click',
              'color': 'red',
              'plate': 'ABC123',
            },
          },
        },
      ));
      await Future<void>.delayed(Duration.zero);
      expect(calls, 1);

      remove();

      client.pump(WsEvent(
        type: 'ride.accepted',
        payload: {
          'ride_id': 'r1',
          'driver': {
            'id': 'd1',
            'name': 'Juan',
            'vehicle': {
              'make': 'Honda',
              'model': 'Click',
              'color': 'red',
              'plate': 'ABC123',
            },
          },
        },
      ));
      await Future<void>.delayed(Duration.zero);
      expect(calls, 1);

      dispatcher.dispose();
      await client.close();
    });

    test('unknown event names are swallowed silently', () async {
      final client = _StubClient();
      final dispatcher = WsDispatcher(client);

      var malformedCount = 0;
      dispatcher.malformed.listen((_) => malformedCount++);

      client.pump(WsEvent(
        type: 'ride.future_event',
        payload: {},
      ));
      await Future<void>.delayed(Duration.zero);

      expect(malformedCount, 0);

      dispatcher.dispose();
      await client.close();
    });

    test('malformed payload pushes to malformed stream', () async {
      final client = _StubClient();
      final dispatcher = WsDispatcher(client);

      WsMalformedEvent? caught;
      dispatcher.malformed.listen((m) => caught = m);

      dispatcher.on<WsEventRideAccepted>(WsEventType.rideAccepted, (_) {});

      // payload missing required 'driver' field
      client.pump(WsEvent(
        type: 'ride.accepted',
        payload: {'ride_id': 'r1'},
      ));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(caught, isNotNull);
      expect(caught!.reason, contains('deserialize'));

      dispatcher.dispose();
      await client.close();
    });
  });
}
