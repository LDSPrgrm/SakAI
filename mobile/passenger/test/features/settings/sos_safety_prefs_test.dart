import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/settings/providers/sos_safety_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SOS-time privacy opt-ins must:
/// 1. Default to OFF per RFC v2 §20 decision 3.
/// 2. Persist across cold starts (the source of truth is SharedPreferences,
///    not in-memory state).
/// 3. Be writable independently so toggling one does not flip another.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to OFF for every SOS opt-in', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Force the hydrate to run.
    final notifier = container.read(sosSafetyPrefsProvider.notifier);
    await _waitForHydration(container);
    final prefs = container.read(sosSafetyPrefsProvider);

    expect(prefs.ambientAudioOptIn, isFalse,
        reason: 'ambient audio MUST be opt-in only — RFC v2 §20 decision 3');
    expect(prefs.liveLocationOptIn, isFalse);
    expect(prefs.photoOptIn, isFalse);
    expect(notifier, isNotNull);
  });

  test('persists ambient-audio toggle to SharedPreferences', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(sosSafetyPrefsProvider.notifier);
    await _waitForHydration(container);

    await notifier.setAmbientAudio(true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('sos_safety_ambient_audio_opt_in'), isTrue,
        reason: 'toggle must round-trip through prefs');
    expect(container.read(sosSafetyPrefsProvider).ambientAudioOptIn, isTrue);
  });

  test('toggles are independent — flipping one does not flip the others',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(sosSafetyPrefsProvider.notifier);
    await _waitForHydration(container);

    await notifier.setLiveLocation(true);
    final state = container.read(sosSafetyPrefsProvider);
    expect(state.liveLocationOptIn, isTrue);
    expect(state.ambientAudioOptIn, isFalse,
        reason: 'opt-ins are orthogonal');
    expect(state.photoOptIn, isFalse);
  });

  test('cold start re-hydrates persisted values', () async {
    SharedPreferences.setMockInitialValues({
      'sos_safety_ambient_audio_opt_in': true,
      'sos_safety_live_location_opt_in': false,
      'sos_safety_photo_opt_in': true,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(sosSafetyPrefsProvider);
    await _waitForHydration(container);

    final state = container.read(sosSafetyPrefsProvider);
    expect(state.ambientAudioOptIn, isTrue);
    expect(state.liveLocationOptIn, isFalse);
    expect(state.photoOptIn, isTrue);
  });
}

/// _waitForHydration spins the event loop until the async hydrate() inside
/// the notifier resolves. SharedPreferences.getInstance() always completes
/// in a single microtask under the mock, so two pumps are enough.
Future<void> _waitForHydration(ProviderContainer c) async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
    if (!c.read(sosSafetyPrefsProvider).isLoading) return;
  }
}
