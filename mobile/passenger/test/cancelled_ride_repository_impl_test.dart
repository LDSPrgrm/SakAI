import 'dart:convert';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/cancelled_ride/repositories/cancelled_ride_repository_impl.dart';
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
  late CancelledRideRepositoryImpl repository;

  setUp(() {
    client = SakaiApiClient(basePathOverride: 'https://api.test');
    repository = CancelledRideRepositoryImpl(client);
  });

  group('CancelledRideRepositoryImpl.getCancellationDetails', () {
    test('successfully retrieves cancellation details', () async {
      final now = DateTime.now().toUtc();
      final mockResponse = $RideResponse(
        (b) => b
          ..id = 'ride-123'
          ..status = RideStatus.cancelled
          ..cancelledBy = RideResponseCancelledByEnum.passenger
          ..cancellationReason = 'driver_too_far'
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
          )
          ..fare = 5.0
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
        if (options.path.endsWith('/rides/ride-123') &&
            options.method == 'GET') {
          return _jsonResponse(mockResponse, 200);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final result = await repository.getCancellationDetails('ride-123');
      expect(result.rideId, 'ride-123');
      expect(result.driverName, 'Mock Driver');
      expect(result.cancellationFee, 5.0);
    });
  });

  group('CancelledRideRepositoryImpl.cancelRide', () {
    test('successfully cancels ride', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/ride-123/cancel') &&
            options.method == 'POST') {
          called = true;
          final dynamic data = options.data;
          final Map<String, dynamic> body = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;

          expect(body['reason_code'], 'changed_plans');
          expect(body['reason_text'], 'Changed my mind');
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.cancelRide(
        'ride-123',
        reasonCode: 'changedPlans',
        reasonText: 'Changed my mind',
      );
      expect(called, isTrue);
    });
  });
}
