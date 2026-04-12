import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/providers.dart';
import '../../home/services/gps_location_service.dart';
import '../models/driver_session.dart';

class DriverHomeState {
  final bool online;
  final bool loading;
  final String? errorMessage;
  final bool gpsAvailable;
  final DriverSessionStatus status;

  const DriverHomeState({
    required this.online,
    required this.loading,
    this.errorMessage,
    this.gpsAvailable = false,
    this.status = DriverSessionStatus.offline,
  });

  DriverHomeState copyWith({
    bool? online,
    bool? loading,
    String? errorMessage,
    bool? gpsAvailable,
    DriverSessionStatus? status,
  }) {
    return DriverHomeState(
      online: online ?? this.online,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
      gpsAvailable: gpsAvailable ?? this.gpsAvailable,
      status: status ?? this.status,
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

class DriverHomeNotifier extends Notifier<DriverHomeState> {
  StreamSubscription<WsEvent>? _wsSubscription;
  Timer? _gpsTimer;
  final GpsLocationService _gpsService = GpsLocationService();

  // Event callbacks — set by the screen or a higher-level coordinator.
  OnRideOffer? onRideOffer;
  OnOfferExpired? onOfferExpired;
  OnStatusChanged? onStatusChanged;
  OnRideCancelled? onRideCancelled;

  @override
  DriverHomeState build() {
    ref.onDispose(() {
      _stopGpsStreaming();
      _unsubscribeWs();
    });
    return const DriverHomeState(online: false, loading: false);
  }

  /// Sets up WS event subscriptions. Called by the screen on init.
  void setupWsListener(WsClient wsClient) {
    _unsubscribeWs();
    _wsSubscription = wsClient.events.listen(_handleWsEvent);
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
      return WsEventRideRequested(
        (b) => b
          ..rideId = payload['ride_id'] as String
          ..expiresAt = DateTime.parse(payload['expires_at'] as String),
      );
    } catch (_) {
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

    state = state.copyWith(loading: true, errorMessage: null);

    try {
      if (targetOnline) {
        await repo.goOnline();
        state = state.copyWith(
          online: true,
          loading: false,
          status: DriverSessionStatus.online,
        );
        _startGpsStreaming();
      } else {
        await repo.goOffline();
        state = state.copyWith(
          online: false,
          loading: false,
          status: DriverSessionStatus.offline,
        );
        _stopGpsStreaming();
      }
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(loading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'An unexpected error occurred.',
      );
    }
  }

  /// Starts periodic GPS streaming (every 4 seconds).
  void _startGpsStreaming() {
    _stopGpsStreaming();
    _gpsTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _sendLocation(),
    );
    // Send first location immediately.
    _sendLocation();
  }

  void _stopGpsStreaming() {
    _gpsTimer?.cancel();
    _gpsTimer = null;
  }

  Future<void> _sendLocation() async {
    if (!state.online) return;

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

      await repo.updateLocation(
        position.latitude,
        position.longitude,
        heading: position.heading,
      );

      if (!state.gpsAvailable) {
        state = state.copyWith(gpsAvailable: true);
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
