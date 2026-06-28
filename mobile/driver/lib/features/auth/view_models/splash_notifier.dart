import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/e2e_mode_stub.dart'
    if (dart.library.js_interop) '../../../app/e2e_mode_web.dart';
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

    debugPrint('[D-Splash] Starting _check');

    // Playwright bypass: skip backend call only when the ?sakai-e2e=true URL
    // flag is present. integration_test specs use the real splash flow with
    // fake repositories, so they should NOT take this path.
    if (kIsWeb && _isPlaywrightMode()) {
      debugPrint('[D-Splash] Playwright mode detected — skipping backend check');
      final onboardingForE2E = ref.read(onboardingServiceProvider);
      if (!onboardingForE2E.hasSeenWelcome()) {
        ref.read(authStateProvider.notifier).markUnauthenticated();
        return SplashState.welcome;
      }
      ref.read(authStateProvider.notifier).markUnauthenticated();
      return SplashState.unauthenticated;
    }

    final onboarding = ref.read(onboardingServiceProvider);
    final hasSeenWelcome = onboarding.hasSeenWelcome();
    debugPrint('[D-Splash] hasSeenWelcome: $hasSeenWelcome');

    // 1. First launch should always show onboarding welcome.
    if (!hasSeenWelcome) {
      debugPrint('[D-Splash] Routing to welcome screen');
      ref.read(authStateProvider.notifier).markUnauthenticated();
      return SplashState.welcome;
    }

    final authRepo = ref.read(authRepositoryProvider);

    debugPrint('[D-Splash] Checking session...');
    final result = await authRepo.checkSession();
    debugPrint('[D-Splash] Session check result: ${result.status}');
    switch (result.status) {
      case SessionCheckStatus.authenticated:
        debugPrint('[D-Splash] Authenticated, marking and checking active ride...');
        ref.read(authStateProvider.notifier).markAuthenticated();
        // Connect WebSocket in the background. 
        // We don't want to block the splash screen transition for the handshake.
        unawaited(ref.read(wsConnectionProvider).connectIfAuthenticated());
        // 2. Check for active ride recovery
        final hasActiveRide = await _checkForActiveRide();
        debugPrint('[D-Splash] hasActiveRide: $hasActiveRide');
        if (hasActiveRide) {
          return SplashState.activeRide;
        }
        return SplashState.home;
      case SessionCheckStatus.unauthenticated:
        debugPrint('[D-Splash] Unauthenticated');
        ref.read(authStateProvider.notifier).markUnauthenticated();
        return SplashState.unauthenticated;
      case SessionCheckStatus.transientError:
        debugPrint('[D-Splash] Transient error');
        // Keep auth state unresolved so the router keeps the user on splash.
        ref.read(authStateProvider.notifier).resetToUnknown();
        return SplashState.transientError;
    }
  }

  /// Checks if the driver has an active ride to recover.
  Future<bool> _checkForActiveRide() async {
    debugPrint('[D-Splash] _checkForActiveRide: querying...');
    try {
      final rideRepo = ref.read(activeRideRepositoryProvider);
      final activeRide = await rideRepo
          .getActiveRide()
          .timeout(const Duration(seconds: 5));
      debugPrint('[D-Splash] _checkForActiveRide: result=${activeRide?.id}');
      return activeRide != null;
    } catch (e) {
      // Non-fatal: if we can't check, default to home screen.
      debugPrint('[D-Splash] _checkForActiveRide failed (non-fatal): $e');
      return false;
    }
  }

  /// Returns true when the app is opened with `?sakai-e2e=true` query param.
  /// Only relevant on Flutter Web; always returns false on other platforms.
  static bool _isPlaywrightMode() {
    try {
      return isPlaywrightMode();
    } catch (_) {
      return false;
    }
  }
}

final splashProvider = AsyncNotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
