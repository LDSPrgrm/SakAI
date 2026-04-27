import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:sakai_shared/sakai_shared.dart';

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
  OnRideCompleted? onCompleted;
  OnRideCancelled? onCancelled;
  bool _loadingStarted = false;

  ActiveRideController({
    required this.rideId,
    required SakaiApiClient client,
    required WsClient wsClient,
  }) : _client = client,
       _wsClient = wsClient;

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

      if (rideStatus == RideState.completed) {
        onCompleted?.call(rideId);
      } else if (rideStatus == RideState.cancelled) {
        onCancelled?.call(rideId);
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
    if (current == null) return;

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
