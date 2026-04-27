import 'dart:convert';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:driver/features/home/repositories/driver_repository_impl.dart';
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
  late DriverRepositoryImpl repository;

  setUp(() {
    client = SakaiApiClient(basePathOverride: 'https://api.test');
    repository = DriverRepositoryImpl(client);
  });

  group('DriverRepositoryImpl.goOnline', () {
    test('successfully sets status to online', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/driver/status') &&
            options.method == 'PUT') {
          called = true;
          final dynamic data = options.data;
          final Map<String, dynamic> body = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;

          expect(body['status'], 'online');
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.goOnline();
      expect(called, isTrue);
    });

    test('throws exception on error', () async {
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Server Error'}),
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      expect(() => repository.goOnline(), throwsException);
    });
  });

  group('DriverRepositoryImpl.goOffline', () {
    test('successfully sets status to offline', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/driver/status') &&
            options.method == 'PUT') {
          called = true;
          final dynamic data = options.data;
          final Map<String, dynamic> body = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;

          expect(body['status'], 'offline');
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.goOffline();
      expect(called, isTrue);
    });

    test('handles special error case for active ride', () async {
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({
            'code': 'DRIVER_HAS_ACTIVE_RIDE',
            'message': 'Cannot go offline',
          }),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      try {
        await repository.goOffline();
        fail('Should have thrown an exception');
      } catch (e) {
        expect(
          e.toString(),
          contains('Cannot go offline — you have an active ride'),
        );
      }
    });
  });

  group('DriverRepositoryImpl.updateLocation', () {
    test('successfully updates location', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/driver/location') &&
            options.method == 'PUT') {
          called = true;
          final dynamic data = options.data;
          final Map<String, dynamic> body = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;

          expect(body['location']['lat'], 40.7128);
          expect(body['heading'], 90.0);
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.updateLocation(40.7128, -74.0060, heading: 90.0);
      expect(called, isTrue);
    });
  });

  group('DriverRepositoryImpl.getIncomingRide', () {
    test('successfully retrieves incoming ride', () async {
      final now = DateTime.now().toUtc();
      final mockResponse = $RideResponse(
        (b) => b
          ..id = 'ride-789'
          ..status = RideStatus.requested
          ..originAddress = 'Start'
          ..destinationAddress = 'End'
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
              ..id = 'user-2'
              ..email = 'rider@test.com'
              ..name = 'Rider'
              ..role = UserProfileRoleEnum.passenger
              ..createdAt = now,
          ),
      );

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/driver/rides/incoming') &&
            options.method == 'GET') {
          return _jsonResponse(mockResponse, 200);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final result = await repository.getIncomingRide();
      expect(result?.id, 'ride-789');
    });

    test('returns null when no incoming ride (404)', () async {
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        return ResponseBody.fromString('Not Found', 404);
      });

      final result = await repository.getIncomingRide();
      expect(result, isNull);
    });
  });
}
