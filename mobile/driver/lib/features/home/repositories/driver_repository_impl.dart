import '../models/driver_session.dart';

/// Data-layer placeholder implementation.
///
/// For now the driver app is UI-only, but this file establishes the expected
/// `repositories/` layer boundary for future API calls + DTO mapping.
class DriverRepositoryImpl {
  Future<DriverSession> loadSession() async {
    return const DriverSession(vehiclePlate: 'ABC 1234');
  }
}

