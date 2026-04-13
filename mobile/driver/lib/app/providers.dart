import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../features/auth/repositories/driver_auth_repository.dart';
import '../features/auth/repositories/driver_auth_repository_impl.dart';
import '../features/home/repositories/driver_repository.dart';
import '../features/home/repositories/driver_repository_impl.dart';
import '../features/home/services/gps_location_service.dart';
import '../features/active_ride/repositories/active_ride_repository.dart';
import '../features/active_ride/repositories/active_ride_repository_impl.dart';

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
    final tokenStorage = _ref.read(tokenStorageProvider);
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty && !_isConnected) {
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
