import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../features/auth/views/login_screen.dart';
import '../features/auth/views/register_screen.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/auth/views/welcome_screen.dart';
import '../features/home/views/driver_home_screen.dart';
import '../features/ride_offer/views/ride_offer_screen.dart';
import '../features/active_ride/views/active_ride_screen.dart';
import '../features/earnings/views/earnings_screen.dart';
import '../features/ride_complete/views/driver_rating_screen.dart';
import '../features/ride_complete/repositories/driver_rating_repository_impl.dart';
import '../features/ride_complete/views/driver_rating_repository_provider.dart';
import 'providers.dart';

abstract class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const rideOffer = '/ride-offer';
  static const rideActive = '/ride/active';
  static const earnings = '/earnings';
  static const rideRating = '/ride-complete/rating';
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = ValueNotifier<AuthStateModel>(ref.read(authStateProvider));
  ref.listen<AuthStateModel>(authStateProvider, (_, next) {
    listenable.value = next;
  });

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final onboarding = ref.read(onboardingServiceProvider);
      final hasSeenWelcome = onboarding.hasSeenWelcome();

      final isSplash = state.matchedLocation == Routes.splash;
      final isWelcome = state.matchedLocation == Routes.welcome;
      final isLogin = state.matchedLocation == Routes.login;
      final isRegister = state.matchedLocation == Routes.register;
      final isAuthRoute = isWelcome || isLogin || isRegister;

      if (isSplash) return null;

      if (authState.status == AuthStatus.unknown) {
        return Routes.splash;
      }

      if (authState.status == AuthStatus.authenticated) {
        if (isAuthRoute) return Routes.home;
        return null;
      }

      if (authState.forceLogin) {
        if (isLogin || isRegister) return null;
        return Routes.login;
      }

      final unauthLanding = hasSeenWelcome ? Routes.login : Routes.welcome;
      if (!isAuthRoute) return unauthLanding;
      if (!hasSeenWelcome && !isWelcome) return Routes.welcome;
      if (hasSeenWelcome && isWelcome) return Routes.login;

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: Routes.rideOffer,
        builder: (context, state) {
          final offer = state.extra as WsEventRideRequested?;
          if (offer == null) {
            return const Scaffold(body: Center(child: Text('No offer data')));
          }
          return RideOfferScreen(offerEvent: offer);
        },
      ),
      GoRoute(
        path: Routes.rideActive,
        builder: (context, state) {
          final ride = state.extra as RideResponse?;
          if (ride != null) return ActiveRideScreen(initialRide: ride);
          return const _ActiveRideLoader();
        },
      ),
      GoRoute(
        path: Routes.earnings,
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: Routes.rideRating,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return const Scaffold(body: Center(child: Text('No ride data')));
          }
          final rideId = extra['rideId'] as String;
          final passengerName = extra['passengerName'] as String;
          final ratingRepo = DriverRatingRepositoryImpl(
            ref.read(apiClientProvider),
          );
          return DriverRatingRepositoryProvider(
            repository: ratingRepo,
            child: DriverRatingScreen(
              rideId: rideId,
              passengerName: passengerName,
            ),
          );
        },
      ),
    ],
  );
});

/// Loads the active ride from the API and navigates to the screen.
class _ActiveRideLoader extends ConsumerWidget {
  const _ActiveRideLoader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
