import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceArea {
  final String id;
  final String name;
  final LatLng center;
  final double radius;

  ServiceArea({
    required this.id,
    required this.name,
    required this.center,
    required this.radius,
  });

  factory ServiceArea.fromJson(Map<String, dynamic> json) {
    final centerJson = json['center'] as Map<String, dynamic>;
    return ServiceArea(
      id: json['id'] as String,
      name: json['name'] as String,
      center: LatLng(
        (centerJson['lat'] as num).toDouble(),
        (centerJson['lng'] as num).toDouble(),
      ),
      radius: (json['radius'] as num).toDouble(),
    );
  }
}
