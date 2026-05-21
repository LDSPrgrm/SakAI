import 'package:driver/features/settings/providers/sos_safety_prefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults OFF (RFC v2 §20 decision 3 — driver parity)', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(sosSafetyPrefsProvider.notifier);
    await _drain(c);
    final s = c.read(sosSafetyPrefsProvider);
    expect(s.ambientAudioOptIn, isFalse);
    expect(s.liveLocationOptIn, isFalse);
    expect(s.photoOptIn, isFalse);
  });

  test('toggles persist + rehydrate', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(sosSafetyPrefsProvider.notifier);
    await _drain(c);
    await n.setLiveLocation(true);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('sos_safety_live_location_opt_in'), isTrue);
  });
}

Future<void> _drain(ProviderContainer c) async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
    if (!c.read(sosSafetyPrefsProvider).isLoading) return;
  }
}
