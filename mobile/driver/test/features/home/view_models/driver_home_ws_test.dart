import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'package:driver/features/home/view_models/driver_home_notifier.dart';
import 'package:driver/features/home/repositories/driver_repository.dart';
import 'package:driver/app/providers.dart';

/// Stub client that exposes a pump method so tests can inject events
/// without a socket.
class _StubWsClient implements WsClient {
  final _events = StreamController<WsEvent>.broadcast();
  final _malformed = StreamController<WsMalformedEvent>.broadcast();

  void pump(WsEvent event) => _events.add(event);

  @override
  Stream<WsEvent> get events => _events.stream;
  @override
  Stream<WsMalformedEvent> get malformed => _malformed.stream;
  @override
  Future<void> connect({String? baseUrl, String? accessToken}) async {}
  @override
  Future<void> disconnect() async {}
  @override
  bool get isConnected => true;
  @override
  set onResync(VoidCallback cb) {}

  Future<void> close() async {
    await _events.close();
    await _malformed.close();
  }
}

class _NoopDriverRepository implements DriverRepository {
  @override
  Future<void> goOnline() async {}
  @override
  Future<void> goOffline() async {}
  @override
  Future<void> updateLocation(double lat, double lng, {double? heading}) async {}
  @override
  Future<RideResponse?> getIncomingRide() async => null;
}

void main() {
  group('DriverHomeNotifier WS dispatcher wiring', () {
    test('ride.requested via dispatcher invokes onRideOffer', () async {
      final stub = _StubWsClient();
      final dispatcher = WsDispatcher(stub);
      addTearDown(() async {
        await dispatcher.dispose();
        await stub.close();
      });

      final container = ProviderContainer(
        overrides: [
          driverRepositoryProvider.overrideWithValue(_NoopDriverRepository()),
        ],
      );
      addTearDown(container.dispose);

      WsEventRideRequested? captured;
      final notifier = container.read(driverHomeNotifierProvider.notifier);
      notifier.onRideOffer = (offer) {
        captured = offer;
      };
      notifier.setupWsDispatcher(dispatcher);

      stub.pump(WsEvent(
        type: 'ride.requested',
        payload: {
          'ride_id': 'ride-1',
          'passenger': {
            'id': 'p1',
            'name': 'Maria',
            'email': 'maria@example.com',
            'role': 'passenger',
            'created_at': '2026-01-01T00:00:00Z',
          },
          'origin': {'lat': 14.5, 'lng': 121.0},
          'destination': {'lat': 14.6, 'lng': 121.1},
          'expires_at': '2026-05-20T12:34:56Z',
        },
      ));

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(captured, isNotNull);
      expect(captured!.rideId, 'ride-1');
      expect(captured!.passenger.name, 'Maria');
    });

    test('ride.status_changed via dispatcher invokes onStatusChanged', () async {
      final stub = _StubWsClient();
      final dispatcher = WsDispatcher(stub);
      addTearDown(() async {
        await dispatcher.dispose();
        await stub.close();
      });

      final container = ProviderContainer(
        overrides: [
          driverRepositoryProvider.overrideWithValue(_NoopDriverRepository()),
        ],
      );
      addTearDown(container.dispose);

      String? rideId;
      RideStatus? status;
      final notifier = container.read(driverHomeNotifierProvider.notifier);
      notifier.onStatusChanged = (id, s) {
        rideId = id;
        status = s;
      };
      notifier.setupWsDispatcher(dispatcher);

      stub.pump(WsEvent(
        type: 'ride.status_changed',
        payload: {
          'ride_id': 'ride-2',
          'status': 'in_progress',
          'updated_at': '2026-05-20T12:34:56Z',
        },
      ));

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(rideId, 'ride-2');
      expect(status, RideStatus.inProgress);
    });

    test('ride.cancelled via dispatcher invokes onRideCancelled', () async {
      final stub = _StubWsClient();
      final dispatcher = WsDispatcher(stub);
      addTearDown(() async {
        await dispatcher.dispose();
        await stub.close();
      });

      final container = ProviderContainer(
        overrides: [
          driverRepositoryProvider.overrideWithValue(_NoopDriverRepository()),
        ],
      );
      addTearDown(container.dispose);

      String? rideId;
      final notifier = container.read(driverHomeNotifierProvider.notifier);
      notifier.onRideCancelled = (id) {
        rideId = id;
      };
      notifier.setupWsDispatcher(dispatcher);

      stub.pump(WsEvent(
        type: 'ride.cancelled',
        payload: {'ride_id': 'ride-3', 'cancelled_by': 'passenger'},
      ));

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(rideId, 'ride-3');
    });
  });
}
