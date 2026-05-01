import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/e2e_mode_stub.dart'
    if (dart.library.js_interop) '../../../app/e2e_mode_web.dart';
import '../../../app/providers.dart';
import '../../home/services/gps_location_service.dart';
import '../models/driver_session.dart';

class DriverHomeState {
  final bool online;
  final bool loading;
  final String? errorMessage;
  final bool gpsAvailable;
  final DriverSessionStatus status;
  final RideResponse? activeRide;
  final gmaps.LatLng? currentLatLng;

  const DriverHomeState({
    required this.online,
    required this.loading,
    this.errorMessage,
    this.gpsAvailable = false,
    this.status = DriverSessionStatus.offline,
    this.activeRide,
    this.currentLatLng,
  });

  DriverHomeState copyWith({
    bool? online,
    bool? loading,
    String? errorMessage,
    bool? gpsAvailable,
    DriverSessionStatus? status,
    RideResponse? activeRide,
    gmaps.LatLng? currentLatLng,
  }) {
    return DriverHomeState(
      online: online ?? this.online,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
      gpsAvailable: gpsAvailable ?? this.gpsAvailable,
      status: status ?? this.status,
      activeRide: activeRide ?? this.activeRide,
      currentLatLng: currentLatLng ?? this.currentLatLng,
    );
  }
}

final driverHomeNotifierProvider =
    NotifierProvider<DriverHomeNotifier, DriverHomeState>(
      DriverHomeNotifier.new,
    );

/// Callbacks for WS event routing — the screen or coordinator sets these.
typedef OnRideOffer = void Function(WsEventRideRequested offer);
typedef OnOfferExpired = void Function(String rideId);
typedef OnStatusChanged = void Function(String rideId, RideStatus status);
typedef OnRideCancelled = void Function(String rideId);
typedef OnActiveRideDetected = void Function(RideResponse activeRide);

class DriverHomeNotifier extends Notifier<DriverHomeState> {
  StreamSubscription<WsEvent>? _wsSubscription;
  Timer? _gpsTimer;
  Timer? _incomingRidePollTimer;
  final GpsLocationService _gpsService = GpsLocationService();

  // Event callbacks — set by the screen or a higher-level coordinator.
  OnRideOffer? onRideOffer;
  OnOfferExpired? onOfferExpired;
  OnStatusChanged? onStatusChanged;
  OnRideCancelled? onRideCancelled;
  OnActiveRideDetected? onActiveRideDetected;

  @override
  DriverHomeState build() {
    ref.onDispose(() {
      _stopGpsStreaming();
      _unsubscribeWs();
      _stopIncomingRidePolling();
    });
    return const DriverHomeState(online: false, loading: false);
  }

  /// Sets up WS event subscriptions. Called by the screen on init.
  void setupWsListener(WsClient wsClient) {
    _unsubscribeWs();
    _wsSubscription = wsClient.events.listen(_handleWsEvent);
  }

  /// Connects the WebSocket client. Should be called after authentication.
  /// Skips if already connected (e.g., splash screen handled it).
  Future<void> connectWebSocket(WsClient wsClient) async {
    if (wsClient.isConnected) {
      debugPrint('[DRIVER] WebSocket already connected, skipping reconnect');
      // Still set up listener and poll for missed offers.
      setupWsListener(wsClient);
      await pollIncomingRide(wsClient);
      return;
    }
    try {
      final tokenStorage = ref.read(tokenStorageProvider);
      final accessToken = await tokenStorage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        await wsClient.connect(
          baseUrl: SakaiApiEndpoints.defaultRestBaseUrl,
          accessToken: accessToken,
        );
        setupWsListener(wsClient);
        // Missed offer recovery: poll for incoming ride after WS reconnect.
        await pollIncomingRide(wsClient);
      }
    } catch (e) {
      // WS connection failure is not fatal — will retry on next init.
      debugPrint('WS connection failed: $e');
    }
  }

  /// Polls for any pending incoming ride offer (e.g., after WS reconnection).
  /// If a pending ride is found, triggers the onRideOffer callback.
  Future<void> pollIncomingRide(WsClient wsClient) async {
    try {
      final repo = ref.read(driverRepositoryProvider);
      final incomingRide = await repo.getIncomingRide();
      if (incomingRide == null) return;
      if (incomingRide.status != RideStatus.requested) return;

      debugPrint(
        '[DRIVER] Found pending incoming ride: ${incomingRide.id}, triggering offer.',
      );
      // Build a WsEventRideRequested from the RideResponse.
      final passenger = incomingRide.passenger;
      final origin = incomingRide.origin;
      final destination = incomingRide.destination;
      final offer = WsEventRideRequested(
        (b) => b
          ..rideId = incomingRide.id
          ..passenger = $UserProfile(
            (pb) => pb
              ..id = passenger.id
              ..name = passenger.name
              ..email = passenger.email
              ..role = passenger.role
              ..createdAt = passenger.createdAt,
          )
          ..origin = (LatLngBuilder()
            ..lat = origin.lat
            ..lng = origin.lng)
          ..destination = (LatLngBuilder()
            ..lat = destination.lat
            ..lng = destination.lng)
          ..originAddress = incomingRide.originAddress ?? ''
          ..destinationAddress = incomingRide.destinationAddress ?? ''
          ..expiresAt = DateTime.now().add(const Duration(seconds: 30)),
      );
      onRideOffer?.call(offer);
    } catch (e) {
      debugPrint('[DRIVER] Poll incoming ride error: $e');
    }
  }

  /// Checks for an active ride and updates state accordingly.
  /// Returns true if an active ride was found.
  Future<bool> checkForActiveRide() async {
    try {
      final rideRepo = ref.read(activeRideRepositoryProvider);
      final activeRide = await rideRepo.getActiveRide();

      if (activeRide != null) {
        debugPrint(
          '[DRIVER] Found active ride: ${activeRide.id}, status: ${activeRide.status}',
        );
        state = state.copyWith(activeRide: activeRide);
        onActiveRideDetected?.call(activeRide);
        return true;
      }

      // Clear active ride from state if none exists
      if (state.activeRide != null) {
        state = state.copyWith(activeRide: null);
      }
      return false;
    } catch (e) {
      debugPrint('[DRIVER] Check for active ride error: $e');
      return false;
    }
  }

  void _handleWsEvent(WsEvent event) {
    switch (event.type) {
      case WsEventNames.rideRequested:
        final offer = _parseRideRequested(event.payload);
        if (offer != null) onRideOffer?.call(offer);
        break;
      case WsEventNames.rideOfferExpired:
        final rideId = event.payload['ride_id'] as String? ?? '';
        onOfferExpired?.call(rideId);
        break;
      case WsEventNames.rideStatusChanged:
        final rideId = event.payload['ride_id'] as String? ?? '';
        final statusStr = event.payload['status'] as String? ?? '';
        final status = _parseRideStatus(statusStr);
        if (status != null) onStatusChanged?.call(rideId, status);
        break;
      case WsEventNames.rideCancelled:
        final rideId = event.payload['ride_id'] as String? ?? '';
        onRideCancelled?.call(rideId);
        break;
    }
  }

  WsEventRideRequested? _parseRideRequested(Map<String, dynamic> payload) {
    try {
      debugPrint('[DRIVER] _parseRideRequested payload: $payload');
      return standardSerializers.deserializeWith(
        WsEventRideRequested.serializer,
        payload,
      );
    } catch (e, stackTrace) {
      debugPrint('[DRIVER] Failed to parse ride requested: $e');
      debugPrint('[DRIVER] Stack trace: $stackTrace');
      debugPrint('[DRIVER] Payload was: $payload');
      return null;
    }
  }

  RideStatus? _parseRideStatus(String s) {
    try {
      return RideStatus.valueOf(s);
    } catch (_) {
      return null;
    }
  }

  /// Toggles driver online/offline status.
  Future<void> toggleStatus() async {
    if (state.loading) return;

    final repo = ref.read(driverRepositoryProvider);
    final targetOnline = !state.online;

    debugPrint('[DRIVER] Toggle: targetOnline=$targetOnline');
    state = state.copyWith(loading: true, errorMessage: null);

    try {
      if (kIsWeb && isE2EMode()) {
        state = state.copyWith(
          online: targetOnline,
          loading: false,
          status: targetOnline
              ? DriverSessionStatus.online
              : DriverSessionStatus.offline,
        );
        if (targetOnline) {
          _startIncomingRidePolling();
        } else {
          _stopIncomingRidePolling();
        }
        return;
      }

      if (targetOnline) {
        debugPrint('[DRIVER] Calling goOnline()...');
        await repo.goOnline();
        debugPrint('[DRIVER] goOnline() success');
        state = state.copyWith(
          online: true,
          loading: false,
          status: DriverSessionStatus.online,
        );
        _startIncomingRidePolling();
      } else {
        debugPrint('[DRIVER] Calling goOffline()...');
        await repo.goOffline();
        debugPrint('[DRIVER] goOffline() success');
        state = state.copyWith(
          online: false,
          loading: false,
          status: DriverSessionStatus.offline,
        );
        _stopIncomingRidePolling();
      }
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[DRIVER] Toggle error: $msg');
      state = state.copyWith(loading: false, errorMessage: msg);
    } catch (e) {
      debugPrint('[DRIVER] Unexpected error: $e');
      state = state.copyWith(
        loading: false,
        errorMessage: 'An unexpected error occurred.',
      );
    }
  }

  /// Starts GPS tracking (always runs, regardless of online status).
  /// Position updates the marker; backend updates only happen when online.
  void startGpsTracking() {
    _stopGpsStreaming();
    _gpsTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _sendLocation(),
    );
    _sendLocation();
  }

  void _stopGpsStreaming() {
    _gpsTimer?.cancel();
    _gpsTimer = null;
  }

  /// Starts periodic polling for incoming ride offers (every 15 seconds).
  /// This acts as a fallback in case WebSocket events are dropped.
  /// WS is the primary path — polling is a safety net for mobile network unreliability.
  void _startIncomingRidePolling() {
    _stopIncomingRidePolling();
    _incomingRidePollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _pollIncomingRideOnce(),
    );
    // Poll immediately when starting.
    _pollIncomingRideOnce();
  }

  void _stopIncomingRidePolling() {
    _incomingRidePollTimer?.cancel();
    _incomingRidePollTimer = null;
  }

  Future<void> _pollIncomingRideOnce() async {
    if (!state.online) return;

    try {
      final repo = ref.read(driverRepositoryProvider);
      final incomingRide = await repo.getIncomingRide();
      if (incomingRide == null) return;
      if (incomingRide.status != RideStatus.requested) return;

      debugPrint(
        '[DRIVER] Polling found incoming ride: ${incomingRide.id}, triggering offer.',
      );
      // Build a WsEventRideRequested from the RideResponse.
      final passenger = incomingRide.passenger;
      final origin = incomingRide.origin;
      final destination = incomingRide.destination;
      final offer = WsEventRideRequested(
        (b) => b
          ..rideId = incomingRide.id
          ..passenger = $UserProfile(
            (pb) => pb
              ..id = passenger.id
              ..name = passenger.name
              ..email = passenger.email
              ..role = passenger.role
              ..createdAt = passenger.createdAt,
          )
          ..origin = (LatLngBuilder()
            ..lat = origin.lat
            ..lng = origin.lng)
          ..destination = (LatLngBuilder()
            ..lat = destination.lat
            ..lng = destination.lng)
          ..originAddress = incomingRide.originAddress ?? ''
          ..destinationAddress = incomingRide.destinationAddress ?? ''
          ..expiresAt = DateTime.now().add(const Duration(seconds: 30)),
      );
      onRideOffer?.call(offer);
    } catch (e) {
      // Polling errors are expected when there's no incoming ride — log at debug level only once
      debugPrint('[DRIVER] Incoming ride poll: $e');
    }
  }

  Future<void> _sendLocation() async {
    final repo = ref.read(driverRepositoryProvider);
    try {
      final position = await _gpsService.getCurrentPosition();
      if (position == null) {
        if (state.gpsAvailable) {
          state = state.copyWith(gpsAvailable: false);
        }
        return;
      }

      if (!_gpsService.isValidCoordinate(
        position.latitude,
        position.longitude,
      )) {
        if (state.gpsAvailable) {
          state = state.copyWith(gpsAvailable: false);
        }
        return;
      }

      // Always update the marker position (even when offline).
      state = state.copyWith(
        gpsAvailable: true,
        currentLatLng: gmaps.LatLng(position.latitude, position.longitude),
      );

      // Only send to backend when online.
      if (state.online) {
        await repo.updateLocation(
          position.latitude,
          position.longitude,
          heading: position.heading,
        );
      }
    } catch (_) {
      // Silently ignore — retry on next interval.
      if (state.gpsAvailable) {
        state = state.copyWith(gpsAvailable: false);
      }
    }
  }

  /// Checks GPS availability and updates state (called periodically by UI).
  Future<void> checkGps() async {
    final available = await _gpsService.isGpsAvailable();
    if (available != state.gpsAvailable) {
      state = state.copyWith(gpsAvailable: available);
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  void unsubscribeWs() {
    _unsubscribeWs();
  }

  void _unsubscribeWs() {
    _wsSubscription?.cancel();
    _wsSubscription = null;
  }
}
