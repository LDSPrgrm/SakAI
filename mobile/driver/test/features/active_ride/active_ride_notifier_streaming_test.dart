import 'package:driver/features/active_ride/repositories/active_ride_repository.dart';
import 'package:driver/features/active_ride/services/location_stream_service.dart';
import 'package:driver/features/active_ride/view_models/active_ride_notifier.dart';
import 'package:driver/features/home/repositories/driver_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

class _NoopActiveRideRepo implements ActiveRideRepository {
  @override
  Future<void> arriveAtPickup(String rideId, LatLng driverLocation) async {}
  @override
  Future<void> startRide(String rideId) async {}
  @override
  Future<void> completeRide(String rideId, LatLng driverLocation) async {}
  @override
  Future<void> cancelRide(String rideId) async {}
  @override
  Future<RideResponse?> getActiveRide() async => null;
}

class _NoopDriverRepo implements DriverRepository {
  @override
  Future<void> goOnline() async {}
  @override
  Future<void> goOffline() async {}
  @override
  Future<void> updateLocation(double lat, double lng, {double? heading}) async {}
  @override
  Future<RideResponse?> getIncomingRide() async => null;
}

class _RecordingLocationStream extends LocationStreamService {
  _RecordingLocationStream()
      : super(
          driverRepo: _NoopDriverRepo(),
          positionStreamFactory: (_) => const Stream.empty(),
        );

  final List<String> startCalls = [];
  int stopCalls = 0;

  @override
  Future<void> start(String rideId) async {
    startCalls.add(rideId);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}
}

$RideResponse _buildRide(RideStatus status) => $RideResponse(
      (b) => b
        ..id = 'ride-xyz'
        ..status = status
        ..passenger = $UserProfile(
          (b) => b
            ..id = 'u'
            ..name = 'P'
            ..email = 'p@x'
            ..role = UserProfileRoleEnum.passenger
            ..createdAt = DateTime.now(),
        )
        ..origin = LatLng((b) => b
          ..lat = 14.5
          ..lng = 121.0).toBuilder()
        ..destination = LatLng((b) => b
          ..lat = 14.6
          ..lng = 121.1).toBuilder()
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),
    );

void main() {
  group('ActiveRideManager streaming wiring', () {
    test('starts streaming when initial status is accepted', () async {
      final stream = _RecordingLocationStream();
      ActiveRideManager(
        repo: _NoopActiveRideRepo(),
        initialRide: _buildRide(RideStatus.accepted),
        locationStream: stream,
      );
      expect(stream.startCalls, ['ride-xyz']);
      expect(stream.stopCalls, 0);
    });

    test('does not start when initial status is requested', () async {
      final stream = _RecordingLocationStream();
      ActiveRideManager(
        repo: _NoopActiveRideRepo(),
        initialRide: _buildRide(RideStatus.requested),
        locationStream: stream,
      );
      expect(stream.startCalls, isEmpty);
    });

    test('stops streaming on handleStatusChanged(completed)', () async {
      final stream = _RecordingLocationStream();
      final manager = ActiveRideManager(
        repo: _NoopActiveRideRepo(),
        initialRide: _buildRide(RideStatus.inProgress),
        locationStream: stream,
      );
      manager.handleStatusChanged(RideStatus.completed);
      expect(stream.stopCalls, greaterThanOrEqualTo(1));
    });

    test('stops streaming on handleStatusChanged(cancelled)', () async {
      final stream = _RecordingLocationStream();
      final manager = ActiveRideManager(
        repo: _NoopActiveRideRepo(),
        initialRide: _buildRide(RideStatus.accepted),
        locationStream: stream,
      );
      manager.handleStatusChanged(RideStatus.cancelled);
      expect(stream.stopCalls, greaterThanOrEqualTo(1));
    });

    test('stops streaming on dispose', () async {
      final stream = _RecordingLocationStream();
      final manager = ActiveRideManager(
        repo: _NoopActiveRideRepo(),
        initialRide: _buildRide(RideStatus.accepted),
        locationStream: stream,
      );
      manager.dispose();
      expect(stream.stopCalls, greaterThanOrEqualTo(1));
    });

    test('restarts streaming when WS transitions back to live status', () async {
      final stream = _RecordingLocationStream();
      final manager = ActiveRideManager(
        repo: _NoopActiveRideRepo(),
        initialRide: _buildRide(RideStatus.requested),
        locationStream: stream,
      );
      expect(stream.startCalls, isEmpty);
      manager.handleStatusChanged(RideStatus.accepted);
      expect(stream.startCalls, contains('ride-xyz'));
    });
  });
}
