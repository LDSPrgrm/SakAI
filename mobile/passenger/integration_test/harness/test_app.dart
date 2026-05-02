import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passenger/app/passenger_app.dart';
import 'package:passenger/app/providers.dart';
import 'package:passenger/features/home/view_models/home_notifier.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'fakes.dart';

class TestHarness {
  TestHarness({this.seenWelcome = true})
      : tokenStorage = FakeTokenStorage(),
        onboardingService = FakeOnboardingService()..seenWelcome = seenWelcome,
        wsConnection = FakeWsConnectionManager(),
        rideRepository = FakeRideRepository() {
    authRepository = FakeAuthRepository(tokenStorage);
  }

  final FakeTokenStorage tokenStorage;
  final FakeOnboardingService onboardingService;
  final FakeWsConnectionManager wsConnection;
  final FakeRideRepository rideRepository;
  late final FakeAuthRepository authRepository;
  bool seenWelcome;

  Widget buildApp({bool useFakeHomeNotifier = false}) {
    return ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(tokenStorage),
        authRepositoryProvider.overrideWithValue(authRepository),
        rideRepositoryProvider.overrideWithValue(rideRepository),
        onboardingServiceProvider.overrideWith((ref) => onboardingService),
        wsConnectionProvider.overrideWithValue(wsConnection),
        if (useFakeHomeNotifier)
          homeNotifierProvider.overrideWith(() => FakeHomeNotifier()),
      ],
      child: const PassengerApp(),
    );
  }

  static Future<void> ensureDotenv() async {
    if (dotenv.isInitialized) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env is optional in tests — leave dotenv unloaded; PassengerApp does
      // not directly read it during integration_test setup.
    }
  }
}
