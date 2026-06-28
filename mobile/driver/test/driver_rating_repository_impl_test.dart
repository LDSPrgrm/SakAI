import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:driver/features/ride_complete/models/driver_rating_exception.dart';
import 'package:driver/features/ride_complete/repositories/driver_rating_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
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
  late DriverRatingRepositoryImpl repository;

  setUp(() {
    client = SakaiApiClient(basePathOverride: 'https://api.test');
    repository = DriverRatingRepositoryImpl(client);
  });

  group('DriverRatingRepositoryImpl.submitRating', () {
    test('successfully submits rating', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.contains('/rides/ride-123/rating') &&
            options.method == 'POST') {
          called = true;
          final dynamic data = options.data;
          final Map<String, dynamic> body = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;

          expect(body['stars'], 4);
          expect(body['feedback'], 'Good passenger');
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.submitRating('ride-123', 4, 'Good passenger');
      expect(called, isTrue);
    });

    test('wraps DioException in DriverRatingException on failure', () async {
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        return ResponseBody.fromString('Error', 500);
      });

      await expectLater(
        repository.submitRating('ride-123', 4, null),
        throwsA(isA<DriverRatingException>()),
      );
    });
  });
}
