import '../models/auth_session.dart';

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
  });

  /// Returns true if a valid session exists.
  Future<bool> hasValidSession();
}
