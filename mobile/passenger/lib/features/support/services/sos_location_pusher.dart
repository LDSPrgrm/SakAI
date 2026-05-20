import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Background pusher for the participant-driven SOS location stream.
///
/// Lifecycle:
///   1. UI flips `sosUiState.active = true` AND user has opted in to
///      live-location streaming → call [start] with the active incident
///      id + the bearer token to use for the REST call.
///   2. Pusher reads the current GPS position every [interval] seconds
///      and POSTs to `/api/incidents/:incidentId/location`. Each push
///      also publishes `sos.location_stream` server-side via the
///      dispatcher, so admin dashboards see the trail in near-real-time.
///   3. Incident resolves / user opts out → call [stop]. Restart-safe.
///
/// Privacy invariant: the pusher MUST NOT be started unless the user
/// has explicitly opted in. The opt-in check lives in the call site
/// (see sos_safety_prefs.dart). Server-side enforcement is participant-
/// scoped (not opt-in-scoped), so a bug in the toggle gate would leak
/// coordinates.
class SosLocationPusher {
  SosLocationPusher({
    required Dio dio,
    Duration interval = const Duration(seconds: 5),
    Future<Position> Function()? positionProvider,
  })  : _dio = dio,
        _interval = interval,
        _positionProvider = positionProvider ??
            (() => Geolocator.getCurrentPosition(
                  locationSettings:
                      const LocationSettings(accuracy: LocationAccuracy.high),
                ));

  final Dio _dio;
  final Duration _interval;
  final Future<Position> Function() _positionProvider;

  Timer? _timer;
  String? _incidentId;
  String? _bearer;
  bool _busy = false;

  bool get isRunning => _timer != null;
  String? get incidentId => _incidentId;

  /// Start the push loop. Idempotent — calling start twice with the same
  /// incident id is a no-op so a stream subscription can re-fire without
  /// double-arming.
  void start({required String incidentId, required String bearer}) {
    if (_incidentId == incidentId && _timer != null) return;
    stop();
    _incidentId = incidentId;
    _bearer = bearer;
    // Fire immediately so the operator dashboard sees a coordinate within
    // the first second of the SOS — subsequent ticks fill in the trail.
    unawaited(_tick());
    _timer = Timer.periodic(_interval, (_) => unawaited(_tick()));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _incidentId = null;
    _bearer = null;
  }

  Future<void> _tick() async {
    if (_busy || _incidentId == null) return;
    _busy = true;
    try {
      final pos = await _positionProvider();
      await _dio.post<dynamic>(
        '/api/incidents/$_incidentId/location',
        data: {'lat': pos.latitude, 'lng': pos.longitude},
        options: Options(
          headers: _bearer == null ? null : {'Authorization': 'Bearer $_bearer'},
          // Short timeout so a stalled push doesn't starve the next tick.
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
    } catch (e, st) {
      // Non-fatal — log + skip. The SOS lifecycle is not paused on a push
      // failure; the next tick retries with a fresh GPS read.
      debugPrint('[SOS] location push failed: $e\n$st');
    } finally {
      _busy = false;
    }
  }
}
