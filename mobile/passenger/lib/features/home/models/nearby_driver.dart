import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart' hide LatLng;

class NearbyDriver {
  final String id;
  final String name;
  final LatLng location;
  final double heading;
  final VehicleType vehicleType;

  NearbyDriver({
    required this.id,
    required this.name,
    required this.location,
    required this.heading,
    required this.vehicleType,
  });

  factory NearbyDriver.fromJson(Map<String, dynamic> json) {
    final locJson = json['location'] as Map<String, dynamic>;
    return NearbyDriver(
      id: json['id'] as String,
      name: json['name'] as String,
      location: LatLng(
        (locJson['lat'] as num).toDouble(),
        (locJson['lng'] as num).toDouble(),
      ),
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      vehicleType: _parseVehicleType(json['vehicle_type'] as String),
    );
  }

  static VehicleType _parseVehicleType(String type) {
    switch (type) {
      case 'motorcycle':
        return VehicleType.motorcycle;
      case 'car':
        return VehicleType.car;
      case 'tricycle':
        return VehicleType.tricycle;
      default:
        return VehicleType.car;
    }
  }
}
