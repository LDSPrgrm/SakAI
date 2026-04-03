import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/providers.dart';

enum SplashState { loading, unauthenticated, home, welcome }

class SplashNotifier extends AsyncNotifier<SplashState> {
  @override
  Future<SplashState> build() => _check();

  Future<SplashState> _check() async {
    final onboarding = ref.read(onboardingServiceProvider);

    // 1. Show welcome carousel on first launch.
    if (!onboarding.hasSeenWelcome()) return SplashState.welcome;

    final authRepo = ref.read(authRepositoryProvider);
    final valid = await authRepo.hasValidSession();
    return valid ? SplashState.home : SplashState.unauthenticated;
  }
}

final splashProvider = AsyncNotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
