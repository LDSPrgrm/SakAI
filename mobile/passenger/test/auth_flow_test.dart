import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/app/passenger_app.dart';
import 'package:passenger/app/providers.dart';
import 'package:passenger/features/auth/models/auth_exception.dart';
import 'package:passenger/features/auth/models/auth_session.dart';
import 'package:passenger/features/auth/models/session_check_result.dart';
import 'package:passenger/features/auth/repositories/auth_repository.dart';
import 'package:passenger/features/auth/views/welcome_screen.dart';
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

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._storage);

  final TokenStorage _storage;
  bool failNextLogin = false;
  bool failNextRegister = false;
  bool failLogout = false;
  String? lastLogoutToken;
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
    if (failNextRegister) {
      throw AuthException(userMessage: 'Email already exists');
    }
    return AuthSession(
      accessToken: 'test-access-reg',
      refreshToken: 'test-refresh-reg',
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
  Future<void> logout({required String refreshToken}) async {
    lastLogoutToken = refreshToken;
    if (failLogout) {
      throw AuthException(userMessage: 'Logout failed');
    }
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

class _FakeWsConnectionManager implements WsConnectionManager {
  @override
  Future<void> connectIfAuthenticated() async {
    // No-op for tests
  }

  @override
  Future<void> disconnect() async {
    // No-op for tests
  }

  @override
  bool get isConnected => false;
}

class _FakeOnboardingService implements OnboardingService {
  bool seenWelcome = false;

  @override
  bool hasSeenWelcome() => seenWelcome;

  @override
  Future<void> markWelcomeComplete() async {
    seenWelcome = true;
  }
}

class _FakeHomeNotifier extends HomeNotifier {
  @override
  HomeState build() => const HomeState(status: HomeStatus.idle);

  @override
  Future<void> initLocation() async {
    state = state.copyWith(
      pickup: RideLocation(lat: 0, lng: 0, address: 'Current Location'),
    );
  }
}

void main() {
  late _FakeAuthRepository authRepo;
  late FakeTokenStorage tokenStorage;
  late _FakeOnboardingService onboardingService;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  setUp(() {
    tokenStorage = FakeTokenStorage();
    authRepo = _FakeAuthRepository(tokenStorage);
    onboardingService = _FakeOnboardingService();
  });

  Widget createTestWidget({bool seenWelcome = true}) {
    onboardingService.seenWelcome = seenWelcome;
    return ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(tokenStorage),
        authRepositoryProvider.overrideWithValue(authRepo),
        rideRepositoryProvider.overrideWithValue(_FakeRideRepository()),
        onboardingServiceProvider.overrideWith((ref) => onboardingService),
        homeNotifierProvider.overrideWith(() => _FakeHomeNotifier()),
        wsConnectionProvider.overrideWithValue(_FakeWsConnectionManager()),
      ],
      child: const PassengerApp(),
    );
  }

  group('Auth Flow Tests', () {
    testWidgets('successful login flow persists session', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_email')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password')),
        'password123',
      );

      await tester.tap(find.byKey(const Key('login_submit')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('Saan kayo pupunta?'), findsOneWidget);
      expect(await tokenStorage.hasToken(), isTrue);
      expect(await tokenStorage.getAccessToken(), 'test-access');
    });

    testWidgets('session persists across app restarts', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tokenStorage.save(
        accessToken: 'saved-token',
        refreshToken: 'refresh-token',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.textContaining('Saan kayo pupunta?'), findsOneWidget);
    });

    testWidgets('unauthenticated first launch is redirected to welcome', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(createTestWidget(seenWelcome: false));
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.textContaining('Go Anywhere'), findsOneWidget);
    });

    testWidgets('transient session error shows splash retry UI', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      authRepo.overrideSessionCheckResult =
          const SessionCheckResult.transientError(
            reason: SessionCheckFailureReason.network,
          );

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();

      expect(find.text('Could not connect to server.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('failed login shows error message', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      onboardingService.seenWelcome = true;
      authRepo.failNextLogin = true;
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_email')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_submit')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password'), findsOneWidget);
    });

    testWidgets('navigate to register and back to login', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Create account'), findsOneWidget);
      expect(find.byKey(const Key('register_name')), findsOneWidget);

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Welcome back'), findsOneWidget);
    });

    testWidgets('successful registration flow persists tokens', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('register_name')),
        'Test User',
      );
      await tester.enterText(
        find.byKey(const Key('register_email')),
        'new@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('register_password')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('register_submit')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('Saan kayo pupunta?'), findsOneWidget);
      expect(await tokenStorage.hasToken(), isTrue);
      expect(await tokenStorage.getAccessToken(), 'test-access-reg');
    });

    testWidgets('runtime session invalidation routes to login', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tokenStorage.save(
        accessToken: 'saved-token',
        refreshToken: 'refresh-token',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.textContaining('Saan kayo pupunta?'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PassengerApp)),
      );
      container
          .read(authStateProvider.notifier)
          .markUnauthenticated(forceLogin: true);
      await tester.pumpAndSettle();

      expect(find.textContaining('Welcome back'), findsOneWidget);
      expect(find.byKey(const Key('login_email')), findsOneWidget);
    });

    group('Logout', () {
      testWidgets('logging out clears session and redirects to login', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tokenStorage.save(
          accessToken: 'saved-token',
          refreshToken: 'refresh-token',
          expiresAt: DateTime.now().add(const Duration(days: 1)),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(find.textContaining('Saan kayo pupunta?'), findsOneWidget);

        // Open the drawer to reveal the logout button
        await tester.tap(find.byIcon(Icons.menu).first);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.logout).first);
        await tester.pumpAndSettle();

        expect(authRepo.lastLogoutToken, 'refresh-token');
        expect(await tokenStorage.hasToken(), isFalse);
        expect(find.textContaining('Welcome back'), findsOneWidget);
      });

      testWidgets('logout still clears local session when API call fails', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        authRepo.failLogout = true;
        await tokenStorage.save(
          accessToken: 'saved-token',
          refreshToken: 'refresh-token',
          expiresAt: DateTime.now().add(const Duration(days: 1)),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Open the drawer to reveal the logout button
        await tester.tap(find.byIcon(Icons.menu).first);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.logout).first);
        await tester.pumpAndSettle();

        expect(authRepo.lastLogoutToken, 'refresh-token');
        expect(await tokenStorage.hasToken(), isFalse);
        expect(find.byKey(const Key('login_email')), findsOneWidget);
      });
    });
  });
}
