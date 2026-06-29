import 'dart:convert';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/ride_complete/repositories/ride_complete_repository_impl.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
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
  } else if (data is ReceiptResponse) {
    serialized = serializers.serialize(
      data,
      specifiedType: const FullType(ReceiptResponse),
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
  late RideCompleteRepositoryImpl repository;

  setUp(() {
    client = SakaiApiClient(basePathOverride: 'https://api.test');
    repository = RideCompleteRepositoryImpl(client);
  });

  group('RideCompleteRepositoryImpl.getRideDetails', () {
    test('successfully retrieves ride details', () async {
      final now = DateTime.now().toUtc();
      final mockResponse = $RideResponse(
        (b) => b
          ..id = 'ride-123'
          ..status = RideStatus.completed
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
        if (options.path.endsWith('/rides/ride-123') &&
            options.method == 'GET') {
          return _jsonResponse(mockResponse, 200);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final result = await repository.getRideDetails('ride-123');
      expect(result.id, 'ride-123');
      expect(result.status, RideStatus.completed);
    });
  });

  group('RideCompleteRepositoryImpl.submitRating', () {
    test('successfully submits rating', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/ride-123/rating') &&
            options.method == 'POST') {
          called = true;
          final dynamic data = options.data;
          final Map<String, dynamic> body = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;

          expect(body['stars'], 5);
          expect(body['feedback'], 'Great ride!');
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.submitRating('ride-123', 5, 'Great ride!');
      expect(called, isTrue);
    });
  });

  group('RideCompleteRepositoryImpl.addTip', () {
    test('successfully adds tip', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/ride-123/tip') &&
            options.method == 'POST') {
          called = true;
          final dynamic data = options.data;
          final Map<String, dynamic> body = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;

          // Note: AddRideTipRequest uses tipAmount in wireName
          expect(body['tipAmount'], 3.50);
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.addTip('ride-123', 3.50);
      expect(called, isTrue);
    });
  });

  group('RideCompleteRepositoryImpl.getReceipt', () {
    test('successfully retrieves receipt', () async {
      final now = DateTime.now().toUtc();
      final mockReceipt = ReceiptResponse(
        (b) => b
          ..rideId = 'ride-123'
          ..passengerName = 'Passenger'
          ..driverName = 'Driver'
          ..amount = 10.0
          ..currency = 'USD'
          ..paymentMethod = api.PaymentMethod.cash
          ..paymentStatus = api.PaymentStatus.completed
          ..completedAt = now,
      );

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/ride-123/receipt') &&
            options.method == 'GET') {
          return _jsonResponse(mockReceipt, 200);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final result = await repository.getReceipt('ride-123');
      expect(result?.rideId, 'ride-123');
      expect(result?.amount, 10.0);
    });

    test('returns null on 404', () async {
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        return ResponseBody.fromString('Not Found', 404);
      });

      final result = await repository.getReceipt('ride-123');
      expect(result, isNull);
    });
  });
}
