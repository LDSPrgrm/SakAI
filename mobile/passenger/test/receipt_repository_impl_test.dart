import 'dart:convert';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/receipt/repositories/receipt_repository_impl.dart';
// Import api client directly to access its models without hiding
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

  if (data is ReceiptResponse) {
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
  late ReceiptRepositoryImpl repository;

  setUp(() {
    client = SakaiApiClient(basePathOverride: 'https://api.test');
    repository = ReceiptRepositoryImpl(client);
  });

  group('ReceiptRepositoryImpl.getReceipt', () {
    test('successfully retrieves a receipt', () async {
      final now = DateTime.now().toUtc();
      final mockReceiptResponse = ReceiptResponse(
        (b) => b
          ..rideId = 'ride-123'
          ..passengerName = 'Test Passenger'
          ..driverName = 'Test Driver'
          ..pickupAddress = 'Origin'
          ..destinationAddress = 'Destination'
          ..amount = 15.50
          ..currency = 'USD'
          ..paymentMethod = api.PaymentMethod.card
          ..paymentStatus = api.PaymentStatus.completed
          ..completedAt = now,
      );

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/rides/ride-123/receipt') &&
            options.method == 'GET') {
          return _jsonResponse(mockReceiptResponse, 200);
        }
        return ResponseBody.fromString('Not Found: ${options.path}', 404);
      });

      final result = await repository.getReceipt('ride-123');

      expect(result.rideId, 'ride-123');
      expect(result.amount, 15.50);
      expect(result.passengerName, 'Test Passenger');
    });

    test('throws ReceiptException on error response', () async {
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        final err = ErrorResponse(
          (b) => b
            ..code = ErrorCode.RIDE_NOT_FOUND
            ..message = 'Ride not found',
        );
        return _jsonResponse(err, 404);
      });

      expect(
        () => repository.getReceipt('ride-invalid'),
        throwsA(
          isA<ReceiptException>().having(
            (e) => e.machineCode,
            'machineCode',
            ErrorCode.RIDE_NOT_FOUND.name,
          ),
        ),
      );
    });

    test('throws ReceiptException on network error', () async {
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });

      expect(
        () => repository.getReceipt('any'),
        throwsA(
          isA<ReceiptException>().having(
            (e) => e.userMessage,
            'userMessage',
            contains('No connection'),
          ),
        ),
      );
    });
  });
}
