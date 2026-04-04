import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../features/auth/views/auth_screen.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/auth/views/welcome_screen.dart';
import '../features/home/views/rider_home_screen.dart';
import '../features/ride/views/waiting_screen.dart';
import 'providers.dart';
import 'routes.dart';

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
        return isLogin ? null : Routes.login;
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
