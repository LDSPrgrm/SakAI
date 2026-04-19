import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/providers.dart';
import '../models/session_check_result.dart';

enum SplashState {
  loading,
  unauthenticated,
  home,
  activeRide,
  welcome,
  transientError,
}

class SplashNotifier extends AsyncNotifier<SplashState> {
  @override
  Future<SplashState> build() async {
    // Rely on Riverpod's built-in caching per ProviderContainer.
    // No static state to avoid cross-test interference.
    return await _check();
  }

  Future<SplashState> _check() async {
    // Minimal delay for UX in production, can be zero in tests.
    await Future.delayed(Duration.zero);

    final onboarding = ref.read(onboardingServiceProvider);

    // 1. First launch should always show onboarding welcome.
    if (!onboarding.hasSeenWelcome()) {
      ref.read(authStateProvider.notifier).markUnauthenticated();
      return SplashState.welcome;
    }

    final authRepo = ref.read(authRepositoryProvider);

    final result = await authRepo.checkSession();
    switch (result.status) {
      case SessionCheckStatus.authenticated:
        ref.read(authStateProvider.notifier).markAuthenticated();
        // Connect WebSocket for real-time ride offers (was missing on session restore)
        await ref.read(wsConnectionProvider).connectIfAuthenticated();
        // 2. Check for active ride recovery
        final hasActiveRide = await _checkForActiveRide();
        if (hasActiveRide) {
          return SplashState.activeRide;
        }
        return SplashState.home;
      case SessionCheckStatus.unauthenticated:
        ref.read(authStateProvider.notifier).markUnauthenticated();
        return SplashState.unauthenticated;
      case SessionCheckStatus.transientError:
        // Keep auth state unresolved so the router keeps the user on splash.
        ref.read(authStateProvider.notifier).resetToUnknown();
        return SplashState.transientError;
    }
  }

  /// Checks if the driver has an active ride to recover.
  Future<bool> _checkForActiveRide() async {
    try {
      final rideRepo = ref.read(activeRideRepositoryProvider);
      final activeRide = await rideRepo.getActiveRide();
      return activeRide != null;
    } catch (e) {
      // Non-fatal: if we can't check, default to home screen.
      return false;
    }
  }
}

final splashProvider = AsyncNotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
