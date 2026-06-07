import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/repositories/auth_repository_impl.dart';
import '../features/wallet/repositories/wallet_repository.dart';
import '../features/wallet/repositories/wallet_repository_impl.dart';
import '../features/notifications/repositories/notifications_repository.dart';
import '../features/notifications/repositories/notifications_repository_impl.dart';
import '../features/ride/repositories/ride_repository.dart';
import '../features/ride/repositories/ride_repository_impl.dart';
import '../features/ride_complete/repositories/ride_complete_repository.dart';
import '../features/ride_complete/repositories/ride_complete_repository_impl.dart';
import '../features/ride_history/repositories/ride_history_repository.dart';
import '../features/ride_history/repositories/ride_history_repository_impl.dart';
import '../features/cancelled_ride/repositories/cancelled_ride_repository.dart';
import '../features/cancelled_ride/repositories/cancelled_ride_repository_impl.dart';
import '../features/receipt/repositories/receipt_repository.dart';
import '../features/receipt/repositories/receipt_repository_impl.dart';
import '../features/support/repositories/sos_repository_impl.dart';
import '../features/active_ride/models/active_ride_state.dart';
import '../features/active_ride/view_models/active_ride_notifier.dart';
import '../features/home/repositories/geocoding_service.dart';
export '../features/active_ride/view_models/active_ride_notifier.dart'
    show ActiveRideController;

/// Shared HTTP client - single instance per app lifetime.
final apiClientProvider = Provider<SakaiApiClient>((ref) {
  return SakaiApiSupport.createClient(
    authInterceptor: ref.watch(authInterceptorProvider),
  );
});

/// Auth interceptor - reusable for any repo that needs its own client.
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthInterceptor(
    tokenStorage,
    onSessionInvalidated: () {
      ref
          .read(authStateProvider.notifier)
          .markUnauthenticated(forceLogin: true);
    },
  );
});

/// Auth repository - domain boundary over the generated API client.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiClientProvider));
});

/// Wallet repository — backend endpoints pending; throws BackendUnavailableException.
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(ref.watch(apiClientProvider));
});

/// Notifications repository — backend endpoints pending; throws BackendUnavailableException.
final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepositoryImpl(ref.watch(apiClientProvider));
});

/// Ride repository - domain boundary over the generated API client.
final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepositoryImpl(ref.watch(apiClientProvider));
});

/// WebSocket client - singleton for real-time events.
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

  WsConnectionManager(this._ref);

  /// Connect WebSocket when authenticated.
  Future<void> connectIfAuthenticated() async {
    final client = _ref.read(wsClientProvider);
    if (client.isConnected) return;

    final tokenStorage = _ref.read(tokenStorageProvider);
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      await client.connect(
        baseUrl: SakaiApiEndpoints.defaultRestBaseUrl,
        accessToken: accessToken,
      );
    }
  }

  /// Disconnect WebSocket on logout.
  Future<void> disconnect() async {
    final client = _ref.read(wsClientProvider);
    await client.disconnect();
  }

  /// Check if currently connected.
  bool get isConnected => _ref.read(wsClientProvider).isConnected;
}

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

/// Auth state notifier - manages the reactive auth lifecycle state.
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

/// Provider for the auth state, used by the router for redirects.
final authStateProvider = NotifierProvider<AuthState, AuthStateModel>(
  AuthState.new,
);

/// Ride complete repository - domain boundary over the generated API client.
final rideCompleteRepositoryProvider = Provider<RideCompleteRepository>((ref) {
  return RideCompleteRepositoryImpl(ref.watch(apiClientProvider));
});

/// Ride history repository - domain boundary over the generated API client.
final rideHistoryRepositoryProvider = Provider<RideHistoryRepository>((ref) {
  return RideHistoryRepositoryImpl(ref.watch(apiClientProvider));
});

/// Geocoding service provider.
final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

/// Cancelled ride repository - domain boundary over the generated API client.
final cancelledRideRepositoryProvider = Provider<CancelledRideRepository>((
  ref,
) {
  return CancelledRideRepositoryImpl(ref.watch(apiClientProvider));
});

/// Receipt repository - domain boundary over the generated API client.
final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepositoryImpl(ref.watch(apiClientProvider));
});

/// SOS repository - domain boundary over the generated API client.
final sosRepositoryProvider = Provider<SOSRepository>((ref) {
  return SOSRepositoryImpl(ref.watch(apiClientProvider).getRidesApi());
});

/// Active ride controller provider — keyed by ride ID.
///
/// Usage: `ref.watch(activeRideProvider(rideId))` returns an
/// `ActiveRideController` with a `stateStream` and `state` property.
final activeRideProvider = Provider.family<ActiveRideController, String>((
  ref,
  rideId,
) {
  final client = ref.watch(apiClientProvider);
  final wsClient = ref.watch(wsClientProvider);
  final sosRepository = ref.watch(sosRepositoryProvider);
  final controller = ActiveRideController(
    rideId: rideId,
    client: client,
    wsClient: wsClient,
    sosRepository: sosRepository,
  );
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Exposes the current async state from the controller as a provider.
final activeRideStateProvider =
    Provider.family<AsyncValue<ActiveRideState>, String>((ref, rideId) {
      final controller = ref.watch(activeRideProvider(rideId));
      return controller.state;
    });

/// Streams the controller's state so widgets/providers can rebuild on
/// every WS-driven transition. Use this when synchronous `.state` reads
/// would miss SOS/incident lifecycle updates that arrive after mount.
final activeRideStateStreamProvider =
    StreamProvider.family<ActiveRideState, String>((ref, rideId) {
      final controller = ref.watch(activeRideProvider(rideId));
      return controller.stateStream
          .where((async) => async.value != null)
          .map((async) => async.value!);
    });

/// Surfaces just the SosUiState for a ride. Wraps the stream provider so
/// callers don't have to extract `.sos` themselves. Returns
/// [SosUiState.idle] until the first state frame arrives.
///
/// Replaces the stubbed `SOSRepository.getActiveIncident` for in-app
/// consumers — that REST contract still exists but always returns null
/// (no backend endpoint). Anything that needs to know whether an
/// incident is open for the active ride should watch this.
final passengerSosStateProvider = Provider.family<SosUiState, String>((
  ref,
  rideId,
) {
  final async = ref.watch(activeRideStateStreamProvider(rideId));
  return async.maybeWhen(
    data: (state) => state.sos,
    orElse: () => SosUiState.idle,
  );
});
