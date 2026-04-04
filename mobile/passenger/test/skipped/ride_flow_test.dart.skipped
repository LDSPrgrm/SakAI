// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:passenger/app/passenger_app.dart';
// import 'package:passenger/app/providers.dart';
// import 'package:passenger/features/auth/models/auth_session.dart';
// import 'package:passenger/features/auth/repositories/auth_repository.dart';
// import 'package:passenger/features/home/view_models/home_notifier.dart';
// import 'package:passenger/features/ride/repositories/ride_repository.dart';
// import 'package:sakai_shared/sakai_shared.dart';
// import 'package:flutter/src/painting/debug.dart';

// // ---------------------------------------------------------------------------
// // Fakes
// // ---------------------------------------------------------------------------

// class _MockHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return _MockHttpClient();
//   }
// }

// class _MockHttpClient extends Fake implements HttpClient {
//   @override
//   Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
//   @override
//   set autoUncompress(bool value) {}
// }

// class _MockHttpClientRequest extends Fake implements HttpClientRequest {
//   @override
//   Future<HttpClientResponse> close() async => _MockHttpClientResponse();
// }

// class _MockHttpClientResponse extends Fake implements HttpClientResponse {
//   @override
//   int get statusCode => 200;
//   @override
//   int get contentLength => 0;
//   @override
//   HttpClientResponseCompressionState get compressionState =>
//       HttpClientResponseCompressionState.notCompressed;

//   @override
//   HttpHeaders get headers => _MockHttpHeaders();

//   @override
//   StreamSubscription<List<int>> listen(
//     void Function(List<int> event)? onData, {
//     Function? onError,
//     void Function()? onDone,
//     bool? cancelOnError,
//   }) {
//     return Stream<List<int>>.fromIterable([
//       // Minimal valid GIF to satisfy image decoder
//       [
//         0x47,
//         0x49,
//         0x46,
//         0x38,
//         0x39,
//         0x61,
//         0x01,
//         0x00,
//         0x01,
//         0x00,
//         0x80,
//         0x00,
//         0x00,
//         0xff,
//         0xff,
//         0xff,
//         0x00,
//         0x00,
//         0x00,
//         0x2c,
//         0x00,
//         0x00,
//         0x00,
//         0x00,
//         0x01,
//         0x00,
//         0x01,
//         0x00,
//         0x00,
//         0x02,
//         0x02,
//         0x44,
//         0x01,
//         0x00,
//         0x3b,
//       ],
//     ]).listen(
//       onData,
//       onError: onError,
//       onDone: onDone,
//       cancelOnError: cancelOnError,
//     );
//   }
// }

// class _MockHttpHeaders extends Fake implements HttpHeaders {
//   @override
//   void forEach(void Function(String name, List<String> values) f) {}
// }

// class _FakeAuthRepository implements AuthRepository {
//   @override
//   Future<AuthSession> login({
//     required String email,
//     required String password,
//   }) async {
//     return AuthSession(
//       accessToken: 'test-access',
//       refreshToken: 'test-refresh',
//       accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
//     );
//   }

//   @override
//   Future<AuthSession> register({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     return AuthSession(
//       accessToken: 'test-access-reg',
//       refreshToken: 'test-refresh-reg',
//       accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
//     );
//   }

//   @override
//   Future<bool> hasValidSession() async => true;
// }

// class _FakeRideRepository implements RideRepository {
//   bool cancelCalled = false;
//   bool failCancel = false;

//   @override
//   Future<RideEntity> requestRide({
//     required RideLocation origin,
//     required RideLocation destination,
//     String? notes,
//     required String idempotencyKey,
//   }) async {
//     // Add delay for state changes
//     await Future.delayed(const Duration(milliseconds: 100));
//     return RideEntity(
//       id: 'test-ride-id',
//       status: RideState.requested,
//       origin: origin,
//       destination: destination,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );
//   }

//   @override
//   Future<RideEntity?> getActiveRide() async => null;

//   @override
//   Future<void> cancelRide(String rideId) async {
//     cancelCalled = true;
//     // Add delay so the test can "see" the isCancelling state
//     await Future.delayed(const Duration(milliseconds: 200));
//     if (failCancel) {
//       throw Exception('Cancel failed');
//     }
//   }
// }

// class _FakeOnboardingService implements OnboardingService {
//   @override
//   bool hasSeenWelcome() => true;
//   @override
//   Future<void> markWelcomeComplete() async {}
// }

// // ---------------------------------------------------------------------------
// // Tests
// // ---------------------------------------------------------------------------

// class _FakeHomeNotifier extends HomeNotifier {
//   @override
//   HomeState build() => const HomeState(status: HomeStatus.idle);

//   @override
//   Future<void> initLocation() async {
//     state = state.copyWith(
//       pickup: RideLocation(lat: 0, lng: 0, address: 'Current Location'),
//     );
//   }
// }

// void main() {
//   // Global override for network images
//   HttpOverrides.global = _MockHttpOverrides();
//   debugNetworkImageHttpClientProvider = () => _MockHttpClient();

//   late _FakeRideRepository rideRepo;

//   setUp(() {
//     rideRepo = _FakeRideRepository();
//   });

//   tearDown(() {
//     debugNetworkImageHttpClientProvider = null;
//   });

//   Widget createTestWidget() {
//     return ProviderScope(
//       overrides: [
//         authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
//         rideRepositoryProvider.overrideWithValue(rideRepo),
//         onboardingServiceProvider.overrideWithValue(_FakeOnboardingService()),
//         homeNotifierProvider.overrideWith(() => _FakeHomeNotifier()),
//         authStateProvider.overrideWith(_FakeAuthState.new),
//       ],
//       child: const PassengerApp(),
//     );
//   }

//   group('Ride Flow Tests', () {
//     testWidgets('WaitingScreen displays and handles cancellation', (
//       WidgetTester tester,
//     ) async {
//       await HttpOverrides.runZoned(() async {
//         await tester.binding.setSurfaceSize(const Size(800, 1600));
//         await tester.pumpWidget(createTestWidget());

//         // Wait for SplashNotifier delay (1000ms)
//         await tester.pump(const Duration(milliseconds: 1100));
//         await tester.pumpAndSettle();

//         final element = tester.element(find.byType(PassengerApp));
//         final container = ProviderScope.containerOf(element);

//         final destination = RideLocation(lat: 0, lng: 0, address: 'Dest');

//         // Trigger navigation via state
//         container
//             .read(homeNotifierProvider.notifier)
//             .setDestination(destination);
//         await container.read(homeNotifierProvider.notifier).requestRide();

//         // Pump multiple times to process async state and navigation
//         await tester.pump();
//         await tester.pump(const Duration(milliseconds: 500));
//         await tester.pump();

//         // Verify we are on Waiting screen
//         expect(find.text('Finding your driver…'), findsOneWidget);
//         expect(find.text('Cancel Ride'), findsOneWidget);

//         // Tap cancel
//         await tester.tap(find.text('Cancel Ride'));
//         await tester.pump(); // Start cancelling state
//         await tester.pump(
//           const Duration(milliseconds: 100),
//         ); // Let the UI update
//         expect(find.textContaining('Cancelling'), findsOneWidget);

//         // Animation might still be going, use pump to wait for cancellation to finish
//         await tester.pump(const Duration(seconds: 1));
//         await tester.pumpAndSettle(); // Finish pop and potential settles

//         // Should be back on home screen
//         expect(rideRepo.cancelCalled, isTrue);
//         expect(find.textContaining('Saan kayo pupunta?'), findsOneWidget);
//       }, createHttpClient: (_) => _MockHttpClient());
//     });

//     testWidgets('WaitingScreen shows error on failed cancellation', (
//       WidgetTester tester,
//     ) async {
//       await tester.binding.setSurfaceSize(const Size(800, 1200));
//       rideRepo.failCancel = true;

//       await tester.pumpWidget(createTestWidget());

//       // Wait for SplashNotifier delay (1000ms)
//       await tester.pump(const Duration(milliseconds: 1100));
//       await tester.pumpAndSettle();

//       final container = ProviderScope.containerOf(
//         tester.element(find.byType(PassengerApp)),
//       );
//       final destination = RideLocation(lat: 0, lng: 0, address: 'Dest');

//       container.read(homeNotifierProvider.notifier).setDestination(destination);
//       await container.read(homeNotifierProvider.notifier).requestRide();
//       await tester.pump();
//       await tester.pump(const Duration(milliseconds: 500));

//       await tester.tap(find.text('Cancel Ride'));
//       await tester.pump();
//       await tester.pump(const Duration(seconds: 1));

//       expect(find.text('Could not cancel. Try again.'), findsOneWidget);
//       expect(find.text('Finding your driver…'), findsOneWidget);
//     });

//     group('Profile Flow Tests', () {
//       testWidgets('Logout from ProfileScreen', (WidgetTester tester) async {
//         await HttpOverrides.runZoned(() async {
//           await tester.binding.setSurfaceSize(const Size(800, 1600));
//           await tester.pumpWidget(createTestWidget());

//           // Wait for SplashNotifier delay (1000ms)
//           await tester.pump(const Duration(milliseconds: 1100));
//           await tester.pumpAndSettle();

//           // Navigate to Profile tab
//           await tester.tap(find.byIcon(Icons.person_outline));
//           await tester.pumpAndSettle();

//           expect(find.text('Profile'), findsAtLeast(1));

//           await tester.tap(find.byIcon(Icons.logout));
//           await tester.pumpAndSettle();

//           expect(find.textContaining('Welcome back'), findsOneWidget);
//         }, createHttpClient: (_) => _MockHttpClient());
//       });
//     });
//     group('Image Loading', () {
//       testWidgets('Network image does not crash', (WidgetTester tester) async {
//         await tester.binding.setSurfaceSize(const Size(800, 1200));
//         await tester.pumpWidget(createTestWidget());

//         // Wait for SplashNotifier delay (1000ms)
//         await tester.pump(const Duration(milliseconds: 1100));
//         await tester.pumpAndSettle();
//       });
//     });
//   });
// }

// class _FakeAuthState extends AuthState {
//   @override
//   bool build() => true;
// }
