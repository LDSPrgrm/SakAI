import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import '../../ride/repositories/ride_repository.dart';
import '../../../app/providers.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum SplashState { loading, unauthenticated, home, activeRide }

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SplashNotifier extends AsyncNotifier<SplashState> {
  @override
  Future<SplashState> build() => _check();

  Future<SplashState> _check() async {
    final authRepo = ref.read(authRepositoryProvider);
    final rideRepo = ref.read(rideRepositoryProvider);
    return _resolve(authRepo, rideRepo);
  }

  static Future<SplashState> _resolve(
    AuthRepository authRepo,
    RideRepository rideRepo,
  ) async {
    // 1. Validate stored session via GET /users/me (performed inside repository).
    final valid = await authRepo.hasValidSession();
    if (!valid) return SplashState.unauthenticated;

    // 2. Check for an in-progress ride.
    final active = await rideRepo.getActiveRide();
    return active != null ? SplashState.activeRide : SplashState.home;
  }
}

final splashProvider = AsyncNotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
