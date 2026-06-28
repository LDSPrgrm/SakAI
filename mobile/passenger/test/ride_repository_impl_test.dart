import 'dart:convert';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/ride/models/ride_exception.dart';
import 'package:passenger/features/ride/repositories/ride_repository_impl.dart';
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
  } else if (data is ErrorResponse) {
    serialized = serializers.serialize(
      data,
      specifiedType: const FullType(ErrorResponse),
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
  late RideRepositoryImpl repository;

  setUp(() {
    client = SakaiApiClient(basePathOverride: 'https://api.test');
    repository = RideRepositoryImpl(client);
  });

  group('RideRepositoryImpl.requestRide', () {
    test('successfully requests a ride', () async {
      final now = DateTime.now().toUtc();
      final mockRideResponse = $RideResponse(
        (b) => b
          ..id = 'ride-123'
          ..status = RideStatus.requested
          ..passenger = $UserProfile(
            (u) => u
              ..id = 'user-1'
              ..email = 'test@example.com'
              ..name = 'Test User'
              ..role = UserProfileRoleEnum.passenger
              ..createdAt = now,
          )
          ..origin.replace(
            LatLng(
              (l) => l
                ..lat = 1.0
                ..lng = 2.0,
            ),
          )
          ..destination.replace(
            LatLng(
              (l) => l
                ..lat = 3.0
                ..lng = 4.0,
            ),
          )
          ..createdAt = now
          ..updatedAt = now,
      );

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        final path = options.path;
        // RidesApi sets path to '/rides' for POST
        if (path.endsWith('/rides') && options.method == 'POST') {
          return _jsonResponse(mockRideResponse, 201);
        }
        return ResponseBody.fromString('Not Found: $path', 404);
      });

      final result = await repository.requestRide(
        origin: const RideLocation(lat: 1.0, lng: 2.0, address: 'Origin'),
        destination: const RideLocation(
          lat: 3.0,
          lng: 4.0,
          address: 'Destination',
        ),
        idempotencyKey: 'key-123',
      );

      expect(result.id, 'ride-123');
      expect(result.status, RideState.requested);
    });

    test('throws RideException on error response', () async {
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        final err = ErrorResponse(
          (b) => b
            ..code = ErrorCode.NO_DRIVERS_AVAILABLE
            ..message = 'No drivers found',
        );
        return _jsonResponse(err, 404);
      });

      expect(
        () => repository.requestRide(
          origin: const RideLocation(lat: 1.0, lng: 2.0, address: 'Origin'),
          destination: const RideLocation(
            lat: 3.0,
            lng: 4.0,
            address: 'Destination',
          ),
          idempotencyKey: 'key-123',
        ),
        throwsA(
          isA<RideException>().having(
            (e) => e.machineCode,
            'machineCode',
            ErrorCode.NO_DRIVERS_AVAILABLE.name,
          ),
        ),
      );
    });
  });

  group('RideRepositoryImpl.getActiveRide', () {
    test('returns ride when active ride exists', () async {
      final now = DateTime.now().toUtc();
      final mockRideResponse = $RideResponse(
        (b) => b
          ..id = 'ride-456'
          ..status = RideStatus.accepted
          ..passenger = $UserProfile(
            (u) => u
              ..id = 'user-1'
              ..email = 'test@example.com'
              ..name = 'Test User'
              ..role = UserProfileRoleEnum.passenger
              ..createdAt = now,
          )
          ..origin.replace(
            LatLng(
              (l) => l
                ..lat = 1.0
                ..lng = 2.0,
            ),
          )
          ..destination.replace(
            LatLng(
              (l) => l
                ..lat = 3.0
                ..lng = 4.0,
            ),
          )
          ..createdAt = now
          ..updatedAt = now,
      );

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/active') && options.method == 'GET') {
          return _jsonResponse(mockRideResponse, 200);
        }
        return ResponseBody.fromString('Not Found: ${options.path}', 404);
      });

      final result = await repository.getActiveRide();

      expect(result?.id, 'ride-456');
      expect(result?.status, RideState.accepted);
    });

    test('returns null when 404 is returned', () async {
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        return ResponseBody.fromString('', 404);
      });

      final result = await repository.getActiveRide();
      expect(result, isNull);
    });
  });

  group('RideRepositoryImpl.cancelRide', () {
    test('executes successfully', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/cancel') && options.method == 'POST') {
          called = true;
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found: ${options.path}', 404);
      });

      await repository.cancelRide(
        'ride-123',
        reasonCode: 'passenger_cancelled',
      );
      expect(called, isTrue);
    });
  });
}
