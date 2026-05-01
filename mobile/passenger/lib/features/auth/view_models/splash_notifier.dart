import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/providers.dart';
import '../../../app/e2e_mode_stub.dart'
    if (dart.library.js_interop) '../../../app/e2e_mode_web.dart';
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
  @override
  Future<SplashResult> build() async {
    // Rely on Riverpod's built-in caching per ProviderContainer.
    // No static state to avoid cross-test interference.
    return await _check();
  }

  Future<SplashResult> _check() async {
    // Minimal delay for UX in production, can be zero in tests if needed via specialized overrides,
    // but Duration.zero here helps tests run faster while keeping the async check.
    await Future.delayed(Duration.zero);

    debugPrint('[SplashNotifier] Starting _check');

    // E2E bypass: skip backend call when running under Playwright tests.
    // The ?sakai-e2e=true URL param signals a test environment where no backend is available.
    if (kIsWeb && _isE2EMode()) {
      debugPrint('[SplashNotifier] E2E mode detected — skipping backend check');
      final onboardingForE2E = ref.read(onboardingServiceProvider);
      final hasSeenWelcomeForE2E = onboardingForE2E.hasSeenWelcome();
      ref.read(authStateProvider.notifier).markUnauthenticated();
      return hasSeenWelcomeForE2E
          ? const SplashResult(SplashState.unauthenticated)
          : const SplashResult(SplashState.welcome);
    }

    final onboarding = ref.read(onboardingServiceProvider);

    final hasSeenWelcome = onboarding.hasSeenWelcome();
    debugPrint('[SplashNotifier] hasSeenWelcome: $hasSeenWelcome');

    if (!hasSeenWelcome) {
      debugPrint(
        '[SplashNotifier] User has not seen welcome, routing to welcome',
      );
      ref.read(authStateProvider.notifier).markUnauthenticated();
      return const SplashResult(SplashState.welcome);
    }

    debugPrint('[SplashNotifier] Reading repos...');
    final authRepo = ref.read(authRepositoryProvider);
    final rideRepo = ref.read(rideRepositoryProvider);
    debugPrint('[SplashNotifier] Repos read');

    debugPrint('[SplashNotifier] Checking session...');
    final result = await authRepo.checkSession();
    debugPrint('[SplashNotifier] Session check result: ${result.status}');
    switch (result.status) {
      case SessionCheckStatus.authenticated:
        debugPrint('[SplashNotifier] Authenticated, checking active ride');
        // Don't modify auth state until ALL checks pass successfully. This prevents
        // redirect loops that can occur if an API call (like getActiveRide) fails
        // mid-flight and triggers onSessionInvalidated callback.
        RideEntity? active;
        try {
          // Add explicit timeout to avoid blocking splash screen indefinitely.
          active = await rideRepo.getActiveRide().timeout(
            const Duration(seconds: 5),
          );
        } catch (e) {
          // Non-fatal: default to home if check fails or times out.
          debugPrint(
            '[SplashNotifier] Active ride check failed or timed out: $e',
          );
        }
        debugPrint('[SplashNotifier] Active ride result: ${active?.id}');

        // WebSocket connection is a background process.
        // We don't want to block the splash screen for it.
        unawaited(ref.read(wsConnectionProvider).connectIfAuthenticated());

        final resultState = active != null
            ? SplashResult(SplashState.activeRide, active.id)
            : const SplashResult(SplashState.home);

        // Set auth state only after all checks complete. If onSessionInvalidated was
        // triggered during getActiveRide(), it would have already set authState to
        // unauthenticated and cleared tokens - we don't overwrite that.
        final currentAuthState = ref.read(authStateProvider);
        if (currentAuthState.status == AuthStatus.unknown) {
          // No callback was triggered, safe to mark authenticated
          ref.read(authStateProvider.notifier).markAuthenticated();
        }
        return resultState;
      case SessionCheckStatus.unauthenticated:
        debugPrint('[SplashNotifier] Unauthenticated');
        ref.read(authStateProvider.notifier).markUnauthenticated();
        return const SplashResult(SplashState.unauthenticated);
      case SessionCheckStatus.transientError:
        debugPrint('[SplashNotifier] Transient error');
        // Keep auth state unresolved so the router keeps the user on splash.
        ref.read(authStateProvider.notifier).resetToUnknown();
        return const SplashResult(SplashState.transientError);
    }
  }

  /// Returns true when the app is opened with `?sakai-e2e=true` query param.
  /// Only relevant on Flutter Web; always returns false on other platforms.
  static bool _isE2EMode() => isE2EMode();
}

final splashProvider = AsyncNotifierProvider<SplashNotifier, SplashResult>(
  SplashNotifier.new,
);
