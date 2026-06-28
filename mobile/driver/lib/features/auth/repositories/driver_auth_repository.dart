import '../models/auth_session.dart';
import '../models/session_check_result.dart';

/// Domain boundary for driver authentication.
abstract class DriverAuthRepository {
  Future<AuthSession> login({required String email, required String password});

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
  });

  /// Checks whether a usable session exists.
  Future<SessionCheckResult> checkSession();

  /// Best-effort server-side token invalidation for explicit logout.
  Future<void> logout({required String refreshToken});

  /// Deletes the user account permanently.
  Future<void> deleteAccount();
}
