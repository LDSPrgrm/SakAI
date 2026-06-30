import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../home/repositories/driver_repository.dart';

/// Phase of the GPS push pipeline.
enum LocationPushStatus { idle, streaming, degraded, stopped }

@immutable
class LocationPushState {
  const LocationPushState({
    required this.status,
    this.lastSuccessAt,
    this.consecutiveFailures = 0,
    this.lastError,
    this.lastPosition,
  });

  final LocationPushStatus status;
  final DateTime? lastSuccessAt;
  final int consecutiveFailures;
  final String? lastError;
  final Position? lastPosition;

  bool get isDegraded => status == LocationPushStatus.degraded;

  LocationPushState copyWith({
    LocationPushStatus? status,
    DateTime? lastSuccessAt,
    int? consecutiveFailures,
    Object? lastError = _sentinel,
    Position? lastPosition,
  }) {
    return LocationPushState(
      status: status ?? this.status,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
      lastError: identical(lastError, _sentinel)
          ? this.lastError
          : lastError as String?,
      lastPosition: lastPosition ?? this.lastPosition,
    );
  }

  static const _sentinel = Object();
}

typedef PositionStreamFactory =
    Stream<Position> Function(LocationSettings settings);

Stream<Position> _defaultPositionStream(LocationSettings settings) =>
    Geolocator.getPositionStream(locationSettings: settings);

/// Streams the driver's GPS to `PUT /driver/location` while an active ride
/// is in `accepted | arrived | in_progress`.
///
/// Cadence: throttle to [normalCadence] (7s) per successful push.
/// Backoff: 3 consecutive failures switch to [degradedCadence] (30s) and emit
/// a degraded state; recover to normal on the first success.
///
/// Idempotent: repeat `start()` calls with the same rideId are no-ops.
class LocationStreamService {
  LocationStreamService({
    required DriverRepository driverRepo,
    PositionStreamFactory? positionStreamFactory,
    Duration normalCadence = const Duration(seconds: 7),
    Duration degradedCadence = const Duration(seconds: 30),
    int degradedAfterFailures = 3,
    DateTime Function() clock = DateTime.now,
  })  : _driverRepo = driverRepo,
        _positionStreamFactory =
            positionStreamFactory ?? _defaultPositionStream,
        _normalCadence = normalCadence,
        _degradedCadence = degradedCadence,
        _degradedAfterFailures = degradedAfterFailures,
        _clock = clock;

  final DriverRepository _driverRepo;
  final PositionStreamFactory _positionStreamFactory;
  final Duration _normalCadence;
  final Duration _degradedCadence;
  final int _degradedAfterFailures;
  final DateTime Function() _clock;

  final StreamController<LocationPushState> _controller =
      StreamController<LocationPushState>.broadcast();

  StreamSubscription<Position>? _positionSub;
  String? _activeRideId;
  bool _paused = false;
  bool _inFlight = false;
  DateTime _lastPushAt = DateTime.fromMillisecondsSinceEpoch(0);
  LocationPushState _state = const LocationPushState(
    status: LocationPushStatus.idle,
  );

  /// Broadcast stream of pipeline state transitions.
  Stream<LocationPushState> get stream => _controller.stream;

  LocationPushState get currentState => _state;

  bool get isStreaming => _positionSub != null;

  String? get activeRideId => _activeRideId;

  /// Starts streaming for [rideId]. Idempotent: a second call with the same
  /// rideId returns immediately; with a different rideId, switches targets.
  Future<void> start(String rideId) async {
    if (_activeRideId == rideId && _positionSub != null) return;
    if (_activeRideId != null && _activeRideId != rideId) {
      await _cancelSubscription();
    }
    _activeRideId = rideId;
    _paused = false;
    _subscribe();
    _emit(_state.copyWith(status: LocationPushStatus.streaming));
  }

  /// Stops streaming entirely. Safe to call multiple times.
  Future<void> stop() async {
    if (_activeRideId == null && _positionSub == null) return;
    await _cancelSubscription();
    _activeRideId = null;
    _lastPushAt = DateTime.fromMillisecondsSinceEpoch(0);
    _emit(_state.copyWith(
      status: LocationPushStatus.stopped,
      consecutiveFailures: 0,
      lastError: null,
    ));
  }

  /// Suspends the position subscription without forgetting the active ride.
  /// Use on `AppLifecycleState.paused` to conserve battery while the app is
  /// backgrounded. Re-engage with [resume].
  Future<void> pause() async {
    if (_paused) return;
    _paused = true;
    await _cancelSubscription();
  }

  Future<void> resume() async {
    if (!_paused) return;
    _paused = false;
    if (_activeRideId != null) {
      _subscribe();
    }
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  void _subscribe() {
    if (_positionSub != null) return;
    final settings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _positionSub = _positionStreamFactory(settings).listen(
      _onPosition,
      onError: _onStreamError,
      cancelOnError: false,
    );
  }

  Future<void> _cancelSubscription() async {
    final sub = _positionSub;
    _positionSub = null;
    await sub?.cancel();
  }

  Future<void> _onPosition(Position position) async {
    _emit(_state.copyWith(lastPosition: position));

    if (_inFlight || _paused || _activeRideId == null) return;
    final now = _clock();
    final cadence = _state.isDegraded ? _degradedCadence : _normalCadence;
    if (now.difference(_lastPushAt) < cadence) return;
    _inFlight = true;
    try {
      await _driverRepo.updateLocation(
        position.latitude,
        position.longitude,
        heading: position.heading,
      );
      _lastPushAt = now;
      _emit(_state.copyWith(
        status: LocationPushStatus.streaming,
        lastSuccessAt: now,
        consecutiveFailures: 0,
        lastError: null,
      ));
    } catch (e) {
      final failures = _state.consecutiveFailures + 1;
      final degraded = failures >= _degradedAfterFailures;
      _emit(_state.copyWith(
        status: degraded
            ? LocationPushStatus.degraded
            : LocationPushStatus.streaming,
        consecutiveFailures: failures,
        lastError: e.toString(),
      ));
    } finally {
      _inFlight = false;
    }
  }

  void _onStreamError(Object error, StackTrace stack) {
    debugPrint('[LocationStreamService] Position stream error: $error');
    _emit(_state.copyWith(lastError: error.toString()));
  }

  void _emit(LocationPushState next) {
    _state = next;
    if (!_controller.isClosed) _controller.add(next);
  }
}
