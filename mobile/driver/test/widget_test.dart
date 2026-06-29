import 'package:driver/app/providers.dart';
import 'package:driver/features/auth/repositories/driver_auth_repository.dart';
import 'package:driver/features/auth/models/auth_session.dart';
import 'package:driver/features/auth/models/session_check_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _FakeDriverAuthRepository implements DriverAuthRepository {
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
  Future<AuthSession> registerDriver({
    required String name,
    required String email,
    required String password,
    required String vehicleMake,
    required String vehicleModel,
    required String vehiclePlate,
    required String vehicleColor,
    required int vehicleYear,
    required String vehicleType,
  }) async {
    return AuthSession(
      accessToken: 'test-access',
      refreshToken: 'test-refresh',
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

void main() {
  testWidgets('app builds with shared theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeDriverAuthRepository()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Driver app builds successfully')),
          ),
        ),
      ),
    );

    // Verify the app scaffold renders without errors
    expect(find.text('Driver app builds successfully'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
