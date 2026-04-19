import 'dart:async';

import 'package:dio/dio.dart';
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
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          _setupWebSocketListener();
          _state = AsyncValue.data(_stateFromJson(data));
          _stateController.add(_state);
          return;
        }
      }
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
    final statusStr = payload['status'] as String?;
    if (statusStr == null) return;

    final rideStatus = RideState.fromString(statusStr);
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
  }

  void _handleDriverLocation(Map<String, dynamic> payload) {
    final lat = payload['lat'] as double?;
    final lng = payload['lng'] as double?;
    if (lat == null || lng == null) return;

    final current = _state.value;
    if (current == null) return;

    _state = AsyncValue.data(
      current.copyWith(driverLocation: gmaps.LatLng(lat, lng)),
    );
    _stateController.add(_state);
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

  // ── Fallback JSON parsing for when generated client fails on 2xx ───────

  ActiveRideState _stateFromJson(Map<String, dynamic> json) {
    final driverData = json['driver'] as Map<String, dynamic>?;
    String? driverName;
    String? driverVehicle;
    gmaps.LatLng? driverLocation;
    VehicleInfo? driverVehicleInfo;
    gmaps.LatLng? driverCurrentLocation;

    if (driverData != null) {
      driverName = driverData['name'] as String?;
      final v = driverData['vehicle'] as Map<String, dynamic>?;
      if (v != null) {
        driverVehicle =
            '${v['make']} ${v['model']} · ${v['plate']} · ${v['color']}';
        driverVehicleInfo = VehicleInfo(
          (vb) => vb
            ..make = v['make'] as String?
            ..model = v['model'] as String?
            ..color = v['color'] as String?
            ..plate = v['plate'] as String?,
        );
      }
      final loc = driverData['current_location'] as Map<String, dynamic>?;
      if (loc != null) {
        driverLocation = gmaps.LatLng(
          (loc['lat'] as num).toDouble(),
          (loc['lng'] as num).toDouble(),
        );
        driverCurrentLocation = gmaps.LatLng(
          (loc['lat'] as num).toDouble(),
          (loc['lng'] as num).toDouble(),
        );
      }
    }

    // Parse passenger from JSON for completeness.
    final passengerData = json['passenger'] as Map<String, dynamic>?;
    final passengerRoleStr = passengerData?['role'] as String?;
    final passengerRole = passengerRoleStr != null
        ? UserProfileRoleEnum.valueOf(passengerRoleStr)
        : UserProfileRoleEnum.passenger;

    // Build origin/destination LatLng.
    final originJson = json['origin'] as Map<String, dynamic>?;
    final destJson = json['destination'] as Map<String, dynamic>?;
    final originLat = (originJson?['lat'] as num?)?.toDouble() ?? 0.0;
    final originLng = (originJson?['lng'] as num?)?.toDouble() ?? 0.0;
    final destLat = (destJson?['lat'] as num?)?.toDouble() ?? 0.0;
    final destLng = (destJson?['lng'] as num?)?.toDouble() ?? 0.0;

    // Parse timestamps with safe fallbacks.
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'] as String);
    } catch (_) {
      createdAt = DateTime.now();
    }
    DateTime updatedAt;
    try {
      updatedAt = DateTime.parse(json['updated_at'] as String);
    } catch (_) {
      updatedAt = DateTime.now();
    }

    // Construct a RideResponse so the UI has data to render (not null → no loading loop).
    final rideResponse = $RideResponse((b) {
      b
        ..id = json['id'] as String? ?? ''
        ..status = RideStatus.valueOf(json['status'] as String)
        ..passenger = $UserProfile(
          (pb) => pb
            ..id = passengerData?['id'] as String? ?? ''
            ..name = passengerData?['name'] as String? ?? ''
            ..email = passengerData?['email'] as String? ?? ''
            ..role = passengerRole
            ..createdAt = _parseDateTime(passengerData?['created_at']),
        )
        ..origin.lat = originLat
        ..origin.lng = originLng
        ..destination.lat = destLat
        ..destination.lng = destLng
        ..originAddress = json['origin_address'] as String?
        ..destinationAddress = json['destination_address'] as String?
        ..createdAt = createdAt
        ..updatedAt = updatedAt;

      if (driverData != null) {
        b.driver.id = driverData['id'] as String? ?? '';
        b.driver.name = driverName ?? '';
        if (driverVehicleInfo != null) {
          b.driver.vehicle.replace(driverVehicleInfo);
        }
        if (driverCurrentLocation != null) {
          final currentLoc = driverCurrentLocation;
          b.driver.currentLocation.replace(
            LatLng(
              (lb) => lb
                ..lat = currentLoc.latitude
                ..lng = currentLoc.longitude,
            ),
          );
        }
      }
    });

    return ActiveRideState(
      ride: rideResponse,
      currentStep: ActiveRideStep.fromRideStatus(
        RideStatus.valueOf(json['status'] as String),
      ),
      driverName: driverName,
      driverVehicle: driverVehicle,
      driverLocation: driverLocation,
      isLoading: false,
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return DateTime.now();
    }
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
