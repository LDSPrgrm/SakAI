import 'package:passenger/app/providers.dart';
import 'package:passenger/features/auth/models/auth_exception.dart';
import 'package:passenger/features/auth/models/auth_session.dart';
import 'package:passenger/features/auth/models/session_check_result.dart';
import 'package:passenger/features/auth/repositories/auth_repository.dart';
import 'package:passenger/features/home/models/ride_type_option.dart';
import 'package:passenger/features/home/view_models/home_notifier.dart';
import 'package:passenger/features/ride/repositories/ride_repository.dart';
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

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._storage);

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
      accessToken: 'integration-access',
      refreshToken: 'integration-refresh',
      accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (failNextRegister) {
      throw AuthException(userMessage: 'Email already exists');
    }
    return AuthSession(
      accessToken: 'integration-access-reg',
      refreshToken: 'integration-refresh-reg',
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

class FakeRideRepository implements RideRepository {
  RideEntity? lastRequested;

  @override
  Future<RideEntity> requestRide({
    required RideLocation origin,
    required RideLocation destination,
    String? notes,
    required String idempotencyKey,
    VehicleType? rideType,
    String? paymentMethod,
  }) async {
    final ride = RideEntity(
      id: 'integration-ride-1',
      passengerId: 'integration-passenger',
      status: RideState.requested,
      origin: origin,
      destination: destination,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    lastRequested = ride;
    return ride;
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

class FakeWsConnectionManager implements WsConnectionManager {
  @override
  Future<void> connectIfAuthenticated() async {}

  @override
  Future<void> disconnect() async {}

  @override
  bool get isConnected => false;
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

/// Stand-in for [HomeNotifier] that bypasses Geolocator and the network
/// nearby-driver poller so multi-screen flow tests can drive the booking
/// state machine deterministically.
class FakeHomeNotifier extends HomeNotifier {
  static const _fakePickup = RideLocation(
    lat: 14.5995,
    lng: 120.9842,
    address: '123 Test Street, Manila',
  );

  static final _fakeOptions = <RideTypeOption>[
    const RideTypeOption(
      type: VehicleType.motorcycle,
      estimatedFare: 65,
      estimatedDuration: Duration(minutes: 10),
      availableDrivers: 3,
    ),
    const RideTypeOption(
      type: VehicleType.car,
      estimatedFare: 120,
      estimatedDuration: Duration(minutes: 15),
      availableDrivers: 2,
    ),
  ];

  @override
  HomeState build() => const HomeState(
        status: HomeStatus.idle,
        pickup: _fakePickup,
      );

  @override
  Future<void> initLocation() async {
    state = state.copyWith(pickup: _fakePickup);
  }

  @override
  void setDestination(RideLocation destination) {
    state = state.copyWith(
      status: HomeStatus.destinationSet,
      pickup: _fakePickup,
      destination: destination,
      rideTypeOptions: _fakeOptions,
      clearError: true,
    );
  }

  @override
  Future<RideEntity?> requestRide() async {
    if (state.destination == null) return null;
    state = state.copyWith(status: HomeStatus.requesting, clearError: true);
    final ride = RideEntity(
      id: 'integration-ride-1',
      passengerId: 'integration-passenger',
      status: RideState.requested,
      origin: state.pickup!,
      destination: state.destination!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(
      createdRide: ride,
      status: HomeStatus.destinationSet,
    );
    return ride;
  }
}
