/// A geographic coordinate paired with a human-readable address.
///
/// Pure Dart — no Flutter or networking imports.
/// Shared between passenger and driver apps via `sakai_shared`.
class RideLocation {
  const RideLocation({
    required this.lat,
    required this.lng,
    this.address = '',
  });

  final double lat;
  final double lng;

  /// Reverse-geocoded label (e.g. "Intramuros, Manila").
  /// Empty string when address has not been resolved yet.
  final String address;

  RideLocation copyWith({double? lat, double? lng, String? address}) {
    return RideLocation(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
    );
  }

  @override
  String toString() => 'RideLocation($lat, $lng, "$address")';

  @override
  bool operator ==(Object other) =>
      other is RideLocation &&
      other.lat == lat &&
      other.lng == lng &&
      other.address == address;

  @override
  int get hashCode => Object.hash(lat, lng, address);
}
