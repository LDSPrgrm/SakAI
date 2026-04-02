import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:passenger/app/passenger_app.dart';
import 'package:passenger/domain/auth_repository.dart';
import 'package:passenger/domain/auth_session.dart';

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

void main() {
  testWidgets('login screen shows rider auth chrome', (WidgetTester tester) async {
    await tester.pumpWidget(
      PassengerApp(authRepository: _FakeAuthRepository()),
    );
    expect(find.textContaining('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_password')), findsOneWidget);
  });
}
