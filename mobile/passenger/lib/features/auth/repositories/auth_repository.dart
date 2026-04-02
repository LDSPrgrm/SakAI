import '../models/auth_session.dart';

/// Port for sign-in and future auth operations (Clean Architecture: domain boundary).
abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });
}
