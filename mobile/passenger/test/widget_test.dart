import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:passenger/app/passenger_app.dart';
import 'package:passenger/domain/auth_repository.dart';
import 'package:passenger/domain/auth_session.dart';
import 'package:passenger/domain/ride_repository.dart';
import 'package:sakai_shared/sakai_shared.dart';

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
}

class _FakeRideRepository implements RideRepository {
  @override
  Future<RideEntity> requestRide({
    required RideLocation origin,
    required RideLocation destination,
    String? notes,
    required String idempotencyKey,
  }) async {
    return RideEntity(
      id: 'fake-ride',
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
  Future<void> cancelRide(String rideId) async {}
}

void main() {
  testWidgets('login screen shows rider auth chrome', (WidgetTester tester) async {
    await tester.pumpWidget(
      PassengerApp(
        authRepository: _FakeAuthRepository(),
        rideRepository: _FakeRideRepository(),
      ),
    );
    expect(find.textContaining('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_password')), findsOneWidget);
  });
}
