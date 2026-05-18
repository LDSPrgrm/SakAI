import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../features/auth/repositories/driver_auth_repository.dart';
import '../features/auth/repositories/driver_auth_repository_impl.dart';
import '../features/home/repositories/driver_repository.dart';
import '../features/home/repositories/driver_repository_impl.dart';
import '../features/home/services/gps_location_service.dart';
import '../features/active_ride/repositories/active_ride_repository.dart';
import '../features/active_ride/repositories/active_ride_repository_impl.dart';
import '../features/active_ride/services/location_stream_service.dart';
import '../features/earnings/repositories/earnings_repository.dart';

import '../features/documents/repositories/driver_document_repository.dart';
import '../features/documents/repositories/driver_document_repository_impl.dart';
import '../features/profile/repositories/driver_profile_repository.dart';
import '../features/profile/repositories/driver_profile_repository_impl.dart';
import '../features/settings/repositories/availability_repository.dart';
import '../features/settings/repositories/availability_repository_impl.dart';
import '../features/notifications/repositories/notifications_repository.dart';
import '../features/notifications/repositories/notifications_repository_impl.dart';
import '../features/sos/repositories/sos_repository_impl.dart';
import '../features/ride_history/repositories/ride_history_repository.dart';
import '../features/ride_history/repositories/ride_history_repository_impl.dart';

// Note: tokenStorageProvider, onboardingServiceProvider, authStateProvider are
// provided by sakai_shared or defined below to avoid conflicts.

/// Shared HTTP client — single instance per app lifetime.
final apiClientProvider = Provider<SakaiApiClient>((ref) {
  return SakaiApiSupport.createClient(
    authInterceptor: AuthInterceptor(
      ref.watch(tokenStorageProvider),
      onSessionInvalidated: () {
        ref
            .read(authStateProvider.notifier)
            .markUnauthenticated(forceLogin: true);
      },
    ),
  );
});

/// Auth repository — domain boundary over the generated API client.
final authRepositoryProvider = Provider<DriverAuthRepository>((ref) {
  return DriverAuthRepositoryImpl(ref.watch(apiClientProvider));
});

/// Driver repository — domain boundary for driver status and location.
final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepositoryImpl(ref.watch(apiClientProvider));
});

/// Active ride repository — domain boundary for ride state transitions.
final activeRideRepositoryProvider = Provider<ActiveRideRepository>((ref) {
  return ActiveRideRepositoryImpl(ref.watch(apiClientProvider));
});

/// Earnings repository — domain boundary for historical and session earnings.
final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return EarningsRepositoryImpl(ref.watch(apiClientProvider));
});

/// Driver documents repository — domain boundary for document uploads and status.
final driverDocumentRepositoryProvider = Provider<DriverDocumentRepository>((ref) {
  return DriverDocumentRepositoryImpl(ref.watch(apiClientProvider));
});

/// Driver profile repository — GET wired, PATCH pending.
final driverProfileRepositoryProvider = Provider<DriverProfileRepository>((ref) {
  return DriverProfileRepositoryImpl(ref.watch(apiClientProvider));
});

/// Availability prefs repository — backend pending.
final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return AvailabilityRepositoryImpl(ref.watch(apiClientProvider));
});

/// Notifications inbox repository — backend pending.
final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(ref.watch(apiClientProvider));
});

/// SOS repository — wired against existing POST /rides/{rideId}/sos.
final sosRepositoryProvider = Provider<SOSRepository>((ref) {
  return SOSRepositoryImpl(ref.watch(apiClientProvider).getRidesApi());
});

/// Ride history (trip history) repository — wired against existing
/// driverGetEarnings / adminListDriverRides endpoints.
final rideHistoryRepositoryProvider = Provider<RideHistoryRepository>((ref) {
  return RideHistoryRepositoryImpl(ref.watch(apiClientProvider).getDriverApi());
});

/// WebSocket client singleton for real-time events.
final wsClientProvider = Provider<WsClient>((ref) {
  final client = WsClient();
  ref.onDispose(() => client.disconnect());
  return client;
});

/// WebSocket connection manager - watches auth state.
final wsConnectionProvider = Provider<WsConnectionManager>((ref) {
  return WsConnectionManager(ref);
});

/// Manages WebSocket connection lifecycle based on auth state.
class WsConnectionManager {
  final Ref _ref;
  bool _isConnected = false;

  WsConnectionManager(this._ref);

  /// Connect WebSocket when authenticated.
  Future<void> connectIfAuthenticated() async {
    final client = _ref.read(wsClientProvider);
    // Check the actual client connection state, not just the manager's flag.
    if (client.isConnected) return;

    final tokenStorage = _ref.read(tokenStorageProvider);
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      _isConnected = true;
      await client.connect(
        baseUrl: SakaiApiEndpoints.defaultRestBaseUrl,
        accessToken: accessToken,
      );
    }
  }

  /// Disconnect WebSocket on logout.
  Future<void> disconnect() async {
    if (_isConnected) {
      final client = _ref.read(wsClientProvider);
      await client.disconnect();
      _isConnected = false;
    }
  }

  /// Check if currently connected.
  bool get isConnected => _isConnected;
}

/// GPS location service singleton.
final gpsLocationServiceProvider = Provider<GpsLocationService>((ref) {
  return GpsLocationService();
});

/// Background GPS push pipeline for the active ride.
/// Singleton so reconnects to the active-ride screen reuse the running stream.
final locationStreamServiceProvider = Provider<LocationStreamService>((ref) {
  final service = LocationStreamService(
    driverRepo: ref.watch(driverRepositoryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Auth state provider - tracks authentication status.
final authStateProvider = NotifierProvider<AuthState, AuthStateModel>(
  AuthState.new,
);

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthStateModel {
  const AuthStateModel({required this.status, this.forceLogin = false});

  final AuthStatus status;
  final bool forceLogin;

  AuthStateModel copyWith({AuthStatus? status, bool? forceLogin}) {
    return AuthStateModel(
      status: status ?? this.status,
      forceLogin: forceLogin ?? this.forceLogin,
    );
  }
}

class AuthState extends Notifier<AuthStateModel> {
  @override
  AuthStateModel build() =>
      const AuthStateModel(status: AuthStatus.unknown, forceLogin: false);

  void markAuthenticated() {
    state = const AuthStateModel(
      status: AuthStatus.authenticated,
      forceLogin: false,
    );
  }

  void markUnauthenticated({bool forceLogin = false}) {
    state = AuthStateModel(
      status: AuthStatus.unauthenticated,
      forceLogin: forceLogin,
    );
  }

  void resetToUnknown() {
    state = const AuthStateModel(status: AuthStatus.unknown, forceLogin: false);
  }
}
