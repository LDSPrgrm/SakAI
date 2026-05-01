import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/e2e_mode_stub.dart'
    if (dart.library.js_interop) '../../../app/e2e_mode_web.dart';
import '../models/active_ride_state.dart';

/// Callback types for navigation actions from the notifier.
typedef OnRideCompleted = void Function(String rideId);
typedef OnRideCancelled = void Function(String rideId);

/// Manages active ride state with WebSocket support.
///
/// This class is NOT a Riverpod notifier itself — it's a plain ChangeNotifier-like
/// class that is wrapped by a [Provider.family].
class ActiveRideController {
  final String rideId;
  final SakaiApiClient _client;
  final WsClient _wsClient;
  final SOSRepository _sosRepository;

  late final StreamController<AsyncValue<ActiveRideState>> _stateController =
      StreamController<AsyncValue<ActiveRideState>>.broadcast(
        onListen: _startLoading,
      );
  Stream<AsyncValue<ActiveRideState>> get stateStream =>
      _stateController.stream;

  AsyncValue<ActiveRideState> _state =
      const AsyncValue<ActiveRideState>.loading();
  AsyncValue<ActiveRideState> get state => _state;

  StreamSubscription<WsEvent>? _wsSubscription;
  Timer? _e2ePollTimer;
  OnRideCompleted? onCompleted;
  OnRideCancelled? onCancelled;
  bool _loadingStarted = false;

  ActiveRideController({
    required this.rideId,
    required SakaiApiClient client,
    required WsClient wsClient,
    required SOSRepository sosRepository,
  }) : _client = client,
       _wsClient = wsClient,
       _sosRepository = sosRepository;

  Future<void> triggerSOS({String? reason}) async {
    try {
      await _sosRepository.triggerSOS(rideId, reason: reason);
    } catch (e, st) {
      debugPrint('[PASSENGER] SOS trigger failed: $e\n$st');
      final current = _state.value;
      if (current != null) {
        _state = AsyncValue.data(
          current.copyWith(errorMessage: 'Failed to trigger SOS alert'),
        );
        _stateController.add(_state);
      }
    }
  }

  void _startLoading() {
    if (_loadingStarted) return;
    _loadingStarted = true;
    _loadRide();
  }

  Future<void> _loadRide() async {
    try {
      final apiResponse = await _client.getRidesApi().rideGet(rideId: rideId);
      final response = apiResponse.data;
      if (response == null) {
        throw Exception('No ride data found');
      }

      _setupWebSocketListener();
      _setupE2EPolling();

      _state = AsyncValue.data(ActiveRideState.fromRideResponse(response));
      _stateController.add(_state);
    } on DioException catch (e) {
      _state = AsyncValue.error(
        Exception('Failed to load ride: $e'),
        StackTrace.current,
      );
      _stateController.add(_state);
    } catch (e, st) {
      _state = AsyncValue.error(Exception('Failed to load ride: $e'), st);
      _stateController.add(_state);
    }
  }

  void _setupE2EPolling() {
    if (!kIsWeb || !isE2EMode() || _e2ePollTimer != null) return;
    _e2ePollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_terminated) return;
      try {
        final apiResponse = await _client.getRidesApi().rideGet(
          rideId: rideId,
        );
        final response = apiResponse.data;
        if (response == null) return;
        final rideStatus = RideState.fromString(response.status.name);
        final nextState = ActiveRideState.fromRideResponse(response);
        _state = AsyncValue.data(nextState);
        _stateController.add(_state);
        if (rideStatus == RideState.completed ||
            rideStatus == RideState.cancelled) {
          _terminated = true;
          _e2ePollTimer?.cancel();
          if (rideStatus == RideState.completed) {
            onCompleted?.call(rideId);
          } else {
            onCancelled?.call(rideId);
          }
        }
      } catch (_) {
        // E2E fallback only; normal WebSocket flow remains authoritative.
      }
    });
  }

  void _setupWebSocketListener() {
    _wsSubscription = _wsClient.events.listen((event) {
      final current = _state.value;
      if (current == null) return;

      switch (event.type) {
        case WsEventNames.rideStatusChanged:
          _handleStatusChanged(event.payload);
          break;
        case WsEventNames.driverLocationUpdated:
          _handleDriverLocation(event.payload);
          break;
        case WsEventNames.rideCancelled:
          _handleRideCancelled();
          break;
      }
    });
  }

  bool _terminated = false;

  void _handleStatusChanged(Map<String, dynamic> payload) {
    try {
      final event = standardSerializers.deserializeWith(
        WsEventRideStatusChanged.serializer,
        payload,
      );
      if (event == null) return;

      final rideStatus = RideState.fromString(event.status.name);
      final current = _state.value;
      if (current == null) return;

      final newStep = _stepFromRideState(rideStatus);
      _state = AsyncValue.data(
        current.copyWith(currentStep: newStep, errorMessage: null),
      );
      _stateController.add(_state);

      if (!_terminated &&
          (rideStatus == RideState.completed ||
              rideStatus == RideState.cancelled)) {
        _terminated = true;
        if (rideStatus == RideState.completed) {
          onCompleted?.call(rideId);
        } else {
          onCancelled?.call(rideId);
        }
      }
    } catch (e, st) {
      debugPrint(
        '[PASSENGER] Failed to deserialize WsEventRideStatusChanged: $e\n$st',
      );
    }
  }

  void _handleDriverLocation(Map<String, dynamic> payload) {
    try {
      final event = standardSerializers.deserializeWith(
        WsEventDriverLocationUpdated.serializer,
        payload,
      );
      if (event == null) return;

      final current = _state.value;
      if (current == null) return;

      _state = AsyncValue.data(
        current.copyWith(
          driverLocation: gmaps.LatLng(
            event.location.lat.toDouble(),
            event.location.lng.toDouble(),
          ),
        ),
      );
      _stateController.add(_state);
    } catch (e, st) {
      debugPrint(
        '[PASSENGER] Failed to deserialize WsEventDriverLocationUpdated: $e\n$st',
      );
    }
  }

  void _handleRideCancelled() {
    final current = _state.value;
    if (current == null || _terminated) return;

    _terminated = true;
    _state = AsyncValue.data(current);
    _stateController.add(_state);
    onCancelled?.call(rideId);
  }

  void enrichDriverInfo({String? name, String? vehicle}) {
    final current = _state.value;
    if (current == null) return;

    _state = AsyncValue.data(
      current.copyWith(
        driverName: name ?? current.driverName,
        driverVehicle: vehicle ?? current.driverVehicle,
      ),
    );
    _stateController.add(_state);
  }

  ActiveRideStep _stepFromRideState(RideState status) {
    switch (status) {
      case RideState.accepted:
        return ActiveRideStep.enRoute;
      case RideState.arrived:
        return ActiveRideStep.arrived;
      case RideState.inProgress:
        return ActiveRideStep.inProgress;
      default:
        return ActiveRideStep.enRoute;
    }
  }

  void dispose() {
    _wsSubscription?.cancel();
    _e2ePollTimer?.cancel();
    _stateController.close();
  }
}

ActiveRideStep activeRideStepFromRideStatus(RideState status) {
  switch (status) {
    case RideState.accepted:
      return ActiveRideStep.enRoute;
    case RideState.arrived:
      return ActiveRideStep.arrived;
    case RideState.inProgress:
      return ActiveRideStep.inProgress;
    default:
      return ActiveRideStep.enRoute;
  }
}
