import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:passenger/app/passenger_app.dart';
import 'package:passenger/app/providers.dart';
import 'package:passenger/features/auth/models/auth_session.dart';
import 'package:passenger/features/auth/models/session_check_result.dart';
import 'package:passenger/features/auth/repositories/auth_repository.dart';
import 'package:passenger/features/ride/repositories/ride_repository.dart';
import 'package:sakai_shared/sakai_shared.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return AuthSession(
      accessToken: 'test-access',
      refreshToken: 'test-refresh',
      accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return AuthSession(
      accessToken: 'test-access-reg',
      refreshToken: 'test-refresh-reg',
      accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<SessionCheckResult> checkSession() async =>
      const SessionCheckResult.unauthenticated();

  @override
  Future<void> logout({required String refreshToken}) async {}

  @override
  Future<void> deleteAccount() async {}
}

class _FakeRideRepository implements RideRepository {
  @override
  Future<RideEntity> requestRide({
    required RideLocation origin,
    required RideLocation destination,
    String? notes,
    required String idempotencyKey,
    VehicleType? rideType,
    String? paymentMethod,
  }) async {
    return RideEntity(
      id: 'fake-ride',
      passengerId: 'fake-passenger-id',
      status: RideState.requested,
      origin: origin,
      destination: destination,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<RideEntity?> getActiveRide() async => null;

  @override
  Future<void> cancelRide(
    String rideId, {
    String? reasonCode,
    String? reasonText,
  }) async {}
}

class _FakeOnboardingService implements OnboardingService {
  @override
  bool hasSeenWelcome() => true;
  @override
  Future<void> markWelcomeComplete() async {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    // Prevent the infinite repeat() loop from blocking pumpAndSettle.
    SakaiAnimatedBackdrop.debugDisableAnimations = true;
  });

  tearDown(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = false;
  });

  testWidgets('after splash resolves unauthenticated → shows login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          rideRepositoryProvider.overrideWithValue(_FakeRideRepository()),
          onboardingServiceProvider.overrideWithValue(_FakeOnboardingService()),
        ],
        child: const PassengerApp(),
      ),
    );
    // Let the splash async check resolve.
    await tester.pumpAndSettle();

    expect(find.textContaining('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_password')), findsOneWidget);
  });
}
