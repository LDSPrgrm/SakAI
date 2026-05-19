import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/active_ride/models/active_ride_state.dart';
import 'package:passenger/features/active_ride/view_models/active_ride_notifier.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'sos_repository_impl_test.mocks.dart';

class MockWsClient implements WsClient {
  final _controller = StreamController<WsEvent>.broadcast();
  @override
  Stream<WsEvent> get events => _controller.stream;

  void addEvent(WsEvent event) => _controller.add(event);

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> connect({String? baseUrl, String? accessToken}) async {}

  @override
  bool get isConnected => true;

  @override
  set onResync(VoidCallback cb) {}
}

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

ResponseBody _jsonResponse(Object data, int statusCode) {
  final serializers = standardSerializers;
  Object? serialized;

  if (data is RideResponse) {
    serialized = serializers.serialize(
      data,
      specifiedType: const FullType(RideResponse),
    );
  } else {
    serialized = serializers.serialize(data);
  }

  return ResponseBody.fromString(
    jsonEncode(serialized),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  late SakaiApiClient client;
  late MockWsClient wsClient;
  late MockSOSRepository sosRepository;
  late ActiveRideController controller;

  setUp(() {
    client = SakaiApiClient(basePathOverride: 'https://api.test');
    wsClient = MockWsClient();
    sosRepository = MockSOSRepository();
    controller = ActiveRideController(
      rideId: 'ride-123',
      client: client,
      wsClient: wsClient,
      sosRepository: sosRepository,
    );
  });

  UserProfile mockPassenger(DateTime now) => $UserProfile(
    (u) => u
      ..id = 'user-1'
      ..email = 'test@example.com'
      ..name = 'Test User'
      ..role = UserProfileRoleEnum.passenger
      ..createdAt = now,
  );

  group('ActiveRideController', () {
    test('initial state and successful load', () async {
      final now = DateTime.now().toUtc();
      final mockRide = $RideResponse(
        (b) => b
          ..id = 'ride-123'
          ..status = RideStatus.accepted
          ..originAddress = 'Origin'
          ..destinationAddress = 'Destination'
          ..origin.replace(
            LatLng(
              (l) => l
                ..lat = 0.0
                ..lng = 0.0,
            ),
          )
          ..destination.replace(
            LatLng(
              (l) => l
                ..lat = 1.0
                ..lng = 1.0,
            ),
          )
          ..createdAt = now
          ..updatedAt = now
          ..passenger = mockPassenger(now)
          ..driver.replace(
            DriverSummary(
              (d) => d
                ..id = 'driver-1'
                ..name = 'Mock Driver'
                ..vehicle.replace(
                  VehicleInfo(
                    (v) => v
                      ..make = 'Toyota'
                      ..model = 'Corolla'
                      ..plate = 'ABC-123'
                      ..color = 'White',
                  ),
                ),
            ),
          ),
      );

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/ride-123') &&
            options.method == 'GET') {
          return _jsonResponse(mockRide, 200);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      // Listening starts loading
      final states = <ActiveRideState>[];
      final completer = Completer<void>();
      final sub = controller.stateStream.listen((asyncValue) {
        if (asyncValue is AsyncData<ActiveRideState>) {
          states.add(asyncValue.value);
          if (!completer.isCompleted) completer.complete();
        }
      });

      await completer.future.timeout(const Duration(seconds: 1));
      expect(states.length, 1);
      final state = states.first;
      expect(state.ride?.id, 'ride-123');
      expect(state.driverName, 'Mock Driver');
      expect(state.currentStep, ActiveRideStep.enRoute);

      await sub.cancel();
    });

    test('handles status changed event', () async {
      // Mock initial load
      final now = DateTime.now().toUtc();
      final mockRide = $RideResponse(
        (b) => b
          ..id = 'ride-123'
          ..status = RideStatus.accepted
          ..originAddress = 'A'
          ..destinationAddress = 'B'
          ..origin.replace(
            LatLng(
              (l) => l
                ..lat = 0.0
                ..lng = 0.0,
            ),
          )
          ..destination.replace(
            LatLng(
              (l) => l
                ..lat = 1.0
                ..lng = 1.0,
            ),
          )
          ..createdAt = now
          ..updatedAt = now
          ..passenger = mockPassenger(now),
      );

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        return _jsonResponse(mockRide, 200);
      });

      final states = <ActiveRideState>[];
      final sub = controller.stateStream.listen((asyncValue) {
        if (asyncValue is AsyncData<ActiveRideState>) {
          states.add(asyncValue.value);
        }
      });

      await _waitFor(() => states.isNotEmpty);
      expect(states.last.currentStep, ActiveRideStep.enRoute);

      // Push WS event
      wsClient.addEvent(
        WsEvent(
          type: WsEventNames.rideStatusChanged,
          payload: {
            'ride_id': 'ride-123',
            'status': 'ARRIVED',
            'updated_at': now.toIso8601String(),
          },
        ),
      );

      await _waitFor(() => states.length >= 2 && states.last.currentStep == ActiveRideStep.arrived);
      expect(states.last.currentStep, ActiveRideStep.arrived);

      await sub.cancel();
    });

    test('handles driver location updated event', () async {
      // Mock initial load
      final now = DateTime.now().toUtc();
      final mockRide = $RideResponse(
        (b) => b
          ..id = 'ride-123'
          ..status = RideStatus.accepted
          ..originAddress = 'A'
          ..destinationAddress = 'B'
          ..origin.replace(
            LatLng(
              (l) => l
                ..lat = 0.0
                ..lng = 0.0,
            ),
          )
          ..destination.replace(
            LatLng(
              (l) => l
                ..lat = 1.0
                ..lng = 1.0,
            ),
          )
          ..createdAt = now
          ..updatedAt = now
          ..passenger = mockPassenger(now),
      );

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        return _jsonResponse(mockRide, 200);
      });

      final states = <ActiveRideState>[];
      final sub = controller.stateStream.listen((asyncValue) {
        if (asyncValue is AsyncData<ActiveRideState>) {
          states.add(asyncValue.value);
        }
      });

      await _waitFor(() => states.isNotEmpty);

      // Push WS event
      wsClient.addEvent(
        WsEvent(
          type: WsEventNames.driverLocationUpdated,
          payload: {
            'ride_id': 'ride-123',
            'location': {'lat': 40.7128, 'lng': -74.0060},
          },
        ),
      );

      await _waitFor(() => states.last.driverLocation != null);
      expect(states.last.driverLocation?.latitude, 40.7128);
      expect(states.last.driverLocation?.longitude, -74.0060);

      await sub.cancel();
    });

    test('handles ride cancelled event and invokes callback', () async {
      String? cancelledRideId;
      controller.onCancelled = (id) => cancelledRideId = id;

      // Mock initial load
      final now = DateTime.now().toUtc();
      final mockRide = $RideResponse(
        (b) => b
          ..id = 'ride-123'
          ..status = RideStatus.accepted
          ..originAddress = 'A'
          ..destinationAddress = 'B'
          ..origin.replace(
            LatLng(
              (l) => l
                ..lat = 0.0
                ..lng = 0.0,
            ),
          )
          ..destination.replace(
            LatLng(
              (l) => l
                ..lat = 1.0
                ..lng = 1.0,
            ),
          )
          ..createdAt = now
          ..updatedAt = now
          ..passenger = mockPassenger(now),
      );

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        return _jsonResponse(mockRide, 200);
      });

      final sub = controller.stateStream.listen((_) {});
      await _waitFor(() => controller.state.hasValue);

      // Push WS event
      wsClient.addEvent(
        WsEvent(
          type: WsEventNames.rideCancelled,
          payload: {'ride_id': 'ride-123', 'reason': 'CANCELLED_BY_DRIVER'},
        ),
      );

      await _waitFor(() => cancelledRideId != null);
      expect(cancelledRideId, 'ride-123');

      await sub.cancel();
    });
  });
}

Future<void> _waitFor(bool Function() condition) async {
  final start = DateTime.now();
  while (!condition()) {
    if (DateTime.now().difference(start) > const Duration(seconds: 2)) {
      throw Exception('Timed out waiting for condition');
    }
    await Future.delayed(const Duration(milliseconds: 10));
  }
}
