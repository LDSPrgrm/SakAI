import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'sharedPreferencesProvider must be overridden at the root',
  );
});

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingService(prefs);
});

final hasSeenWelcomeProvider = Provider<bool>((ref) {
  final service = ref.watch(onboardingServiceProvider);
  return service.hasSeenWelcome();
});

class OnboardingService {
  final SharedPreferences _prefs;
  static const _keyHasSeenWelcome = 'hasSeenWelcome';

  OnboardingService(this._prefs);

  bool hasSeenWelcome() {
    return _prefs.getBool(_keyHasSeenWelcome) ?? false;
  }

  Future<void> markWelcomeComplete() async {
    await _prefs.setBool(_keyHasSeenWelcome, true);
  }
}
