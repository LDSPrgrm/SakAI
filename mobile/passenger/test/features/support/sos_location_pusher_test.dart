import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passenger/features/support/services/sos_location_pusher.dart';

/// Captures every POST so the test can assert push cadence + path
/// without standing up an HTTP server.
class _CapturingAdapter implements HttpClientAdapter {
  final List<RequestOptions> calls = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    calls.add(options);
    return ResponseBody.fromString('', 202);
  }

  @override
  void close({bool force = false}) {}
}

Position _fakePos() => Position(
      latitude: 14.5995,
      longitude: 120.9842,
      timestamp: DateTime.now(),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  group('SosLocationPusher', () {
    test('start fires an immediate push then ticks on interval', () async {
      final adapter = _CapturingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.httpClientAdapter = adapter;
      final pusher = SosLocationPusher(
        dio: dio,
        interval: const Duration(milliseconds: 60),
        positionProvider: () async => _fakePos(),
      );

      pusher.start(incidentId: 'incident-1', bearer: 'jwt-x');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      pusher.stop();

      expect(adapter.calls.length, greaterThanOrEqualTo(2),
          reason: 'immediate push + at least one tick within 200ms');
      final first = adapter.calls.first;
      expect(first.path, contains('/api/incidents/incident-1/location'));
      expect(first.headers['Authorization'], 'Bearer jwt-x');
      expect(first.data, containsPair('lat', 14.5995));
      expect(first.data, containsPair('lng', 120.9842));
    });

    test('stop halts ticks; subsequent start with same id is idempotent',
        () async {
      final adapter = _CapturingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.httpClientAdapter = adapter;
      final pusher = SosLocationPusher(
        dio: dio,
        interval: const Duration(milliseconds: 40),
        positionProvider: () async => _fakePos(),
      );

      pusher.start(incidentId: 'incident-x', bearer: 'jwt');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      pusher.stop();
      final after = adapter.calls.length;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(adapter.calls.length, after, reason: 'no ticks after stop');
      expect(pusher.isRunning, isFalse);

      pusher.start(incidentId: 'incident-x', bearer: 'jwt');
      expect(pusher.isRunning, isTrue);
      pusher.stop();
    });
  });
}
