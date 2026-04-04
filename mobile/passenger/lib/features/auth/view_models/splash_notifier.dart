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
  Future<SplashState> build() => _check();

  Future<SplashState> _check() async {
    await Future.delayed(const Duration(seconds: 1));

    final onboarding = ref.read(onboardingServiceProvider);

    // 1. First launch should always show onboarding welcome.
    if (!onboarding.hasSeenWelcome()) {
      ref.read(authStateProvider.notifier).markUnauthenticated();
      return SplashState.welcome;
    }

    final authRepo = ref.read(authRepositoryProvider);
    final rideRepo = ref.read(rideRepositoryProvider);

    final result = await authRepo.checkSession();
    switch (result.status) {
      case SessionCheckStatus.authenticated:
        ref.read(authStateProvider.notifier).markAuthenticated();
        final active = await rideRepo.getActiveRide();
        return active != null ? SplashState.activeRide : SplashState.home;
      case SessionCheckStatus.unauthenticated:
        ref.read(authStateProvider.notifier).markUnauthenticated();
        return SplashState.unauthenticated;
      case SessionCheckStatus.transientError:
        // Keep auth state unresolved so the router keeps the user on splash.
        ref.read(authStateProvider.notifier).resetToUnknown();
        return SplashState.transientError;
    }
  }
}

final splashProvider = AsyncNotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
