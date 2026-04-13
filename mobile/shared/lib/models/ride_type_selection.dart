import 'package:flutter/material.dart';

enum VehicleType { motorcycle, car, tricycle }

extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.motorcycle:
        return 'Motorcycle';
      case VehicleType.car:
        return 'Car';
      case VehicleType.tricycle:
        return 'Tricycle';
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleType.motorcycle:
        return Icons.two_wheeler;
      case VehicleType.car:
        return Icons.directions_car;
      case VehicleType.tricycle:
        return Icons.airport_shuttle;
    }
  }

  String get apiValue {
    switch (this) {
      case VehicleType.motorcycle:
        return 'motorcycle';
      case VehicleType.car:
        return 'car';
      case VehicleType.tricycle:
        return 'tricycle';
    }
  }

  static VehicleType fromApi(String value) {
    switch (value) {
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

class RideTypeSelection {
  final VehicleType type;
  final double estimatedFare;
  final Duration estimatedDuration;
  final int availableDrivers;

  const RideTypeSelection({
    required this.type,
    required this.estimatedFare,
    required this.estimatedDuration,
    required this.availableDrivers,
  });
}
