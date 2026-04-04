import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/repositories/auth_repository_impl.dart';
import '../features/ride/repositories/ride_repository.dart';
import '../features/ride/repositories/ride_repository_impl.dart';

/// Shared HTTP client - single instance per app lifetime.
final apiClientProvider = Provider<SakaiApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return SakaiApiSupport.createClient(
    authInterceptor: AuthInterceptor(
      tokenStorage,
      onSessionInvalidated: () {
        ref
            .read(authStateProvider.notifier)
            .markUnauthenticated(forceLogin: true);
      },
    ),
  );
});

/// Auth repository - domain boundary over the generated API client.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiClientProvider));
});

/// Ride repository - domain boundary over the generated API client.
final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepositoryImpl(ref.watch(apiClientProvider));
});

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
