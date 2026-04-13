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

/// Result of splash check, includes active ride ID if present.
class SplashResult {
  final SplashState state;
  final String? activeRideId;
  const SplashResult(this.state, [this.activeRideId]);
}

class SplashNotifier extends AsyncNotifier<SplashResult> {
  static bool _running = false;
  static SplashResult? _cachedResult;

  @override
  Future<SplashResult> build() async {
    if (_cachedResult != null) return _cachedResult!;
    if (_running) return const SplashResult(SplashState.loading);
    _running = true;

    final result = await _check();
    _cachedResult = result;
    return result;
  }

  Future<SplashResult> _check() async {
    await Future.delayed(const Duration(seconds: 1));

    final onboarding = ref.read(onboardingServiceProvider);

    if (!onboarding.hasSeenWelcome()) {
      ref.read(authStateProvider.notifier).markUnauthenticated();
      return const SplashResult(SplashState.welcome);
    }

    final authRepo = ref.read(authRepositoryProvider);
    final rideRepo = ref.read(rideRepositoryProvider);

    final result = await authRepo.checkSession();
    switch (result.status) {
      case SessionCheckStatus.authenticated:
        ref.read(authStateProvider.notifier).markAuthenticated();
        RideEntity? active;
        try {
          active = await rideRepo.getActiveRide();
        } catch (_) {
          // Non-fatal: default to home.
        }
        await ref.read(wsConnectionProvider).connectIfAuthenticated();
        return active != null
            ? SplashResult(SplashState.activeRide, active.id)
            : const SplashResult(SplashState.home);
      case SessionCheckStatus.unauthenticated:
        ref.read(authStateProvider.notifier).markUnauthenticated();
        return const SplashResult(SplashState.unauthenticated);
      case SessionCheckStatus.transientError:
        ref.read(authStateProvider.notifier).resetToUnknown();
        return const SplashResult(SplashState.transientError);
    }
  }
}

final splashProvider = AsyncNotifierProvider<SplashNotifier, SplashResult>(
  SplashNotifier.new,
);
