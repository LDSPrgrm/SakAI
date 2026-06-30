import '../models/auth_session.dart';
import '../models/session_check_result.dart';

/// Port for sign-in and future auth operations (Clean Architecture: domain boundary).
abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });

  /// Checks whether a usable session exists.
  Future<SessionCheckResult> checkSession();

  /// Best-effort server-side token invalidation for explicit logout.
  Future<void> logout({required String refreshToken});

  /// Deletes the user account permanently.
  Future<void> deleteAccount();
}
