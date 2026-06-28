import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final hiddenLocationsNotifierProvider =
    AsyncNotifierProvider<HiddenLocationsNotifier, Set<String>>(
      HiddenLocationsNotifier.new,
    );

class HiddenLocationsNotifier extends AsyncNotifier<Set<String>> {
  static const _key = 'hidden_locations';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  Future<void> hideLocation(String address) async {
    final current = state.value ?? {};
    final next = {...current, address};
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, next.toList());
  }
}
