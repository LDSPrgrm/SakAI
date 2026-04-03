import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/views/auth_screen.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/auth/views/welcome_screen.dart';
import '../features/home/views/rider_home_screen.dart';
import '../features/ride/views/waiting_screen.dart';

// ---------------------------------------------------------------------------
// Route names — constants to avoid typos across the app.
// ---------------------------------------------------------------------------

abstract class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const rideWaiting = '/ride/waiting';
  static const rideActive = '/ride/active';
  static const rideComplete = '/ride/complete';
  static const rideCancelled = '/ride/cancelled';
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

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
        builder: (context, state) =>
            const AuthScreen(initialMode: AuthMode.login),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) =>
            const AuthScreen(initialMode: AuthMode.register),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const RiderHomeScreen(),
      ),
      GoRoute(
        path: Routes.rideWaiting,
        builder: (context, state) {
          final rideId = state.extra as String;
          return WaitingScreen(rideId: rideId);
        },
      ),
      // Active ride, complete, and cancelled screens added in Sprint 3.
      GoRoute(
        path: Routes.rideActive,
        builder: (context, state) => _PlaceholderScreen(Routes.rideActive),
      ),
      GoRoute(
        path: Routes.rideComplete,
        builder: (context, state) => _PlaceholderScreen(Routes.rideComplete),
      ),
      GoRoute(
        path: Routes.rideCancelled,
        builder: (context, state) => _PlaceholderScreen(Routes.rideCancelled),
      ),
    ],
  );
});

/// Placeholder used for routes not yet implemented in the current sprint.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.route);
  final String route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(route)),
      body: Center(child: Text('Coming in Sprint 3: $route')),
    );
  }
}
