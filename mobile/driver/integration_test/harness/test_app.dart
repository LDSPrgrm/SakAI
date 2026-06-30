import 'package:driver/app/driver_app.dart';
import 'package:driver/app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'fakes.dart';

class DriverTestHarness {
  DriverTestHarness({this.seenWelcome = true})
      : tokenStorage = FakeTokenStorage(),
        onboardingService = FakeOnboardingService()..seenWelcome = seenWelcome,
        driverRepository = FakeDriverRepository(),
        activeRideRepository = FakeActiveRideRepository() {
    authRepository = FakeDriverAuthRepository(tokenStorage);
  }

  final FakeTokenStorage tokenStorage;
  final FakeOnboardingService onboardingService;
  final FakeDriverRepository driverRepository;
  final FakeActiveRideRepository activeRideRepository;
  late final FakeDriverAuthRepository authRepository;
  bool seenWelcome;

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(tokenStorage),
        authRepositoryProvider.overrideWithValue(authRepository),
        driverRepositoryProvider.overrideWithValue(driverRepository),
        activeRideRepositoryProvider.overrideWithValue(activeRideRepository),
        onboardingServiceProvider.overrideWith((ref) => onboardingService),
      ],
      child: const DriverApp(),
    );
  }

  static Future<void> ensureDotenv() async {
    if (dotenv.isInitialized) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env optional in tests.
    }
  }
}
