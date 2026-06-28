import 'dart:convert';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver/features/active_ride/repositories/active_ride_repository_impl.dart';
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
  late ActiveRideRepositoryImpl repository;

  setUp(() {
    client = SakaiApiClient(basePathOverride: 'https://api.test');
    repository = ActiveRideRepositoryImpl(client);
  });

  group('ActiveRideRepositoryImpl.getActiveRide', () {
    test('successfully retrieves active ride', () async {
      final now = DateTime.now().toUtc();
      final mockResponse = $RideResponse(
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
          ..passenger = $UserProfile(
            (u) => u
              ..id = 'user-1'
              ..email = 'test@example.com'
              ..name = 'Test User'
              ..role = UserProfileRoleEnum.passenger
              ..createdAt = now,
          ),
      );

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/active') && options.method == 'GET') {
          return _jsonResponse(mockResponse, 200);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final result = await repository.getActiveRide();
      expect(result?.id, 'ride-123');
      expect(result?.status, RideStatus.accepted);
    });

    test('returns null when no active ride (404)', () async {
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        return ResponseBody.fromString('Not Found', 404);
      });

      final result = await repository.getActiveRide();
      expect(result, isNull);
    });
  });

  group('ActiveRideRepositoryImpl.arriveAtPickup', () {
    test('successfully marks arrival', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/ride-123/arrive') &&
            options.method == 'POST') {
          called = true;
          final dynamic data = options.data;
          final Map<String, dynamic> body = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;

          expect(body['driver_location']['lat'], 40.7128);
          expect(body['driver_location']['lng'], -74.0060);
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.arriveAtPickup(
        'ride-123',
        LatLng(
          (l) => l
            ..lat = 40.7128
            ..lng = -74.0060,
        ),
      );
      expect(called, isTrue);
    });
  });

  group('ActiveRideRepositoryImpl.startRide', () {
    test('successfully starts ride', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/ride-123/start') &&
            options.method == 'POST') {
          called = true;
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.startRide('ride-123');
      expect(called, isTrue);
    });
  });

  group('ActiveRideRepositoryImpl.completeRide', () {
    test('successfully completes ride', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/ride-123/complete') &&
            options.method == 'POST') {
          called = true;
          final dynamic data = options.data;
          final Map<String, dynamic> body = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;

          expect(body['driver_location']['lat'], 40.7128);
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.completeRide(
        'ride-123',
        LatLng(
          (l) => l
            ..lat = 40.7128
            ..lng = -74.0060,
        ),
      );
      expect(called, isTrue);
    });
  });

  group('ActiveRideRepositoryImpl.cancelRide', () {
    test('successfully cancels ride', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/ride-123/cancel') &&
            options.method == 'POST') {
          called = true;
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.cancelRide('ride-123');
      expect(called, isTrue);
    });
  });
}
