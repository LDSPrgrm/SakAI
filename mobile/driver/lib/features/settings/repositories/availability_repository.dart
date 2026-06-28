/// Driver availability preferences (auto-online schedule, preferred zones).
///
/// TODO(backend): No /driver/settings or /driver/preferences endpoints yet.
abstract class AvailabilityRepository {
  Future<AvailabilityPrefs> get();
  Future<void> save(AvailabilityPrefs prefs);
}

class AvailabilityPrefs {
  const AvailabilityPrefs({
    this.autoGoOnline = false,
    this.startHour,
    this.endHour,
    this.preferredZones = const [],
  });

  final bool autoGoOnline;
  final int? startHour; // 0..23
  final int? endHour; // 0..23
  final List<String> preferredZones;

  AvailabilityPrefs copyWith({
    bool? autoGoOnline,
    int? startHour,
    int? endHour,
    List<String>? preferredZones,
  }) {
    return AvailabilityPrefs(
      autoGoOnline: autoGoOnline ?? this.autoGoOnline,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      preferredZones: preferredZones ?? this.preferredZones,
    );
  }
}
