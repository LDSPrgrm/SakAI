import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/onboarding_service.dart' show sharedPreferencesProvider;

/// Persists the user's chosen [ThemeMode] (System/Light/Dark) across app
/// restarts. Shared between the passenger and driver apps so both read and
/// write the same `theme_mode` preference key and default (system).
///
/// Unlike [SosSafetyPrefsNotifier] this reads [SharedPreferences]
/// synchronously in [build] rather than hydrating asynchronously: both apps
/// already await `SharedPreferences.getInstance()` in `main()` before
/// `runApp` and override [sharedPreferencesProvider] with the loaded
/// instance, so the persisted value is available before the first frame.
class ThemeModeController extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _fromStored(prefs.getString(_key)) ?? ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, _toStored(mode));
  }

  static ThemeMode? _fromStored(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  static String _toStored(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
