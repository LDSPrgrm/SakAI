import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Driver-side mirror of the passenger SOS safety opt-ins. All flags
/// default to OFF per RFC v2 §20 decision 3.
///
/// Kept duplicated rather than shared because the consent text differs
/// (drivers see passenger SOS as inbound, not outbound) and the legal
/// review may split approval between the two apps.
class SosSafetyPrefs {
  const SosSafetyPrefs({
    this.isLoading = true,
    this.ambientAudioOptIn = false,
    this.liveLocationOptIn = false,
    this.photoOptIn = false,
  });

  final bool isLoading;
  final bool ambientAudioOptIn;
  final bool liveLocationOptIn;
  final bool photoOptIn;

  SosSafetyPrefs copyWith({
    bool? isLoading,
    bool? ambientAudioOptIn,
    bool? liveLocationOptIn,
    bool? photoOptIn,
  }) {
    return SosSafetyPrefs(
      isLoading: isLoading ?? this.isLoading,
      ambientAudioOptIn: ambientAudioOptIn ?? this.ambientAudioOptIn,
      liveLocationOptIn: liveLocationOptIn ?? this.liveLocationOptIn,
      photoOptIn: photoOptIn ?? this.photoOptIn,
    );
  }
}

class SosSafetyPrefsNotifier extends Notifier<SosSafetyPrefs> {
  static const _keyAmbient = 'sos_safety_ambient_audio_opt_in';
  static const _keyLocation = 'sos_safety_live_location_opt_in';
  static const _keyPhoto = 'sos_safety_photo_opt_in';

  @override
  SosSafetyPrefs build() {
    _hydrate();
    return const SosSafetyPrefs();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    state = SosSafetyPrefs(
      isLoading: false,
      ambientAudioOptIn: prefs.getBool(_keyAmbient) ?? false,
      liveLocationOptIn: prefs.getBool(_keyLocation) ?? false,
      photoOptIn: prefs.getBool(_keyPhoto) ?? false,
    );
  }

  Future<void> setAmbientAudio(bool value) async {
    state = state.copyWith(ambientAudioOptIn: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAmbient, value);
  }

  Future<void> setLiveLocation(bool value) async {
    state = state.copyWith(liveLocationOptIn: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLocation, value);
  }

  Future<void> setPhoto(bool value) async {
    state = state.copyWith(photoOptIn: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPhoto, value);
  }
}

final sosSafetyPrefsProvider =
    NotifierProvider<SosSafetyPrefsNotifier, SosSafetyPrefs>(
  SosSafetyPrefsNotifier.new,
);
