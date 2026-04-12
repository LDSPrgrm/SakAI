import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import '../features/auth/views/login_screen.dart';
import '../features/auth/views/register_screen.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/auth/views/welcome_screen.dart';
import '../features/home/views/driver_home_screen.dart';
import '../features/ride_offer/views/ride_offer_screen.dart';
import '../features/active_ride/views/active_ride_screen.dart';
import '../features/earnings/views/earnings_screen.dart';

abstract class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const rideOffer = '/ride-offer';
  static const rideActive = '/ride/active';
  static const earnings = '/earnings';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
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
