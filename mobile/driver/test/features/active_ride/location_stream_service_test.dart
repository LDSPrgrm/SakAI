import 'dart:async';

import 'package:driver/features/active_ride/services/location_stream_service.dart';
import 'package:driver/features/home/repositories/driver_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

Position _pos(double lat, double lng, {DateTime? t}) => Position(
      longitude: lng,
      latitude: lat,
      timestamp: t ?? DateTime.now(),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

class _RecordingDriverRepo implements DriverRepository {
  final List<List<double>> calls = [];
  Exception? failWith;
  int failTimes = 0;

  @override
  Future<void> goOnline() async {}

  @override
  Future<void> goOffline() async {}

  @override
  Future<void> updateLocation(double lat, double lng, {double? heading}) async {
    if (failTimes > 0) {
      failTimes--;
      throw failWith ?? Exception('forced');
    }
    calls.add([lat, lng]);
  }

  @override
  Future<RideResponse?> getIncomingRide() async => null;
}

void main() {
  group('LocationStreamService', () {
    test('throttles pushes to normal cadence', () async {
      final repo = _RecordingDriverRepo();
      final controller = StreamController<Position>.broadcast();
      var now = DateTime(2026, 5, 18, 9, 0, 0);
      final service = LocationStreamService(
        driverRepo: repo,
        positionStreamFactory: (_) => controller.stream,
        normalCadence: const Duration(seconds: 7),
        clock: () => now,
      );

      await service.start('ride-1');
      // First fix → pushed (lastPushAt = epoch, diff > 7s).
      controller.add(_pos(14.55, 121.00));
      await Future.microtask(() {});
      await Future.microtask(() {});
      // 2s later → throttled.
      now = now.add(const Duration(seconds: 2));
      controller.add(_pos(14.5501, 121.0001));
      await Future.microtask(() {});
      // 8s later → pushed again.
      now = now.add(const Duration(seconds: 6));
      controller.add(_pos(14.5502, 121.0002));
      await Future.microtask(() {});
      await Future.microtask(() {});

      expect(repo.calls.length, 2);
      await service.dispose();
      await controller.close();
    });

    test('enters degraded after 3 consecutive failures', () async {
      final repo = _RecordingDriverRepo()
        ..failWith = Exception('500')
        ..failTimes = 3;
      final controller = StreamController<Position>.broadcast();
      var now = DateTime(2026, 5, 18);
      final service = LocationStreamService(
        driverRepo: repo,
        positionStreamFactory: (_) => controller.stream,
        normalCadence: Duration.zero,
        clock: () => now,
      );
      final states = <LocationPushState>[];
      service.stream.listen(states.add);

      await service.start('ride-1');
      for (var i = 0; i < 3; i++) {
        controller.add(_pos(14.55, 121.0));
        await Future.microtask(() {});
        await Future.microtask(() {});
        now = now.add(const Duration(seconds: 1));
      }

      expect(service.currentState.status, LocationPushStatus.degraded);
      expect(service.currentState.consecutiveFailures, 3);
      // Drain microtasks so broadcast delivery completes, then assert emitted.
      await Future<void>.delayed(Duration.zero);
      expect(states.any((s) => s.status == LocationPushStatus.degraded), isTrue);
      await service.dispose();
      await controller.close();
    });

    test('recovers from degraded on first success', () async {
      final repo = _RecordingDriverRepo()
        ..failWith = Exception('500')
        ..failTimes = 3;
      final controller = StreamController<Position>.broadcast();
      var now = DateTime(2026, 5, 18);
      final service = LocationStreamService(
        driverRepo: repo,
        positionStreamFactory: (_) => controller.stream,
        normalCadence: Duration.zero,
        clock: () => now,
      );
      await service.start('ride-1');
      for (var i = 0; i < 3; i++) {
        controller.add(_pos(14.55, 121.0));
        await Future.microtask(() {});
        await Future.microtask(() {});
        now = now.add(const Duration(seconds: 1));
      }
      expect(service.currentState.status, LocationPushStatus.degraded);

      // Next push succeeds.
      controller.add(_pos(14.56, 121.01));
      await Future.microtask(() {});
      await Future.microtask(() {});

      expect(service.currentState.status, LocationPushStatus.streaming);
      expect(service.currentState.consecutiveFailures, 0);
      await service.dispose();
      await controller.close();
    });

    test('start is idempotent for same rideId', () async {
      final repo = _RecordingDriverRepo();
      var subscribed = 0;
      final controller = StreamController<Position>.broadcast(
        onListen: () => subscribed++,
      );
      final service = LocationStreamService(
        driverRepo: repo,
        positionStreamFactory: (_) => controller.stream,
      );
      await service.start('ride-1');
      await service.start('ride-1');
      await service.start('ride-1');
      expect(subscribed, 1);
      await service.dispose();
      await controller.close();
    });

    test('stop cancels subscription and emits stopped', () async {
      final repo = _RecordingDriverRepo();
      final controller = StreamController<Position>.broadcast();
      final service = LocationStreamService(
        driverRepo: repo,
        positionStreamFactory: (_) => controller.stream,
      );
      await service.start('ride-1');
      expect(service.isStreaming, isTrue);
      await service.stop();
      expect(service.isStreaming, isFalse);
      expect(service.currentState.status, LocationPushStatus.stopped);
      await service.dispose();
      await controller.close();
    });

    test('pause/resume re-subscribes without losing rideId', () async {
      final repo = _RecordingDriverRepo();
      var listens = 0;
      final controller = StreamController<Position>.broadcast(
        onListen: () => listens++,
      );
      final service = LocationStreamService(
        driverRepo: repo,
        positionStreamFactory: (_) => controller.stream,
      );
      await service.start('ride-7');
      await service.pause();
      expect(service.isStreaming, isFalse);
      expect(service.activeRideId, 'ride-7');
      await service.resume();
      expect(service.isStreaming, isTrue);
      expect(listens, 2);
      await service.dispose();
      await controller.close();
    });
  });
}
