import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceArea {
  final String id;
  final String name;
  final List<LatLng> polygon;

  ServiceArea({required this.id, required this.name, required this.polygon});

  /// Check if a point is inside the polygon using the ray casting algorithm.
  bool contains(LatLng point) {
    if (polygon.isEmpty) return false;

    var intersections = 0;
    for (var i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];

      if (p1.longitude > point.longitude != p2.longitude > point.longitude) {
        final intersectLat =
            (p2.latitude - p1.latitude) *
                (point.longitude - p1.longitude) /
                (p2.longitude - p1.longitude) +
            p1.latitude;
        if (point.latitude < intersectLat) {
          intersections++;
        }
      }
    }
    return intersections % 2 != 0;
  }
}
