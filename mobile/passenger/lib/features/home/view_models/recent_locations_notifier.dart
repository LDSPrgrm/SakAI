import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/location_search_mode.dart';

final recentLocationsNotifierProvider =
    NotifierProvider.family<RecentLocationsNotifier, List<RideLocation>, LocationSearchMode>(
  RecentLocationsNotifier.new,
);

class RecentLocationsNotifier extends Notifier<List<RideLocation>> {
  RecentLocationsNotifier(this.arg);
  final LocationSearchMode arg;

  String get _key => arg == LocationSearchMode.pickup
      ? 'recent_pickup_locations'
      : 'recent_destination_locations';

  @override
  List<RideLocation> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final list = prefs.getStringList(_key);
    if (list == null) return [];
    return list.map((item) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        return RideLocation(
          lat: (decoded['lat'] as num).toDouble(),
          lng: (decoded['lng'] as num).toDouble(),
          address: decoded['address'] as String? ?? '',
        );
      } catch (_) {
        return null;
      }
    }).whereType<RideLocation>().toList();
  }

  Future<void> addLocation(RideLocation location) async {
    final current = [...state];
    current.removeWhere((loc) => loc.address == location.address);
    current.insert(0, location);

    if (current.length > 10) {
      current.removeRange(10, current.length);
    }

    state = current;

    final prefs = ref.read(sharedPreferencesProvider);
    final stringList = current.map((loc) => jsonEncode({
      'lat': loc.lat,
      'lng': loc.lng,
      'address': loc.address,
    })).toList();
    await prefs.setStringList(_key, stringList);
  }

  Future<void> removeLocation(RideLocation location) async {
    final current = [...state];
    current.removeWhere((loc) => loc.address == location.address);
    state = current;

    final prefs = ref.read(sharedPreferencesProvider);
    final stringList = current.map((loc) => jsonEncode({
      'lat': loc.lat,
      'lng': loc.lng,
      'address': loc.address,
    })).toList();
    await prefs.setStringList(_key, stringList);
  }
}

