import 'package:driver/features/active_ride/repositories/active_ride_repository.dart';
import 'package:driver/features/auth/models/auth_exception.dart';
import 'package:driver/features/auth/models/auth_session.dart';
import 'package:driver/features/auth/models/session_check_result.dart';
import 'package:driver/features/auth/repositories/driver_auth_repository.dart';
import 'package:driver/features/home/repositories/driver_repository.dart';
import 'package:sakai_shared/sakai_shared.dart';

class FakeTokenStorage extends TokenStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    _data['access'] = accessToken;
    _data['refresh'] = refreshToken;
    _data['expiry'] = expiresAt.toIso8601String();
  }

  @override
  Future<void> saveAccessToken(String token) async => _data['access'] = token;

  @override
  Future<void> saveRefreshToken(String token) async => _data['refresh'] = token;

  @override
  Future<void> saveExpiry(DateTime expiresAt) async =>
      _data['expiry'] = expiresAt.toIso8601String();

  @override
  Future<String?> getAccessToken() async => _data['access'];

  @override
  Future<String?> getRefreshToken() async => _data['refresh'];

  @override
  Future<DateTime?> getExpiry() async =>
      _data['expiry'] == null ? null : DateTime.parse(_data['expiry']!);

  @override
  Future<bool> hasToken() async => _data.containsKey('access');

  @override
  Future<void> clear() async => _data.clear();
}

class FakeDriverAuthRepository implements DriverAuthRepository {
  FakeDriverAuthRepository(this._storage);

  final TokenStorage _storage;
  bool failNextLogin = false;
  bool failNextRegister = false;
  SessionCheckResult? overrideSessionCheckResult;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (failNextLogin) {
      throw AuthException(userMessage: 'Invalid email or password');
    }
    return AuthSession(
      accessToken: 'integration-driver-access',
      refreshToken: 'integration-driver-refresh',
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
    if (failNextRegister) {
      throw AuthException(userMessage: 'Email already exists');
    }
    return AuthSession(
      accessToken: 'integration-driver-access-reg',
      refreshToken: 'integration-driver-refresh-reg',
      accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<SessionCheckResult> checkSession() async {
    if (overrideSessionCheckResult != null) {
      return overrideSessionCheckResult!;
    }
    final hasToken = await _storage.hasToken();
    return hasToken
        ? const SessionCheckResult.authenticated()
        : const SessionCheckResult.unauthenticated();
  }

  @override
  Future<void> logout({required String refreshToken}) async {}

  @override
  Future<void> deleteAccount() async {}
}

class FakeDriverRepository implements DriverRepository {
  bool isOnline = false;
  int locationUpdateCount = 0;

  @override
  Future<void> goOnline() async {
    isOnline = true;
  }

  @override
  Future<void> goOffline() async {
    isOnline = false;
  }

  @override
  Future<void> updateLocation(double lat, double lng, {double? heading}) async {
    locationUpdateCount++;
  }

  @override
  Future<RideResponse?> getIncomingRide() async => null;
}

class FakeActiveRideRepository implements ActiveRideRepository {
  @override
  Future<RideResponse?> getActiveRide() async => null;

  @override
  Future<void> arriveAtPickup(String rideId, LatLng driverLocation) async {}

  @override
  Future<void> startRide(String rideId) async {}

  @override
  Future<void> completeRide(String rideId, LatLng driverLocation) async {}

  @override
  Future<void> cancelRide(String rideId, {String? reasonText}) async {}
}

class FakeOnboardingService implements OnboardingService {
  bool seenWelcome = true;

  @override
  bool hasSeenWelcome() => seenWelcome;

  @override
  Future<void> markWelcomeComplete() async {
    seenWelcome = true;
  }
}
