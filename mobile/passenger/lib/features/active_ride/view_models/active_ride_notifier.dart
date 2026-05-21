import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/e2e_mode_stub.dart'
    if (dart.library.js_interop) '../../../app/e2e_mode_web.dart';
import 'package:passenger/features/active_ride/models/active_ride_state.dart';

/// Callback types for navigation actions from the notifier.
typedef OnRideCompleted = void Function(String rideId);
typedef OnRideCancelled = void Function(String rideId);

/// When true, WS events flow through the shared [WsDispatcher] using
/// generated `built_value` serializers. When false, falls back to the
/// hand-rolled payload-extraction path that shipped pre-v1.3.0 spec.
/// Keep on for one release; remove the legacy path once parity is
/// confirmed in staging.
const bool kUseGeneratedSerializers = true;

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
        onListen: () {
          // Replay current state to new listener
          scheduleMicrotask(() {
            if (!_stateController.isClosed) {
              _stateController.add(_state);
            }
          });
          _startLoading();
        },
      );
  Stream<AsyncValue<ActiveRideState>> get stateStream =>
      _stateController.stream;

  AsyncValue<ActiveRideState> _state =
      const AsyncValue<ActiveRideState>.loading();
  AsyncValue<ActiveRideState> get state => _state;

  StreamSubscription<WsEvent>? _wsSubscription;
  WsDispatcher? _dispatcher;
  final List<void Function()> _wsDisposers = [];
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
    debugPrint('[P-ActiveRide] triggerSOS: rideId=$rideId, reason=$reason');
    try {
      await _sosRepository.triggerSOS(rideId, reason: reason);
      debugPrint('[P-ActiveRide] triggerSOS succeeded');
    } catch (e, st) {
      debugPrint('[P-ActiveRide] SOS trigger failed: $e\n$st');
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
    debugPrint('[P-ActiveRide] _loadRide: rideId=$rideId');
    try {
      final apiResponse = await _client.getRidesApi().rideGet(rideId: rideId);
      final response = apiResponse.data;
      if (response == null) {
        throw Exception('No ride data found');
      }
      debugPrint('[P-ActiveRide] _loadRide succeeded, status=${response.status}');

      _setupWebSocketListener();
      _setupE2EPolling();
      _wsClient.onResync = _onWsResync;

      _state = AsyncValue.data(ActiveRideState.fromRideResponse(response));
      _stateController.add(_state);
    } on DioException catch (e) {
      debugPrint('[P-ActiveRide] _loadRide DioException: $e');
      _state = AsyncValue.error(
        Exception('Failed to load ride: $e'),
        StackTrace.current,
      );
      _stateController.add(_state);
    } catch (e, st) {
      debugPrint('[P-ActiveRide] _loadRide unexpected error: $e');
      _state = AsyncValue.error(Exception('Failed to load ride: $e'), st);
      _stateController.add(_state);
    }
  }

  /// Fires before each WS reconnect attempt. Refetches the ride so any state
  /// transitions that happened during the disconnect window are reconciled.
  void _onWsResync() {
    debugPrint('[P-ActiveRide] _onWsResync: rideId=$rideId');
    if (_terminated) return;
    unawaited(_refetchRide());
  }

  Future<void> _refetchRide() async {
    debugPrint('[P-ActiveRide] _refetchRide: rideId=$rideId');
    try {
      final apiResponse = await _client.getRidesApi().rideGet(rideId: rideId);
      final response = apiResponse.data;
      if (response == null) return;
      final rideStatus = RideState.fromString(response.status.name);
      debugPrint('[P-ActiveRide] _refetchRide: status=$rideStatus');
      final next = ActiveRideState.fromRideResponse(response);
      _state = AsyncValue.data(next);
      _stateController.add(_state);
      if (!_terminated &&
          (rideStatus == RideState.completed ||
              rideStatus == RideState.cancelled)) {
        _terminated = true;
        debugPrint('[P-ActiveRide] _refetchRide: terminal=$rideStatus, firing callback');
        if (rideStatus == RideState.completed) {
          onCompleted?.call(rideId);
        } else {
          onCancelled?.call(rideId);
        }
      }
    } catch (e) {
      debugPrint('[P-ActiveRide] WS resync refetch failed: $e');
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
    if (kUseGeneratedSerializers) {
      _setupDispatcherListener();
    } else {
      _setupLegacyListener();
    }
  }

  void _setupDispatcherListener() {
    debugPrint('[P-ActiveRide] _setupDispatcherListener: rideId=$rideId');
    final dispatcher = WsDispatcher(_wsClient);
    _dispatcher = dispatcher;

    _wsDisposers.add(dispatcher.on<WsEventRideAccepted>(
      WsEventType.rideAccepted,
      (e) => _applyRideAccepted(e.driver),
    ));
    _wsDisposers.add(dispatcher.on<WsEventRideStatusChanged>(
      WsEventType.rideStatusChanged,
      (e) => _applyStatusChange(e.status.toString()),
    ));
    _wsDisposers.add(dispatcher.on<DriverLocationFast>(
      WsEventType.driverLocationUpdated,
      (e) => _applyDriverLocation(e.lat, e.lng),
    ));
    _wsDisposers.add(dispatcher.on<WsEventRideCancelled>(
      WsEventType.rideCancelled,
      (_) => _handleRideCancelled(),
    ));
    // P6 SOS lifecycle. Payloads arrive as BuiltMap<String, Object?>
    // because the built_value codegen has not yet regenerated for the
    // incident.* schemas (see WsDispatcher._deserialize).
    _wsDisposers.add(dispatcher.on<BuiltMap<String, Object?>>(
      WsEventType.rideSosTriggered,
      (p) => _applySosTrigger(p),
    ));
    _wsDisposers.add(dispatcher.on<BuiltMap<String, Object?>>(
      WsEventType.incidentAssigned,
      (p) => _applyIncidentAssigned(p),
    ));
    _wsDisposers.add(dispatcher.on<BuiltMap<String, Object?>>(
      WsEventType.incidentResolved,
      (_) => _applyIncidentResolved(),
    ));
  }

  void _applySosTrigger(BuiltMap<String, Object?> payload) {
    debugPrint('[P-ActiveRide] WS rideSosTriggered: incidentId=${payload["incident_id"]}, triggeredBy=${payload["triggered_by"]}');
    final current = _state.value;
    if (current == null) return;
    final incidentId = payload['incident_id'] as String?;
    final triggeredBy = payload['triggered_by'] as String?;
    final reason = payload['reason'] as String?;
    _state = AsyncValue.data(
      current.copyWith(
        sos: current.sos.withTrigger(
          incidentId: incidentId,
          triggeredBy: triggeredBy,
          reason: reason,
        ),
      ),
    );
    _stateController.add(_state);
  }

  void _applyIncidentAssigned(BuiltMap<String, Object?> payload) {
    debugPrint('[P-ActiveRide] WS incidentAssigned: assignee=${payload["assignee_name"]}');
    final current = _state.value;
    if (current == null) return;
    final assigneeName = payload['assignee_name'] as String?;
    _state = AsyncValue.data(
      current.copyWith(sos: current.sos.withAssignee(assigneeName)),
    );
    _stateController.add(_state);
  }

  void _applyIncidentResolved() {
    debugPrint('[P-ActiveRide] WS incidentResolved');
    final current = _state.value;
    if (current == null) return;
    _state = AsyncValue.data(
      current.copyWith(sos: current.sos.withResolved()),
    );
    _stateController.add(_state);
  }

  void _setupLegacyListener() {
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

  void _applyRideAccepted(DriverSummary driver) {
    debugPrint('[P-ActiveRide] WS rideAccepted: driver=${driver.name}');
    final vehicle = driver.vehicle;
    final vehicleStr = vehicle != null ? '${vehicle.make} ${vehicle.model}' : null;
    enrichDriverInfo(name: driver.name, vehicle: vehicleStr);
  }

  void _applyStatusChange(String rawStatus) {
    final rideStatus = RideState.fromString(rawStatus);
    debugPrint('[P-ActiveRide] WS rideStatusChanged: $rideStatus (raw=$rawStatus)');
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
      debugPrint('[P-ActiveRide] Terminal status=$rideStatus — firing callback');
      if (rideStatus == RideState.completed) {
        onCompleted?.call(rideId);
      } else {
        onCancelled?.call(rideId);
      }
    }
  }

  void _applyDriverLocation(double lat, double lng) {
    final current = _state.value;
    if (current == null) return;
    _state = AsyncValue.data(
      current.copyWith(driverLocation: gmaps.LatLng(lat, lng)),
    );
    _stateController.add(_state);
  }

  bool _terminated = false;

  void _handleStatusChanged(Map<String, dynamic> payload) {
    try {
      final rawStatus = payload['status'] as String?;
      if (rawStatus == null) {
        debugPrint('[PASSENGER] WsEventRideStatusChanged missing status field');
        return;
      }

      // Parse directly via RideState.fromString which handles case-insensitivity,
      // underscores, and different wire forms safely.
      final rideStatus = RideState.fromString(rawStatus);
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
        '[PASSENGER] Failed to handle WsEventRideStatusChanged: $e\n$st',
      );
    }
  }

  void _handleDriverLocation(Map<String, dynamic> payload) {
    try {
      // Primary parsing path: manual extraction of lat/lng with type resilience.
      double? lat;
      double? lng;

      final loc = payload['location'];
      if (loc is Map) {
        final rawLat = loc['lat'];
        final rawLng = loc['lng'];

        if (rawLat is num) {
          lat = rawLat.toDouble();
        } else if (rawLat is String) {
          lat = double.tryParse(rawLat);
        }

        if (rawLng is num) {
          lng = rawLng.toDouble();
        } else if (rawLng is String) {
          lng = double.tryParse(rawLng);
        }
      }

      if (lat == null || lng == null) {
        final rawLat = payload['lat'];
        final rawLng = payload['lng'];

        if (rawLat is num) {
          lat = rawLat.toDouble();
        } else if (rawLat is String) {
          lat = double.tryParse(rawLat);
        }

        if (rawLng is num) {
          lng = rawLng.toDouble();
        } else if (rawLng is String) {
          lng = double.tryParse(rawLng);
        }
      }

      if (lat != null && lng != null) {
        final current = _state.value;
        if (current == null) return;

        _state = AsyncValue.data(
          current.copyWith(
            driverLocation: gmaps.LatLng(lat, lng),
          ),
        );
        _stateController.add(_state);
        return;
      }

      // Fallback path: built_value deserialization.
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
    debugPrint('[P-ActiveRide] WS rideCancelled: rideId=$rideId, _terminated=$_terminated');
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
    debugPrint('[P-ActiveRide] dispose: rideId=$rideId');
    _wsSubscription?.cancel();
    for (final d in _wsDisposers) {
      d();
    }
    _wsDisposers.clear();
    final dispatcher = _dispatcher;
    if (dispatcher != null) {
      unawaited(dispatcher.dispose());
      _dispatcher = null;
    }
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
