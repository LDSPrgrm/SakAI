import 'package:sakai_api_client/sakai_api_client.dart';

/// Domain Driver model — stable wrapper around [DriverSummary].
class DomainDriver {
  final String id;
  final String name;
  final String? status;
  final DomainVehicle? vehicle;

  DomainDriver({
    required this.id,
    required this.name,
    this.status,
    this.vehicle,
  });

  factory DomainDriver.fromApi(DriverSummary d) => DomainDriver(
        id: d.id,
        name: d.name,
        vehicle: DomainVehicle.fromApi(d.vehicle),
      );
}

/// Domain Vehicle model — stable wrapper around [VehicleInfo].
class DomainVehicle {
  final String make;
  final String model;
  final String color;
  final String plate;

  DomainVehicle({
    required this.make,
    required this.model,
    required this.color,
    required this.plate,
  });

  factory DomainVehicle.fromApi(VehicleInfo v) => DomainVehicle(
        make: v.make,
        model: v.model,
        color: v.color,
        plate: v.plate,
      );
}
